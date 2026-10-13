# ============================================================
#  Nutrition Agentic AI — Export PPT to MP4 (150 seconds)
#  17 slides x ~8.82 seconds each = 150.0 seconds total
# ============================================================

param(
    [string]$PptxPath = "C:\Users\STUDENT\Desktop\IBM_Workshop\NutritionAI_IBM_Granite.pptx",
    [string]$VideoPath = "C:\Users\STUDENT\Desktop\IBM_Workshop\NutritionAI_IBM_Granite_150s.mp4"
)

Write-Host "============================================================"
Write-Host "  Nutrition Agentic AI — PPT to MP4 Export"
Write-Host "  17 slides x 8.82s = 150 seconds"
Write-Host "============================================================"
Write-Host ""

# ── 1. Validate input file ────────────────────────────────────
if (-not (Test-Path $PptxPath)) {
    Write-Error "PPTX not found: $PptxPath"
    exit 1
}

Write-Host "[1/5] Opening PowerPoint COM object..."
$pptApp = New-Object -ComObject PowerPoint.Application
$pptApp.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue

Write-Host "[2/5] Loading presentation: $PptxPath"
$presentation = $pptApp.Presentations.Open($PptxPath, $false, $false, $true)

$slideCount = $presentation.Slides.Count
Write-Host "      Found $slideCount slides."

# ── 2. Set timing: 150 sec / 17 slides = ~8.82 sec per slide ─
$totalSeconds = 150
$secondsPerSlide = [Math]::Round($totalSeconds / $slideCount, 2)
Write-Host "[3/5] Setting slide timings: $secondsPerSlide sec per slide..."

foreach ($slide in $presentation.Slides) {
    # Enable auto-advance with timing
    $slide.SlideShowTransition.AdvanceOnTime = [Microsoft.Office.Core.MsoTriState]::msoTrue
    $slide.SlideShowTransition.AdvanceOnClick = [Microsoft.Office.Core.MsoTriState]::msoFalse
    $slide.SlideShowTransition.AdvanceTime = $secondsPerSlide
    # Smooth fade transition for professional look
    $slide.SlideShowTransition.EntryEffect = 3073   # ppEffectFade = 3073
    $slide.SlideShowTransition.Speed = 2            # ppTransitionSpeedMedium = 2
}

Write-Host "      Timings set: $secondsPerSlide sec x $slideCount slides = $($secondsPerSlide * $slideCount) sec"

# ── 3. Save the timed version ─────────────────────────────────
Write-Host "[4/5] Saving timed presentation..."
$presentation.Save()

# ── 4. Export to MP4 ──────────────────────────────────────────
Write-Host "[5/5] Exporting to MP4: $VideoPath"
Write-Host "      (This may take 1-3 minutes — please wait...)"

# ppSaveAsMP4 = 39
# Quality: 2 = ppFixedFormatIntentPrint (1080p); 1 = screen quality
$presentation.CreateVideo(
    $VideoPath,   # FileName
    $true,        # UseTimingsAndNarrations
    $secondsPerSlide,  # DefaultSlideDuration (fallback)
    1080,         # VertResolution (1080p HD)
    30,           # FramesPerSecond
    85            # Quality (85%)
)

Write-Host ""
Write-Host "      Export started. Waiting for PowerPoint to finish rendering..."

# Wait for file to appear and stabilize
$maxWait = 180  # seconds
$waited = 0
$lastSize = 0

do {
    Start-Sleep -Seconds 5
    $waited += 5
    if (Test-Path $VideoPath) {
        $currentSize = (Get-Item $VideoPath).Length
        Write-Host "      Progress: ${waited}s elapsed, file size: $([Math]::Round($currentSize/1MB,1)) MB"
        if ($currentSize -gt 0 -and $currentSize -eq $lastSize) {
            Write-Host "      File size stabilized — export complete!"
            break
        }
        $lastSize = $currentSize
    } else {
        Write-Host "      Waiting for export to begin... (${waited}s)"
    }
} while ($waited -lt $maxWait)

# ── 5. Close and report ───────────────────────────────────────
$presentation.Close()
$pptApp.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($pptApp) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host ""
if (Test-Path $VideoPath) {
    $videoFile = Get-Item $VideoPath
    $sizeMB = [Math]::Round($videoFile.Length / 1MB, 2)
    Write-Host "============================================================"
    Write-Host "  SUCCESS!"
    Write-Host "  Video : $VideoPath"
    Write-Host "  Size  : $sizeMB MB"
    Write-Host "  Duration (target): 150 seconds"
    Write-Host "============================================================"
} else {
    Write-Host "============================================================"
    Write-Host "  NOTE: PowerPoint may still be rendering in the background."
    Write-Host "  Check: $VideoPath"
    Write-Host "  It can take up to 3 minutes for the file to appear."
    Write-Host "============================================================"
}
