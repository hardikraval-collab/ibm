@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM   Nutrition Agentic AI — Startup Script
REM   IBM Granite LLM Powered | watsonx.ai
REM ═══════════════════════════════════════════════════════════════════════════

title Nutrition Agentic AI - IBM Granite

echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║       🥗  Nutrition Agentic AI — IBM Granite            ║
echo  ║       Powered by watsonx.ai                             ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

REM ─── Set Python path (Anaconda) ────────────────────────────────────────────
SET PYTHON_EXE=C:\ProgramData\Anaconda3\python.exe
SET PIP_EXE=C:\ProgramData\Anaconda3\Scripts\pip.exe
SET APP_DIR=%~dp0NutritionAI

REM ─── Check Python ──────────────────────────────────────────────────────────
IF NOT EXIST "%PYTHON_EXE%" (
    echo  [ERROR] Python not found at %PYTHON_EXE%
    echo  Please install Anaconda or update the PYTHON_EXE path in this file.
    pause
    exit /b 1
)

echo  [✓] Python found: %PYTHON_EXE%

REM ─── Install / Verify Dependencies ─────────────────────────────────────────
echo  [*] Checking dependencies...
"%PIP_EXE%" install flask flask-cors requests ibm-watson==4.7.1 ibm-cloud-sdk-core==1.7.3 markdown python-dotenv PyJWT --quiet 2>nul
echo  [✓] Dependencies verified.

REM ─── Load config.env if present ─────────────────────────────────────────────
IF EXIST "%APP_DIR%\config.env" (
    echo  [*] Loading configuration from config.env...
    FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%APP_DIR%\config.env") DO (
        IF NOT "%%A"=="" (
            IF NOT "%%A:~0,1%"=="#" (
                SET "%%A=%%B"
            )
        )
    )
    echo  [✓] Configuration loaded.
) ELSE (
    echo  [!] config.env not found — using defaults (fallback AI mode).
)

echo.
echo  ─────────────────────────────────────────────────────────────
echo    Configuration:
echo      App URL    : http://localhost:5000
echo      Plans Dir  : %APP_DIR%\nutrition_plans\
echo      AI Model   : IBM Granite (watsonx.ai)
echo  ─────────────────────────────────────────────────────────────
echo.
echo  [*] Starting Nutrition Agentic AI server...
echo  [*] Opening browser in 3 seconds...
echo.

REM ─── Open browser after delay ──────────────────────────────────────────────
START /B cmd /c "timeout /t 3 /nobreak >nul && start http://localhost:5000"

REM ─── Start Flask server ────────────────────────────────────────────────────
cd /d "%APP_DIR%"
"%PYTHON_EXE%" app.py

REM ─── On exit ────────────────────────────────────────────────────────────────
echo.
echo  [!] Server stopped.
pause
