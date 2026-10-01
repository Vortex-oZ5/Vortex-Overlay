$ErrorActionPreference = "Stop"

# ==========================================
# VORTEX OVERLAY INSTALLER
# ==========================================

$DownloadUrl = "https://github.com/DarkVortex0z/Vortex-Overlay/releases/latest/download/vortex-overlay.zip"

$InstallDir = "$env:LOCALAPPDATA\VortexOverlay"

$TempZip = "$env:TEMP\vortex-overlay.zip"

$CorrectKey = "VORTEX05Z"


# ==========================================
# BANNER
# ==========================================

Clear-Host

Write-Host ""

Write-Host "██╗   ██╗ ██████╗ ██████╗ ████████╗███████╗██╗  ██╗" -ForegroundColor Green
Write-Host "██║   ██║██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝" -ForegroundColor Green
Write-Host "██║   ██║██║   ██║██████╔╝   ██║   █████╗   ╚███╔╝ " -ForegroundColor Green
Write-Host "╚██╗ ██╔╝██║   ██║██╔══██╗   ██║   ██╔══╝   ██╔██╗ " -ForegroundColor Green
Write-Host " ╚████╔╝ ╚██████╔╝██║  ██║   ██║   ███████╗██╔╝ ██╗" -ForegroundColor Green
Write-Host "  ╚═══╝   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝" -ForegroundColor Green

Write-Host ""
Write-Host "                 VORTEX OVERLAY" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor DarkGreen
Write-Host "             INSTALLER" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor DarkGreen
Write-Host ""


# ==========================================
# ACCESS KEY
# ==========================================

$EnteredKey = Read-Host "Enter access key"

if ($EnteredKey -ne $CorrectKey) {

    Write-Host ""
    Write-Host "[X] Invalid access key." -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    Write-Host ""

    exit 1
}

Write-Host ""
Write-Host "[+] Access key accepted." -ForegroundColor Green
Write-Host ""


# ==========================================
# PREPARE INSTALLATION
# ==========================================

if (Test-Path $InstallDir) {

    Write-Host "Removing previous installation..." -ForegroundColor Yellow

    Remove-Item `
        $InstallDir `
        -Recurse `
        -Force
}

New-Item `
    -ItemType Directory `
    -Path $InstallDir `
    -Force | Out-Null


# ==========================================
# DOWNLOAD
# ==========================================

Write-Host "Downloading Vortex Overlay..." -ForegroundColor Cyan
Write-Host ""

try {

    $webClient = New-Object System.Net.WebClient

    $script:DownloadPercent = 0

    Register-ObjectEvent `
        -InputObject $webClient `
        -EventName DownloadProgressChanged `
        -Action {

            $script:DownloadPercent = $EventArgs.ProgressPercentage

        } | Out-Null


    $webClient.DownloadFileAsync(
        [System.Uri]$DownloadUrl,
        $TempZip
    )


    $frames = @(
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏"
    )

    $frameIndex = 0


    while ($webClient.IsBusy) {

        $spinner = $frames[$frameIndex % $frames.Count]

        $percent = $script:DownloadPercent

        $barLength = 30

        $filled = [math]::Floor(
            ($percent / 100) * $barLength
        )

        $empty = $barLength - $filled

        $bar =
            ("█" * $filled) +
            ("░" * $empty)

        Write-Host `
            "`r  $spinner [$bar] $percent%" `
            -NoNewline `
            -ForegroundColor Green

        $frameIndex++

        Start-Sleep -Milliseconds 100
    }

    Write-Host ""

    $webClient.Dispose()

    Write-Host ""
    Write-Host "[+] Download completed." -ForegroundColor Green

}
catch {

    Write-Host ""
    Write-Host "[X] Download failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    if (Test-Path $TempZip) {
        Remove-Item $TempZip -Force
    }

    exit 1
}


# ==========================================
# EXTRACTION
# ==========================================

Write-Host ""
Write-Host "Extracting Vortex Overlay..." -ForegroundColor Cyan
Write-Host ""

try {

    Expand-Archive `
        -Path $TempZip `
        -DestinationPath $InstallDir `
        -Force

    Write-Host "[+] Extraction completed." -ForegroundColor Green

}
catch {

    Write-Host ""
    Write-Host "[X] Extraction failed." -ForegroundColor Red

    exit 1
}


# ==========================================
# DELETE ZIP
# ==========================================

Write-Host ""
Write-Host "Cleaning temporary files..." -ForegroundColor Cyan

if (Test-Path $TempZip) {

    Remove-Item `
        $TempZip `
        -Force
}

Write-Host "[+] Temporary ZIP deleted." -ForegroundColor Green


# ==========================================
# APPLICATION
# ==========================================

$Exe = Join-Path `
    $InstallDir `
    "VortexOverlay.exe"


# ==========================================
# COMPLETE
# ==========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "       INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installed location:" -ForegroundColor White
Write-Host $InstallDir -ForegroundColor Gray
Write-Host ""

if (Test-Path $Exe) {

    Write-Host "Starting Vortex Overlay..." -ForegroundColor Cyan

    Start-Sleep -Seconds 2

    Start-Process $Exe

}
else {

    Write-Host "[!] VortexOverlay.exe was not found." -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Expected executable:"
    Write-Host $Exe -ForegroundColor Gray
}

Write-Host ""
