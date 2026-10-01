# ============================================================
#                    VORTEX OVERLAY
#                       INSTALLER
# ============================================================

$ErrorActionPreference = "Stop"

# ========================= CONFIGURATION ======================

$DownloadUrl = "https://github.com/Vortex-oZ5/Vortex-Overlay/releases/latest/download/vortex-overlay.zip"
$CorrectKey = "VORTEX05Z"

$DefaultInstallDir = Join-Path $env:LOCALAPPDATA "VortexOverlay"

$TempZip   = Join-Path $env:TEMP "vortex-overlay.zip"
$TempSteps = Join-Path $env:TEMP "vortex-steps-to-run"

$StepsUrl = "https://raw.githubusercontent.com/Vortex-oZ5/Vortex-Overlay/main/steps%20to%20run"

$Red    = [ConsoleColor]::Red
$White  = [ConsoleColor]::White
$Gray   = [ConsoleColor]::DarkGray
$Yellow = [ConsoleColor]::Yellow

# ========================= CONSOLE ============================

try {
    $Host.UI.RawUI.WindowTitle = "VORTEX OVERLAY INSTALLER"
    $Host.UI.RawUI.ForegroundColor = $White
} catch {}

# ========================= ANIMATION ==========================

$VortexX  = 4
$VortexY  = 8
$VortexDX = 1
$VortexDY = 1

function Reset-VortexAnimation {
    $script:VortexX  = 4
    $script:VortexY  = 8
    $script:VortexDX = 1
    $script:VortexDY = 1
}

function Draw-VortexFrame {
    param(
        [string]$Title = "VORTEX",
        [string]$Status = "",
        [int]$Percent = -1
    )

    try {
        $w = [Console]::WindowWidth
        $h = [Console]::WindowHeight

        if ($w -lt 60 -or $h -lt 20) {
            return
        }

        $script:VortexX += $script:VortexDX
        $script:VortexY += $script:VortexDY

        $maxX = [Math]::Max(4, $w - 12)
        $maxY = [Math]::Max(7, $h - 7)

        if ($script:VortexX -le 2) {
            $script:VortexX = 2
            $script:VortexDX = 1
        }
        elseif ($script:VortexX -ge $maxX) {
            $script:VortexX = $maxX
            $script:VortexDX = -1
        }

        if ($script:VortexY -le 6) {
            $script:VortexY = 6
            $script:VortexDY = 1
        }
        elseif ($script:VortexY -ge $maxY) {
            $script:VortexY = $maxY
            $script:VortexDY = -1
        }

        [Console]::SetCursorPosition(0,0)

        $blank = " " * ($w - 1)

        # Header
        Write-Host $blank -NoNewline
        [Console]::SetCursorPosition(0,0)
        Write-Host " VORTEX OVERLAY INSTALLER".PadRight($w-1) -ForegroundColor $Red
        Write-Host " ─────────────────────────────────────────────────────────────".PadRight($w-1) -ForegroundColor $White

        # Animation area
        for ($i = 2; $i -lt $h - 6; $i++) {
            Write-Host $blank -NoNewline
            Write-Host ""
        }

        # Status area
        [Console]::SetCursorPosition(0, $h - 6)
        Write-Host " ─────────────────────────────────────────────────────────────".PadRight($w-1) -ForegroundColor $Red
        Write-Host ("  " + $Title).PadRight($w-1) -ForegroundColor $White

        if ($Percent -ge 0) {
            $barWidth = [Math]::Min(48, $w - 22)
            $filled = [Math]::Floor(($Percent / 100) * $barWidth)
            $empty = $barWidth - $filled
            $bar = ("█" * $filled) + ("░" * $empty)

            Write-Host ("  [" + $bar + "] " + $Percent + "%").PadRight($w-1) -ForegroundColor $Red
        }
        else {
            Write-Host ("  " + $Status).PadRight($w-1) -ForegroundColor $White
        }

        Write-Host " ─────────────────────────────────────────────────────────────".PadRight($w-1) -ForegroundColor $Red

        # Moving VORTEX
        $safeX = [Math]::Min([Math]::Max($script:VortexX,0), $w-7)
        $safeY = [Math]::Min([Math]::Max($script:VortexY,2), $h-7)

        [Console]::SetCursorPosition($safeX, $safeY)
        Write-Host "VORTEX" -NoNewline -ForegroundColor $Red

        [Console]::SetCursorPosition(0, $h-1)
    }
    catch {}
}

function Show-Spinner {
    param([string]$Message,[int]$Seconds=1)

    $frames = @("|","/","-","\")
    $end = (Get-Date).AddSeconds($Seconds)
    $i = 0

    while ((Get-Date) -lt $end) {
        Write-Host "`r  $($frames[$i]) $Message" -NoNewline -ForegroundColor $Red
        $i = ($i + 1) % $frames.Count
        Start-Sleep -Milliseconds 80
    }

    Write-Host "`r  [✓] $Message".PadRight(70) -ForegroundColor $White
}

function Show-VortexBanner {
    Clear-Host

    Write-Host ""
    Write-Host "██╗   ██╗ ██████╗ ██████╗ ████████╗███████╗██╗  ██╗" -ForegroundColor $Red
    Write-Host "██║   ██║██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝" -ForegroundColor $Red
    Write-Host "██║   ██║██║   ██║██████╔╝   ██║   █████╗   ╚███╔╝ " -ForegroundColor $Red
    Write-Host "╚██╗ ██╔╝██║   ██║██╔══██╗   ██║   ██╔══╝   ██╔██╗ " -ForegroundColor $Red
    Write-Host " ╚████╔╝ ╚██████╔╝██║  ██║   ██║   ███████╗██╔╝ ██╗" -ForegroundColor $Red
    Write-Host "  ╚═══╝   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝" -ForegroundColor $Red
    Write-Host ""
    Write-Host "                 VORTEX OVERLAY" -ForegroundColor $White
    Write-Host "                  RED EDITION" -ForegroundColor $Red
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red
    Write-Host "                    INSTALLER" -ForegroundColor $White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red
    Write-Host ""
}

function Stop-WithError {
    param([string]$Message)

    Write-Host ""
    Write-Host "  [X] $Message" -ForegroundColor $Red
    Write-Host ""
    Read-Host "Press ENTER to close"
    exit 1
}

# ========================= START ==============================

Show-VortexBanner
Show-Spinner "Preparing installation environment" 1

# ========================= ACCESS KEY =========================

Write-Host ""
Write-Host "  ACCESS REQUIRED" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""

$EnteredKey = Read-Host "  Enter access key"

if ($EnteredKey -ne $CorrectKey) {
    Write-Host ""
    Write-Host "  [X] INVALID ACCESS KEY" -ForegroundColor $Red
    Write-Host "  Access denied." -ForegroundColor $White
    Write-Host ""
    Read-Host "Press ENTER to close"
    exit 1
}

Write-Host ""
Write-Host "  [✓] ACCESS GRANTED" -ForegroundColor $Red
Show-Spinner "Authenticating VORTEX" 1

# ========================= INSTALL PATH =======================

Write-Host ""
Write-Host "  INSTALLATION LOCATION" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""
Write-Host "  Default location:" -ForegroundColor $Gray
Write-Host "  $DefaultInstallDir" -ForegroundColor $White
Write-Host ""

$InstallInput = Read-Host "  Enter installation path (ENTER = default)"

if ([string]::IsNullOrWhiteSpace($InstallInput)) {
    $InstallDir = $DefaultInstallDir
}
else {
    $InstallDir = $InstallInput.Trim().Trim('"')
}

Write-Host ""
Write-Host "  Selected location:" -ForegroundColor $Gray
Write-Host "  $InstallDir" -ForegroundColor $White
Write-Host ""

# ========================= PREPARE =============================

try {
    if (Test-Path $InstallDir) {
        Write-Host "  Existing installation detected." -ForegroundColor $Red
        Show-Spinner "Removing previous installation" 1

        Remove-Item $InstallDir -Recurse -Force -ErrorAction Stop
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Host "  [✓] Installation directory ready." -ForegroundColor $Red
}
catch {
    Stop-WithError "Could not prepare the installation directory."
}

# ========================= TEMP CLEANUP ========================

foreach ($file in @($TempZip,$TempSteps)) {
    if (Test-Path $file) {
        Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
}

# ========================= NOTICE ==============================

try {
    Add-Type -AssemblyName PresentationFramework

    $Message = @"
WELCOME TO VORTEX OVERLAY

Vortex Overlay is about to be downloaded
and installed on this computer.

Installation location:

$InstallDir

Only continue if you trust this software
and its source.

Click OK to begin.
"@

    $result = [System.Windows.MessageBox]::Show(
        $Message,
        "VORTEX OVERLAY",
        [System.Windows.MessageBoxButton]::OKCancel,
        [System.Windows.MessageBoxImage]::Information
    )

    if ($result -ne [System.Windows.MessageBoxResult]::OK) {
        Write-Host ""
        Write-Host "  Installation cancelled." -ForegroundColor $Red
        Read-Host "Press ENTER to close"
        exit
    }
}
catch {
    Write-Host "  Popup unavailable. Continuing..." -ForegroundColor $Yellow
}

# ========================= DOWNLOAD ============================

Clear-Host
Reset-VortexAnimation

try {
    Add-Type -AssemblyName System.Net.Http

    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.AllowAutoRedirect = $true

    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromMinutes(30)

    $response = $client.GetAsync(
        $DownloadUrl,
        [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
    ).Result

    if (-not $response.IsSuccessStatusCode) {
        throw "HTTP $([int]$response.StatusCode)"
    }

    $totalBytes = $response.Content.Headers.ContentLength
    $inputStream = $response.Content.ReadAsStreamAsync().Result
    $outputStream = [System.IO.File]::Create($TempZip)

    $buffer = New-Object byte[] 65536
    $totalRead = 0
    $lastPercent = -1

    while ($true) {
        $bytesRead = $inputStream.Read($buffer,0,$buffer.Length)

        if ($bytesRead -le 0) {
            break
        }

        $outputStream.Write($buffer,0,$bytesRead)
        $totalRead += $bytesRead

        if ($totalBytes) {
            $percent = [Math]::Floor(($totalRead / $totalBytes) * 100)

            if ($percent -ne $lastPercent) {
                $lastPercent = $percent
                Draw-VortexFrame "DOWNLOADING VORTEX OVERLAY" "" $percent
            }
        }
        else {
            Draw-VortexFrame "DOWNLOADING VORTEX OVERLAY" "Downloading..." -1
        }

        Start-Sleep -Milliseconds 12
    }

    $outputStream.Close()
    $inputStream.Close()
    $response.Dispose()
    $client.Dispose()

    Start-Sleep -Milliseconds 250

    Write-Host ""
    Write-Host "  [✓] DOWNLOAD COMPLETE" -ForegroundColor $Red
}
catch {
    try { $outputStream.Close() } catch {}
    try { $inputStream.Close() } catch {}
    try { $client.Dispose() } catch {}

    if (Test-Path $TempZip) {
        Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
    }

    Stop-WithError "Download failed. Check your internet connection or download source."
}

# ========================= STEPS FILE ==========================

Clear-Host
Reset-VortexAnimation

try {
    Invoke-WebRequest `
        -Uri $StepsUrl `
        -OutFile $TempSteps `
        -UseBasicParsing `
        -ErrorAction Stop

    if (-not (Test-Path $TempSteps)) {
        throw "File was not created."
    }

    Draw-VortexFrame "INSTALLATION INSTRUCTIONS" "Steps downloaded." -1
    Start-Sleep -Milliseconds 500

    Write-Host ""
    Write-Host "  [✓] STEPS TO RUN DOWNLOADED" -ForegroundColor $Red
}
catch {
    Write-Host ""
    Write-Host "  [!] Could not download 'steps to run'." -ForegroundColor $Yellow
    Write-Host "      Main installation will continue." -ForegroundColor $White
}

# ========================= VERIFY ZIP ==========================

Write-Host ""
Show-Spinner "Verifying VORTEX package" 1

if (-not (Test-Path $TempZip)) {
    Stop-WithError "Downloaded ZIP was not found."
}

if ((Get-Item $TempZip).Length -lt 1024) {
    Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
    Stop-WithError "Downloaded package appears to be invalid."
}

Write-Host "  [✓] PACKAGE VERIFIED" -ForegroundColor $Red

# ========================= EXTRACTION ==========================

Clear-Host
Reset-VortexAnimation

try {
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $archive = [System.IO.Compression.ZipFile]::OpenRead($TempZip)
    $entries = $archive.Entries

    $fileEntries = @(
        $entries | Where-Object {
            -not [string]::IsNullOrEmpty($_.Name)
        }
    )

    $totalFiles = $fileEntries.Count

    if ($totalFiles -eq 0) {
        throw "The ZIP archive contains no files."
    }

    $currentFile = 0
    $installRoot = [System.IO.Path]::GetFullPath($InstallDir)

    foreach ($entry in $entries) {

        if ([string]::IsNullOrEmpty($entry.Name)) {
            continue
        }

        $relativePath = $entry.FullName.Replace("/","\")
        $destination = [System.IO.Path]::GetFullPath(
            (Join-Path $InstallDir $relativePath)
        )

        if (-not $destination.StartsWith(
            $installRoot,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            throw "Unsafe path detected in archive."
        }

        $parent = Split-Path $destination -Parent

        if ($parent) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
            $entry,
            $destination,
            $true
        )

        $currentFile++

        $percent = [Math]::Floor(
            ($currentFile / $totalFiles) * 100
        )

        Draw-VortexFrame `
            "EXTRACTING VORTEX OVERLAY" `
            $entry.Name `
            $percent

        Start-Sleep -Milliseconds 18
    }

    $archive.Dispose()

    Start-Sleep -Milliseconds 300

    Write-Host ""
    Write-Host "  [✓] EXTRACTION COMPLETE" -ForegroundColor $Red
}
catch {
    try { $archive.Dispose() } catch {}

    if (Test-Path $TempZip) {
        Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path $TempSteps) {
        Remove-Item $TempSteps -Force -ErrorAction SilentlyContinue
    }

    Stop-WithError "Extraction failed: $($_.Exception.Message)"
}

# ========================= INSTALL STEPS =======================

Write-Host ""
Write-Host "  INSTALLING SETUP INSTRUCTIONS" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""

if (Test-Path $TempSteps) {
    try {
        $InstalledSteps = Join-Path $InstallDir "steps to run"

        for ($i=0; $i -le 100; $i += 10) {
            Draw-VortexFrame `
                "INSTALLING SETUP INSTRUCTIONS" `
                "steps to run" `
                $i

            Start-Sleep -Milliseconds 45
        }

        Copy-Item `
            -Path $TempSteps `
            -Destination $InstalledSteps `
            -Force `
            -ErrorAction Stop

        Write-Host ""
        Write-Host "  [✓] STEPS TO RUN INSTALLED" -ForegroundColor $Red
    }
    catch {
        Write-Host ""
        Write-Host "  [!] Could not install 'steps to run'." -ForegroundColor $Yellow
    }
}
else {
    Write-Host "  [!] STEPS TO RUN WAS NOT INSTALLED" -ForegroundColor $Yellow
}

# ========================= CLEANUP ============================

Write-Host ""
Show-Spinner "Cleaning temporary files" 1

if (Test-Path $TempZip) {
    try {
        Remove-Item $TempZip -Force -ErrorAction Stop
        Write-Host "  [✓] ZIP AUTOMATICALLY DELETED" -ForegroundColor $Red
    }
    catch {
        Write-Host "  [!] ZIP could not be deleted." -ForegroundColor $Yellow
    }
}

if (Test-Path $TempSteps) {
    Remove-Item $TempSteps -Force -ErrorAction SilentlyContinue
}

# ========================= VERIFY ==============================

Write-Host ""
Show-Spinner "Finalizing installation" 1

$InstalledFiles = Get-ChildItem `
    -Path $InstallDir `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue

if (-not $InstalledFiles) {
    Stop-WithError "No files were found after extraction."
}

# ========================= FINAL SCREEN ========================

Clear-Host

Write-Host ""
Write-Host ""

Write-Host "              V O R T E X" -ForegroundColor $Red
Write-Host ""

$FinalFrames = @(
    "[■□□□□□□□□□]",
    "[■■□□□□□□□□]",
    "[■■■□□□□□□□]",
    "[■■■■□□□□□□]",
    "[■■■■■□□□□□]",
    "[■■■■■■□□□□]",
    "[■■■■■■■□□□]",
    "[■■■■■■■■□□]",
    "[■■■■■■■■■□]",
    "[■■■■■■■■■■]"
)

foreach ($frame in $FinalFrames) {
    Write-Host "`r              $frame" -NoNewline -ForegroundColor $Red
    Start-Sleep -Milliseconds 70
}

Write-Host ""
Write-Host ""

Write-Host " █████╗ ██╗     ██╗          ██████╗  ██████╗ ███╗   ██╗███████╗" -ForegroundColor $Red
Write-Host "██╔══██╗██║     ██║         ██╔═══██╗██╔═══██╗████╗  ██║██╔════╝" -ForegroundColor $Red
Write-Host "███████║██║     ██║         ██║   ██║██║   ██║██╔██╗ ██║█████╗  " -ForegroundColor $Red
Write-Host "██╔══██║██║     ██║         ██║   ██║██║   ██║██║╚██╗██║██╔══╝  " -ForegroundColor $Red
Write-Host "██║  ██║███████╗███████╗    ╚██████╔╝╚██████╔╝██║ ╚████║███████╗" -ForegroundColor $Red
Write-Host "╚═╝  ╚═╝╚══════╝╚══════╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝" -ForegroundColor $Red

Write-Host ""
Write-Host "                 GOOD TO GO....." -ForegroundColor $White
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red
Write-Host ""
Write-Host "       VORTEX OVERLAY INSTALLED SUCCESSFULLY" -ForegroundColor $White
Write-Host ""
Write-Host "       Location:" -ForegroundColor $Gray
Write-Host "       $InstallDir" -ForegroundColor $White
Write-Host ""
Write-Host "       ZIP automatically deleted." -ForegroundColor $Gray
Write-Host "       Installation instructions installed." -ForegroundColor $Gray
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red
Write-Host ""

Read-Host "Press ENTER to close"
