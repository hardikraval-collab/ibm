/**
 * Nutrition Agentic AI — Frontend JavaScript
 * IBM Granite LLM Powered | Agentic AI Application
 */

'use strict';

// ─── State ───────────────────────────────────────────────────────────────────
let currentPlanText = '';
let currentFilename = '';
let userContext = null;

// ─── Tab Navigation ───────────────────────────────────────────────────────────
function switchTab(tab) {
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + tab).classList.add('active');
  const btns = document.querySelectorAll('.nav-btn');
  const tabIndex = ['plan', 'chat', 'plans'].indexOf(tab);
  if (btns[tabIndex]) btns[tabIndex].classList.add('active');
  if (tab === 'plans') loadPlans();
}

// ─── Medical History Checkboxes ───────────────────────────────────────────────
function updateMedical(noneSelected) {
  const checkboxes = document.querySelectorAll('.checkbox-group input[type="checkbox"]');
  const noneBox = document.getElementById('chk-none');

  if (noneSelected) {
    if (noneBox.checked) {
      checkboxes.forEach(cb => { if (cb.value !== 'None') cb.checked = false; });
    }
  } else {
    if (noneBox.checked) noneBox.checked = false;
  }

  const selected = Array.from(checkboxes)
    .filter(cb => cb.checked && cb.value !== 'None')
    .map(cb => cb.value);

  const hidden = document.getElementById('medical_history');
  if (noneBox.checked || selected.length === 0) {
    hidden.value = 'None';
  } else {
    hidden.value = selected.join(', ');
  }
}

// ─── Form Submission → Generate Plan ─────────────────────────────────────────
async function handleSubmit(e) {
  e.preventDefault();
  clearError();

  const userData = collectFormData();
  if (!userData) return;

  // Show loading
  showLoading();

  try {
    // Animate progress steps
    animateProgress();

    const response = await fetch('/api/generate-plan', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData)
    });

    const data = await response.json();

    if (!data.success) {
      showError(data.error || 'Failed to generate plan. Please try again.');
      showWelcome();
      return;
    }

    // Store for download
    currentPlanText = data.plan || '';
    currentFilename = data.filename || '';
    userContext = userData;

    // Update badge
    const badge = document.getElementById('plan-source-badge');
    if (badge) {
      badge.textContent = data.source === 'ibm-granite' ? '🤖 IBM Granite' : '🧠 AI Engine';
    }

    // Render plan
    setTimeout(() => {
      renderPlan(data.plan);
      if (data.filename) {
        showNotification(`✅ Plan saved: ${data.filename}`, 'success');
      }
    }, 600);

  } catch (err) {
    showError('Connection error. Please check your network and try again.');
    showWelcome();
  }
}

function collectFormData() {
  const name = document.getElementById('name').value.trim();
  const age = document.getElementById('age').value.trim();
  const diet = document.getElementById('diet_preference').value;

  if (!name) { showError('Please enter your name.'); return null; }
  if (!age || isNaN(age) || age < 1 || age > 120) { showError('Please enter a valid age (1–120).'); return null; }
  if (!diet) { showError('Please select your diet preference.'); return null; }

  const apiKey = document.getElementById('api_key').value.trim();
  const projectId = document.getElementById('project_id').value.trim();
  const apiUrl = document.getElementById('api_url').value.trim();

  // Set environment variables if provided (passed to backend for this session)
  const userData = {
    name,
    age: parseInt(age),
    diet_preference: diet,
    weight: document.getElementById('weight').value || null,
    height: document.getElementById('height').value || null,
    activity_level: document.getElementById('activity_level').value || 'Moderate',
    goal: document.getElementById('goal').value || 'Maintain healthy weight',
    medical_history: document.getElementById('medical_history').value || 'None',
    allergies: document.getElementById('allergies').value.trim() || 'None',
    city: document.getElementById('city').value.trim() || '',
    country: document.getElementById('country').value.trim() || '',
    api_key: apiKey || null,
    project_id: projectId || null,
    api_url: apiUrl || null
  };

  return userData;
}

// ─── Loading & Progress Animation ────────────────────────────────────────────
function showLoading() {
  document.getElementById('welcome-state').style.display = 'none';
  document.getElementById('loading-state').style.display = 'flex';
  document.getElementById('plan-output').style.display = 'none';
  document.getElementById('submitBtn').disabled = true;

  // Reset progress
  for (let i = 1; i <= 5; i++) {
    const el = document.getElementById('prog-' + i);
    if (el) el.classList.remove('active', 'done');
  }
}

function animateProgress() {
  const steps = [
    { id: 'prog-1', delay: 0 },
    { id: 'prog-2', delay: 800 },
    { id: 'prog-3', delay: 1600 },
    { id: 'prog-4', delay: 2400 },
    { id: 'prog-5', delay: 3200 }
  ];

  steps.forEach(({ id, delay }, idx) => {
    setTimeout(() => {
      // Mark previous as done
      if (idx > 0) {
        const prev = document.getElementById(steps[idx - 1].id);
        if (prev) { prev.classList.remove('active'); prev.classList.add('done'); }
      }
      const el = document.getElementById(id);
      if (el) el.classList.add('active');
    }, delay);
  });
}

function showWelcome() {
  document.getElementById('welcome-state').style.display = 'flex';
  document.getElementById('loading-state').style.display = 'none';
  document.getElementById('plan-output').style.display = 'none';
  document.getElementById('submitBtn').disabled = false;
}

// ─── Plan Rendering ───────────────────────────────────────────────────────────
function renderPlan(planText) {
  document.getElementById('loading-state').style.display = 'none';
  document.getElementById('welcome-state').style.display = 'none';
  document.getElementById('plan-output').style.display = 'flex';
  document.getElementById('submitBtn').disabled = false;

  const content = document.getElementById('plan-content');
  content.innerHTML = markdownToHtml(planText);

  // Scroll to output
  content.scrollTop = 0;
}

function clearPlan() {
  currentPlanText = '';
  currentFilename = '';
  showWelcome();
  document.getElementById('plan-source-badge').textContent = 'AI Ready';
}

// ─── Markdown to HTML (minimal parser) ───────────────────────────────────────
function markdownToHtml(md) {
  if (!md) return '';
  let html = escapeHtml(md);

  // Headers
  html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
  html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
  html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');
  html = html.replace(/^#### (.+)$/gm, '<h4>$1</h4>');

  // Bold, italic
  html = html.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>');
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');

  // Blockquote
  html = html.replace(/^&gt; (.+)$/gm, '<blockquote>$1</blockquote>');

  // HR
  html = html.replace(/^---$/gm, '<hr/>');

  // Unordered lists
  html = html.replace(/((?:^- .+$\n?)+)/gm, (match) => {
    const items = match.trim().split('\n').map(l => {
      const text = l.replace(/^- /, '');
      return `<li>${text}</li>`;
    }).join('');
    return `<ul>${items}</ul>`;
  });

  // Tables
  html = html.replace(/((?:^\|.+\|\s*$\n?)+)/gm, (match) => {
    const rows = match.trim().split('\n').filter(r => !r.match(/^\|[-:| ]+\|$/));
    if (rows.length < 1) return match;
    const headerRow = rows[0];
    const dataRows = rows.slice(1);
    const cells = (row) => row.split('|').filter((_, i, a) => i > 0 && i < a.length - 1)
      .map(c => c.trim()).join('</td><td>');
    const thead = `<tr><th>${headerRow.split('|').filter((_, i, a) => i > 0 && i < a.length - 1).map(c => c.trim()).join('</th><th>')}</th></tr>`;
    const tbody = dataRows.map(r => `<tr><td>${cells(r)}</td></tr>`).join('');
    return `<table><thead>${thead}</thead><tbody>${tbody}</tbody></table>`;
  });

  // Paragraphs (lines not starting with block elements)
  const lines = html.split('\n');
  const result = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i].trim();
    if (line === '') {
      result.push('<br/>');
    } else if (line.startsWith('<h') || line.startsWith('<ul') || line.startsWith('<table') ||
               line.startsWith('<blockquote') || line.startsWith('<hr') || line.startsWith('<li')) {
      result.push(line);
    } else {
      result.push(`<p>${line}</p>`);
    }
    i++;
  }

  return result.join('\n');
}

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ─── Plan Actions ─────────────────────────────────────────────────────────────
function downloadPlan() {
  if (!currentFilename) {
    showNotification('No plan to download.', 'error');
    return;
  }
  const link = document.createElement('a');
  link.href = '/api/download-plan/' + encodeURIComponent(currentFilename);
  link.download = currentFilename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  showNotification('⬇️ Downloading ' + currentFilename, 'success');
}

function printPlan() {
  if (!currentPlanText) { showNotification('No plan to print.', 'error'); return; }
  const win = window.open('', '_blank');
  win.document.write(`<html><head><title>Nutrition Plan</title>
    <style>body{font-family:sans-serif;padding:20px;max-width:800px;margin:0 auto;}
    h1{color:#1a5c32;}h2{color:#2d7d46;border-left:3px solid #2d7d46;padding-left:10px;}
    table{width:100%;border-collapse:collapse;}th{background:#2d7d46;color:white;padding:8px;}
    td{padding:7px;border-bottom:1px solid #e5e7eb;}blockquote{border-left:3px solid #d97706;background:#fef3c7;padding:10px;}
    </style></head><body>${markdownToHtml(currentPlanText)}</body></html>`);
  win.document.close();
  win.print();
}

function copyPlan() {
  if (!currentPlanText) { showNotification('No plan to copy.', 'error'); return; }
  if (navigator.clipboard) {
    navigator.clipboard.writeText(currentPlanText).then(() => {
      showNotification('📋 Plan copied to clipboard!', 'success');
    });
  } else {
    const ta = document.createElement('textarea');
    ta.value = currentPlanText;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    showNotification('📋 Plan copied!', 'success');
  }
}

// ─── Chat / Q&A ───────────────────────────────────────────────────────────────
async function sendChat() {
  const input = document.getElementById('chat-input');
  const question = input.value.trim();
  if (!question) return;

  input.value = '';
  addChatBubble(question, 'user');
  const typing = addTypingIndicator();

  try {
    const response = await fetch('/api/query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        question,
        user_context: userContext
      })
    });

    const data = await response.json();
    removeElement(typing);

    if (data.success) {
      addChatBubble(data.answer + (data.disclaimer ? `\n\n*${data.disclaimer}*` : ''), 'ai');
    } else {
      addChatBubble(data.answer || 'Sorry, I could not answer that. Please try again.', 'ai');
    }
  } catch (err) {
    removeElement(typing);
    addChatBubble('Network error. Please check your connection and try again.', 'ai');
  }
}

function askQuick(question) {
  document.getElementById('chat-input').value = question;
  sendChat();
}

function addChatBubble(text, role) {
  const messages = document.getElementById('chat-messages');
  const div = document.createElement('div');
  div.className = `chat-bubble ${role === 'user' ? 'user-bubble' : 'ai-bubble'}`;

  const avatar = role === 'user' ? '👤' : '🤖';
  const html = role === 'ai' ? markdownToHtml(text) : `<p>${escapeHtml(text)}</p>`;

  div.innerHTML = `
    <div class="bubble-avatar">${avatar}</div>
    <div class="bubble-text">${html}</div>
  `;

  messages.appendChild(div);
  messages.scrollTop = messages.scrollHeight;
  return div;
}

function addTypingIndicator() {
  const messages = document.getElementById('chat-messages');
  const div = document.createElement('div');
  div.className = 'chat-bubble ai-bubble typing-indicator';
  div.innerHTML = `
    <div class="bubble-avatar">🤖</div>
    <div class="bubble-text">
      <span class="typing-dot"></span>
      <span class="typing-dot"></span>
      <span class="typing-dot"></span>
    </div>
  `;
  messages.appendChild(div);
  messages.scrollTop = messages.scrollHeight;
  return div;
}

function removeElement(el) { if (el && el.parentNode) el.parentNode.removeChild(el); }

// ─── Saved Plans ──────────────────────────────────────────────────────────────
async function loadPlans() {
  const list = document.getElementById('plans-list');
  list.innerHTML = '<p class="empty-msg">Loading...</p>';

  try {
    const resp = await fetch('/api/list-plans');
    const data = await resp.json();

    if (!data.plans || data.plans.length === 0) {
      list.innerHTML = `
        <div class="empty-msg">
          <div style="font-size:48px;margin-bottom:12px">📂</div>
          <p>No saved plans yet. Generate your first nutrition plan!</p>
        </div>`;
      return;
    }

    list.innerHTML = data.plans.map(p => `
      <div class="plan-item">
        <span class="plan-item-icon">📄</span>
        <div class="plan-item-info">
          <div class="plan-item-name">${escapeHtml(p.filename)}</div>
          <div class="plan-item-meta">Created: ${p.created} · ${formatBytes(p.size)}</div>
        </div>
        <button class="btn-secondary small" onclick="downloadFile('${escapeHtml(p.filename)}')">⬇️ Download</button>
      </div>
    `).join('');
  } catch (e) {
    list.innerHTML = '<p class="empty-msg">Unable to load plans. Please try again.</p>';
  }
}

function downloadFile(filename) {
  const link = document.createElement('a');
  link.href = '/api/download-plan/' + encodeURIComponent(filename);
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function formatBytes(bytes) {
  if (bytes < 1024) return bytes + ' B';
  return (bytes / 1024).toFixed(1) + ' KB';
}

// ─── Error Handling ───────────────────────────────────────────────────────────
function showError(msg) {
  const el = document.getElementById('form-error');
  if (el) { el.textContent = '⚠️ ' + msg; el.style.display = 'block'; }
}

function clearError() {
  const el = document.getElementById('form-error');
  if (el) { el.textContent = ''; el.style.display = 'none'; }
}

// ─── Toast Notification ───────────────────────────────────────────────────────
function showNotification(message, type) {
  const existing = document.getElementById('toast-notif');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.id = 'toast-notif';
  toast.style.cssText = `
    position: fixed; bottom: 24px; right: 24px; z-index: 9999;
    background: ${type === 'success' ? '#1a5c32' : '#dc2626'};
    color: white; padding: 12px 20px; border-radius: 10px;
    font-size: 13px; font-weight: 600; font-family: sans-serif;
    box-shadow: 0 8px 24px rgba(0,0,0,.2); max-width: 360px;
    animation: slideIn .3s ease;
  `;
  toast.textContent = message;

  const style = document.createElement('style');
  style.textContent = '@keyframes slideIn{from{transform:translateY(20px);opacity:0}to{transform:translateY(0);opacity:1}}';
  document.head.appendChild(style);
  document.body.appendChild(toast);

  setTimeout(() => { if (toast.parentNode) toast.remove(); }, 4000);
}

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  // Default: no medical condition checked
  document.getElementById('chk-none').checked = true;

  // Keyboard shortcut: Ctrl+Enter to submit
  document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.key === 'Enter') {
      const btn = document.getElementById('submitBtn');
      if (btn && !btn.disabled) btn.click();
    }
  });
});
