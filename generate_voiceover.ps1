# ============================================================
#  Nutrition Agentic AI — Voiceover Generator
#  Uses Windows SAPI TTS to generate narration WAV
#  17 slides, ~150 seconds total narration
# ============================================================

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$FFMPEG    = "C:\Users\STUDENT\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin\ffmpeg.exe"
$WorkDir   = "C:\Users\STUDENT\Desktop\IBM_Workshop"
$VideoIn   = "$WorkDir\NutritionAI_IBM_Granite_150s.mp4"
$VoiceWav  = "$WorkDir\voiceover_full.wav"
$VideoOut  = "$WorkDir\NutritionAI_IBM_Granite_WithVoice.mp4"

Set-Location $WorkDir

# ── Full narration script (~150 seconds at normal TTS pace) ──
$script = @"
Welcome to the Nutrition Agentic AI project, powered by IBM Granite Large Language Model and watsonx dot ai.

This is a complete full-stack agentic AI web application that generates personalised seven-day nutrition plans.
It uses IBM Granite thirteen billion parameter model via the watsonx dot ai REST API,
and applies ethical AI guardrails with H A M principles throughout.

The project follows all seven phases of the Agentic AI Software Development Life Cycle.
Phase one collects user requirements: name, age, diet preference, medical history, and location.
Phase two designs the multi-agent architecture: planner, executor, guardrail, reflector, and question-and-answer agents.
Phase three builds structured, ethics-aware prompts.
Phase four integrates IBM Granite via the watsonx dot ai API.
Phase five applies guardrails and H A M — Helpful, Accurate, and Mindful — principles.
Phase six persists every plan as a Markdown dot md file.
Phase seven deploys the full Flask web server.

The system architecture connects three layers.
The browser sends H T T P requests to the Flask server running app dot py.
Flask calls the agentic pipeline in granite underscore agent dot py,
which either calls IBM Granite on watsonx dot ai or falls back to the built-in rule-based AI engine.
All inputs and outputs pass through the guardrail screening layer before delivery.

For IBM Granite integration, the application uses the model I D ibm slash granite dash thirteen B dash instruct dash v two.
It authenticates using IBM Cloud I A M tokens, sends structured prompts with user context,
and parses the generated text response. If the API is unavailable, the intelligent fallback engine activates automatically.

The web interface has three tabs.
The Generate Plan tab shows a user profile form on the left where you enter your name, age, diet preference,
medical history like diabetes or blood pressure, and your city and country for culturally relevant food suggestions.
On the right, the A I agent generates your complete seven-day personalised nutrition plan instantly.

The Ask A I tab provides a chat interface powered by IBM Granite.
You can ask any nutrition question — about protein, blood sugar, hydration, vitamins, or managing health conditions.
Quick-question shortcuts are available for common queries.
All responses are screened by ethical guardrails before display.

Every nutrition plan is saved as a Markdown file with Y A M L front-matter metadata.
The file includes the full seven-day plan — breakfast, lunch, dinner, and two daily snacks —
plus a macronutrient summary table and a medical disclaimer appended automatically to every plan.

The seven-day plan provides complete daily coverage.
Day one focuses on energy and balance. Day two on protein power. Day three on heart health.
Day four recharges midweek. Day five targets fibre and gut health.
Day six is weekend wellness. Day seven promotes rest and recovery.
All calorie and macro targets are adjusted for medical conditions:
low glycaemic index foods for diabetes, and low sodium for blood pressure management.

Ethical A I is enforced throughout using H A M principles.
Helpful: evidence-based personalised guidance.
Accurate and honest: transparent A I content with clear limitations.
Mindful: respects medical boundaries and recommends professional consultation.
Guardrails screen for harmful keywords like crash diet, starve, overdose, and extreme diet
on both inputs and outputs, ensuring no harmful advice is ever delivered.

The REST A P I provides six endpoints:
G E T slash for the web app homepage,
P O S T slash A P I slash generate dash plan for nutrition plan generation,
P O S T slash A P I slash query for the Q and A agent,
G E T slash A P I slash download dash plan for file download,
G E T slash A P I slash list dash plans for listing saved plans,
and G E T slash A P I slash health for the service status check.

The project contains thirteen files totalling nearly three thousand lines of code:
the Flask server, the IBM Granite agent with guardrails, the responsive web templates,
C S S stylesheets, JavaScript frontend, requirements, and the Windows batch launcher.

To run the application, simply double-click start underscore nutrition underscore A I dot bat on Windows,
or clone the repository with git clone https github dot com slash hardikraval-collab slash ibm,
install requirements, and run python app dot py.
Open your browser at http localhost five thousand.

In summary, this project demonstrates a production-quality agentic A I application
built with IBM Granite, covering all S D L C phases, ethical A I design, and real-world deployment.
The complete source code, presentation, and this video are all available on GitHub.

IMPORTANT: This application is for educational purposes only and is not a substitute for professional medical advice.
Always consult a qualified nutritionist or physician before making dietary changes.

Thank you for watching the Nutrition Agentic AI project powered by IBM Granite and watsonx dot ai.
"@

Write-Host "============================================================"
Write-Host "  Nutrition Agentic AI — Voiceover Generator"
Write-Host "============================================================"
Write-Host ""
Write-Host "[1/4] Initialising Windows SAPI Text-to-Speech..."

Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Select best available voice (prefer David for clarity)
$voices = $synth.GetInstalledVoices()
$chosen = $null
foreach ($v in $voices) {
    if ($v.VoiceInfo.Name -like "*David*") { $chosen = $v.VoiceInfo.Name; break }
}
if (-not $chosen -and $voices.Count -gt 0) { $chosen = $voices[0].VoiceInfo.Name }
$synth.SelectVoice($chosen)
$synth.Rate   = -1    # Slightly slower = clearer narration (-10 to 10)
$synth.Volume = 100   # Maximum volume
Write-Host "     Voice   : $chosen"
Write-Host "     Rate    : -1 (slightly slow for clarity)"
Write-Host "     Volume  : 100%"

Write-Host ""
Write-Host "[2/4] Generating voiceover WAV: $VoiceWav"
$synth.SetOutputToWaveFile($VoiceWav)
$synth.Speak($script)
$synth.SetOutputToDefaultAudioDevice()
$synth.Dispose()

if (Test-Path $VoiceWav) {
    $wavSize = [Math]::Round((Get-Item $VoiceWav).Length / 1MB, 2)
    Write-Host "     WAV generated: $wavSize MB"
} else {
    Write-Error "WAV generation failed."
    exit 1
}

Write-Host ""
Write-Host "[3/4] Merging voiceover into MP4 with FFmpeg..."
Write-Host "     Input video : $VideoIn"
Write-Host "     Input audio : $VoiceWav"
Write-Host "     Output      : $VideoOut"

# -shortest: end when the shorter stream ends (video drives duration)
# -c:v copy  : no video re-encode (fast, no quality loss)
# -c:a aac   : encode WAV to AAC for MP4 container
# -b:a 192k  : high-quality audio bitrate
# -filter:a  : amplify audio slightly for good listening level
& $FFMPEG -y `
    -i $VideoIn `
    -i $VoiceWav `
    -map 0:v:0 `
    -map 1:a:0 `
    -c:v copy `
    -c:a aac `
    -b:a 192k `
    -af "volume=1.4" `
    -shortest `
    $VideoOut 2>&1

Write-Host ""
if (Test-Path $VideoOut) {
    $vf   = Get-Item $VideoOut
    $mb   = [Math]::Round($vf.Length / 1MB, 2)

    # Read duration via Shell COM
    $shell  = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace($WorkDir)
    $item   = $folder.ParseName("NutritionAI_IBM_Granite_WithVoice.mp4")
    $dur    = $folder.GetDetailsOf($item, 27)
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null

    Write-Host "[4/4] SUCCESS!"
    Write-Host "============================================================"
    Write-Host "  Output  : $VideoOut"
    Write-Host "  Size    : $mb MB"
    Write-Host "  Duration: $dur"
    Write-Host "  Voice   : $chosen (Windows SAPI TTS)"
    Write-Host "  Audio   : AAC 192kbps"
    Write-Host "  Video   : 1080p 30fps (original quality preserved)"
    Write-Host "============================================================"
} else {
    Write-Error "Output video not found — FFmpeg may have failed."
    exit 1
}
