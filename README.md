# 🥗 Nutrition Agentic AI — IBM Granite Powered

> A full-stack **Agentic AI** web application that generates personalised 7-day nutrition plans using **IBM Granite LLM** via **watsonx.ai**, with ethical guardrails, HAM principles, and medical disclaimers built in.

[![Python](https://img.shields.io/badge/Python-3.7+-blue.svg)](https://python.org)
[![Flask](https://img.shields.io/badge/Flask-1.0+-green.svg)](https://flask.palletsprojects.com)
[![IBM Granite](https://img.shields.io/badge/IBM-Granite%20LLM-0f62fe.svg)](https://watsonx.ai)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Table of Contents

- [Features](#-features)
- [Agentic AI SDLC Phases](#-agentic-ai-sdlc-phases)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Running the Application](#-running-the-application)
- [Project Structure](#-project-structure)
- [API Reference](#-api-reference)
- [AI Ethics & Guardrails](#-ai-ethics--guardrails)
- [Screenshots](#-screenshots)
- [Medical Disclaimer](#-medical-disclaimer)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **IBM Granite LLM** | Powered by `ibm/granite-13b-instruct-v2` via watsonx.ai REST API |
| 👤 **User Profiling** | Collects name, age, diet preference, medical history, location |
| 📋 **7-Day Plans** | Full week meal plans with breakfast, lunch, dinner & snacks |
| 🛡️ **Ethical Guardrails** | Input/output screening, harmful content filtering |
| ⚕️ **Medical Awareness** | Handles diabetes, hypertension, allergies & more |
| 💬 **Q&A Agent** | Context-aware nutrition questions answered by IBM Granite |
| 💾 **Markdown Export** | Plans saved as `.md` files with YAML front-matter |
| 🌍 **Cultural Context** | Incorporates local foods based on user's city/country |
| 📱 **Responsive UI** | Clean, mobile-friendly web interface |
| ⚡ **Fallback AI** | Full rule-based intelligence when API is unavailable |

---

## 🔄 Agentic AI SDLC Phases

This application follows all phases of the **Agentic AI Software Development Life Cycle**:

```
Phase 1 — Requirements Analysis
  └─ User profile collection: name, age, diet, medical history, location

Phase 2 — Agent Design
  └─ Multi-agent architecture: Planner → Executor → Guardrail → Reflector → Q&A

Phase 3 — Prompt Engineering
  └─ Structured, context-aware prompts with ethical constraints

Phase 4 — Tool Integration
  └─ IBM Granite via watsonx.ai REST API + fallback rule engine

Phase 5 — Guardrails & Ethics (HAM)
  └─ Harmful keyword filtering, medical boundary enforcement

Phase 6 — Plan Persistence
  └─ Markdown file generation with YAML metadata

Phase 7 — Deployment
  └─ Flask web server, REST API endpoints, HTML/CSS/JS frontend
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Nutrition Agentic AI                       │
│                                                             │
│  ┌──────────┐    ┌──────────────────────────────────────┐  │
│  │  Browser │───▶│        Flask Web Server              │  │
│  │ (HTML/JS)│◀───│          app.py                      │  │
│  └──────────┘    └──────────────────┬───────────────────┘  │
│                                     │                       │
│                  ┌──────────────────▼───────────────────┐  │
│                  │      Agentic Pipeline (granite_agent) │  │
│                  │                                       │  │
│                  │  [1] Input Validation                 │  │
│                  │  [2] Guardrail Screening              │  │
│                  │  [3] Prompt Builder (Planning)        │  │
│                  │  [4] IBM Granite API Call (Execution) │  │
│                  │  [5] Output Guardrails (Reflection)   │  │
│                  │  [6] Fallback AI (if API unavailable) │  │
│                  └──────────────────┬───────────────────┘  │
│                                     │                       │
│              ┌──────────────────────┼────────────────┐     │
│              ▼                      ▼                 ▼     │
│    ┌──────────────┐    ┌──────────────────┐  ┌──────────┐  │
│    │ watsonx.ai   │    │  Nutrition Plans  │  │  Q&A     │  │
│    │ IBM Granite  │    │  (.md files)      │  │  Agent   │  │
│    └──────────────┘    └──────────────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisites

- **Python 3.7+** (Anaconda recommended)
- **pip** package manager
- **IBM watsonx.ai account** *(optional — app works without it using fallback AI)*
  - API Key from [IBM Cloud](https://cloud.ibm.com)
  - watsonx.ai Project ID

---

## 🚀 Installation

### Option 1 — One-Click (Windows)

```bat
# Double-click the batch file:
start_nutrition_ai.bat
```

This will automatically install dependencies, load configuration, start the server, and open your browser.

### Option 2 — Manual Installation

**1. Clone the repository:**
```bash
git clone https://github.com/hardikraval-collab/ibm.git
cd ibm
```

**2. Install dependencies:**
```bash
pip install -r NutritionAI/requirements.txt
```

**3. Configure environment (optional for IBM Granite):**
```bash
# Edit NutritionAI/config.env with your IBM credentials
WATSONX_API_KEY=your_api_key_here
WATSONX_PROJECT_ID=your_project_id_here
WATSONX_API_URL=https://us-south.ml.cloud.ibm.com
```

**4. Run the application:**
```bash
cd NutritionAI
python app.py
```

**5. Open browser:**
```
http://localhost:5000
```

---

## ⚙️ Configuration

Edit `NutritionAI/config.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `WATSONX_API_KEY` | IBM Cloud API Key | `YOUR_IBM_WATSONX_API_KEY` |
| `WATSONX_PROJECT_ID` | watsonx.ai Project ID | `YOUR_PROJECT_ID` |
| `WATSONX_API_URL` | API Endpoint URL | `https://us-south.ml.cloud.ibm.com` |
| `PORT` | Flask server port | `5000` |

> **Note:** If no API key is configured, the app uses the intelligent built-in AI engine (rule-based with full nutrition knowledge). You still get a complete, personalised 7-day plan!

You can also enter credentials directly in the web UI under **"IBM watsonx.ai Configuration"**.

---

## ▶️ Running the Application

```bash
cd NutritionAI
python app.py
```

Expected output:
```
============================================================
  Nutrition Agentic AI -- IBM Granite Powered
============================================================
  Server  : http://localhost:5000
  Plans   : /path/to/NutritionAI/nutrition_plans
  Model   : IBM Granite (watsonx.ai)
============================================================
 * Running on http://0.0.0.0:5000/
```

---

## 📁 Project Structure

```
ibm/
├── NutritionAI/
│   ├── app.py                    # Flask application & REST API
│   ├── requirements.txt          # Python dependencies
│   ├── config.env                # Environment configuration
│   ├── agents/
│   │   ├── __init__.py
│   │   └── granite_agent.py      # IBM Granite LLM agent + guardrails
│   ├── templates/
│   │   └── index.html            # Web UI (3-tab application)
│   ├── static/
│   │   ├── css/
│   │   │   └── style.css         # Application stylesheet
│   │   └── js/
│   │       └── app.js            # Frontend JavaScript
│   └── nutrition_plans/          # Generated .md plans (auto-created)
├── start_nutrition_ai.bat        # Windows one-click launcher
├── README.md                     # This file
├── .gitignore                    # Git ignore rules
└── requirements.txt              # Root-level requirements
```

---

## 🔌 API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Web application homepage |
| `POST` | `/api/generate-plan` | Generate personalised nutrition plan |
| `POST` | `/api/query` | Ask nutrition Q&A question |
| `GET` | `/api/download-plan/<filename>` | Download saved `.md` plan |
| `GET` | `/api/list-plans` | List all saved plans |
| `GET` | `/api/health` | Health check |

### POST `/api/generate-plan` — Request Body

```json
{
  "name": "Aisha Khan",
  "age": 35,
  "diet_preference": "vegetarian",
  "medical_history": "diabetes, blood pressure",
  "goal": "Manage diabetes",
  "weight": 68,
  "height": 165,
  "activity_level": "Moderate",
  "allergies": "peanuts",
  "city": "Mumbai",
  "country": "India",
  "api_key": "optional-your-ibm-key",
  "project_id": "optional-your-project-id"
}
```

---

## 🛡️ AI Ethics & Guardrails

This application implements **IBM's AI Ethics Principles**:

- **Helpful (H):** Provides evidence-based, personalised nutrition guidance
- **Accurate & Honest (A):** Transparent about AI-generated content and limitations
- **Mindful (M):** Respects medical boundaries, includes professional consultation advice

**Guardrail protections:**
- Harmful keyword screening on all inputs and outputs
- No recommendations for crash diets, extreme weight loss, or harmful practices
- Medical condition-aware advice (avoids contraindicated foods)
- Clear medical disclaimer on every generated plan
- Emergency care guidance when appropriate

---

## ⚠️ Medical Disclaimer

> This application generates AI-powered nutrition information **for educational purposes only**. It is **NOT** a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified nutritionist, dietitian, or physician before making significant dietary changes — especially if you have a medical condition.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m "Add your feature"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Made with ❤️ using IBM Granite & watsonx.ai*
