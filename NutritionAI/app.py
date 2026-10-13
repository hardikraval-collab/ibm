"""
Nutrition Agentic AI — Flask Application Server
IBM Granite LLM Powered | Agentic AI SDLC

Agentic AI SDLC Phases Implemented:
  1. Requirements Analysis  — user profile collection
  2. Agent Design           — multi-agent architecture (planner, executor, guardrail, Q&A)
  3. Prompt Engineering     — structured, ethics-aware prompts
  4. Tool Integration       — IBM Granite watsonx.ai REST API
  5. Guardrails & Ethics    — input/output filtering, HAM principles
  6. Plan Persistence       — Markdown file generation
  7. Deployment             — Flask web server
"""

import os
import re
import json
from datetime import datetime
from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS

# Add parent directory to path for agent imports
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agents.granite_agent import (
    generate_nutrition_plan,
    answer_nutrition_query
)

app = Flask(__name__)
CORS(app)

# ─── Directory Setup ──────────────────────────────────────────────────────────
PLANS_DIR = os.path.join(os.path.dirname(__file__), "nutrition_plans")
os.makedirs(PLANS_DIR, exist_ok=True)


# ─── Utility ─────────────────────────────────────────────────────────────────
def sanitize_filename(name: str) -> str:
    """Create a safe filename from user name."""
    safe = re.sub(r'[^\w\s-]', '', name.strip()).replace(' ', '_')
    return safe[:30] if safe else "User"


def save_plan_to_md(user_data: dict, plan_text: str) -> str:
    """
    Agentic Tool: Persist nutrition plan to a Markdown file.
    Returns the filename saved.
    """
    name = sanitize_filename(user_data.get("name", "User"))
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{name}_NutritionPlan_{timestamp}.md"
    filepath = os.path.join(PLANS_DIR, filename)

    header = f"""---
title: "Personalised Nutrition Plan — {user_data.get('name', 'User')}"
generated: "{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
model: "IBM Granite (watsonx.ai)"
diet: "{user_data.get('diet_preference', 'N/A')}"
age: {user_data.get('age', 'N/A')}
location: "{user_data.get('city', '')}, {user_data.get('country', '')}"
medical_history: "{user_data.get('medical_history', 'None')}"
---

"""
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(header + plan_text)

    return filename


# ─── Routes ──────────────────────────────────────────────────────────────────

@app.route('/')
def index():
    """Serve the main application page."""
    return render_template('index.html')


@app.route('/api/generate-plan', methods=['POST'])
def generate_plan():
    """
    Endpoint: Generate personalised nutrition plan.
    Agentic Pipeline: Collect → Validate → Plan → Execute → Reflect → Persist
    """
    try:
        user_data = request.get_json()
        if not user_data:
            return jsonify({"success": False, "error": "No user data provided"}), 400

        # If user provided API credentials via form, set them in environment
        if user_data.get('api_key'):
            os.environ['WATSONX_API_KEY'] = user_data.pop('api_key')
        if user_data.get('project_id'):
            os.environ['WATSONX_PROJECT_ID'] = user_data.pop('project_id')
        if user_data.get('api_url'):
            os.environ['WATSONX_API_URL'] = user_data.pop('api_url')

        # Validate required fields
        required = ['name', 'age', 'diet_preference']
        for field in required:
            if not user_data.get(field):
                return jsonify({
                    "success": False,
                    "error": f"Required field missing: {field}"
                }), 400

        # Validate age
        try:
            age = int(user_data.get('age', 0))
            if age < 1 or age > 120:
                return jsonify({"success": False, "error": "Please enter a valid age (1–120)"}), 400
            user_data['age'] = age
        except (ValueError, TypeError):
            return jsonify({"success": False, "error": "Age must be a number"}), 400

        # Run agentic pipeline
        result = generate_nutrition_plan(user_data)

        if not result["success"]:
            return jsonify(result), 400

        # Save plan to markdown file
        filename = save_plan_to_md(user_data, result["plan"])
        result["filename"] = filename
        result["message"] = f"Your nutrition plan has been saved as: {filename}"

        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"An unexpected error occurred. Please try again. ({str(e)[:100]})"
        }), 500


@app.route('/api/query', methods=['POST'])
def query_agent():
    """
    Endpoint: Answer nutrition-related questions using IBM Granite.
    Agentic Q&A with context awareness.
    """
    try:
        data = request.get_json()
        question = data.get('question', '').strip()
        user_context = data.get('user_context', None)

        if not question:
            return jsonify({"success": False, "answer": "Please enter a question."}), 400

        if len(question) > 500:
            return jsonify({"success": False, "answer": "Question too long. Please keep it under 500 characters."}), 400

        result = answer_nutrition_query(question, user_context)
        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            "success": False,
            "answer": f"Unable to process your question. Please try again."
        }), 500


@app.route('/api/download-plan/<filename>', methods=['GET'])
def download_plan(filename):
    """Download the saved nutrition plan .md file."""
    # Security: sanitize filename
    safe_name = re.sub(r'[^a-zA-Z0-9_\-.]', '', filename)
    return send_from_directory(PLANS_DIR, safe_name, as_attachment=True)


@app.route('/api/list-plans', methods=['GET'])
def list_plans():
    """List all saved nutrition plans."""
    try:
        files = []
        for f in os.listdir(PLANS_DIR):
            if f.endswith('.md'):
                fp = os.path.join(PLANS_DIR, f)
                stat = os.stat(fp)
                files.append({
                    "filename": f,
                    "size": stat.st_size,
                    "created": datetime.fromtimestamp(stat.st_ctime).strftime("%Y-%m-%d %H:%M")
                })
        files.sort(key=lambda x: x['created'], reverse=True)
        return jsonify({"success": True, "plans": files[:20]}), 200
    except Exception:
        return jsonify({"success": True, "plans": []}), 200


@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy",
        "service": "Nutrition Agentic AI",
        "model": "IBM Granite (watsonx.ai)",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat()
    }), 200


# ─── Run Server ───────────────────────────────────────────────────────────────
if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    print("=" * 60)
    print("  Nutrition Agentic AI -- IBM Granite Powered")
    print("=" * 60)
    print("  Server  : http://localhost:{}".format(port))
    print("  Plans   : {}".format(PLANS_DIR))
    print("  Model   : IBM Granite (watsonx.ai)")
    print("=" * 60)
    app.run(host='0.0.0.0', port=port, debug=False)
