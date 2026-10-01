$ErrorActionPreference = "Stop"

$DownloadUrl = "https://github.com/Vortex-oZ5/Vortex-Overlay/releases/latest/download/vortex-overlay.zip"
$InstallDir = "$env:LOCALAPPDATA\VortexOverlay"
$TempZip = "$env:TEMP\vortex-overlay.zip"
$CorrectKey = "VORTEX05Z"

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
Write-Host "              INSTALLER" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor DarkGreen
Write-Host ""

# KEY
$EnteredKey = Read-Host "Enter access key"

if ($EnteredKey -ne $CorrectKey) {
    Write-Host ""
    Write-Host "[X] Invalid access key." -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host ""
Write-Host "[+] Access key accepted." -ForegroundColor Green
Write-Host ""

# DOWNLOAD
Write-Host "Downloading Vortex Overlay..." -ForegroundColor Cyan
Write-Host ""

try {

    if (Test-Path $TempZip) {
        Remove-Item $TempZip -Force
    }

    # Download using Invoke-WebRequest
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri $DownloadUrl `
        -OutFile $TempZip

    Write-Host ""
    Write-Host "[+] Download completed." -ForegroundColor Green

}
catch {

    Write-Host ""
    Write-Host "[X] DOWNLOAD FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""

    Read-Host "Press ENTER to exit"
    exit 1
}

# VERIFY ZIP
if (-not (Test-Path $TempZip)) {

    Write-Host ""
    Write-Host "[X] Downloaded ZIP was not found." -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}

# INSTALL DIRECTORY
Write-Host ""
Write-Host "Preparing installation..." -ForegroundColor Cyan

try {

    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force
    }

    New-Item `
        -ItemType Directory `
        -Path $InstallDir `
        -Force | Out-Null

}
catch {

    Write-Host ""
    Write-Host "[X] Could not create installation directory." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}

# EXTRACT
Write-Host ""
Write-Host "Extracting Vortex Overlay..." -ForegroundColor Cyan

try {

    Expand-Archive `
        -Path $TempZip `
        -DestinationPath $InstallDir `
        -Force

    Write-Host "[+] Extraction completed." -ForegroundColor Green

}
catch {

    Write-Host ""
    Write-Host "[X] EXTRACTION FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Read-Host "Press ENTER to exit"
    exit 1
}

# DELETE ZIP
Write-Host ""
Write-Host "Cleaning temporary files..." -ForegroundColor Cyan

try {

    Remove-Item $TempZip -Force

    Write-Host "[+] Temporary ZIP deleted." -ForegroundColor Green

}
catch {

    Write-Host "[!] Could not delete temporary ZIP." -ForegroundColor Yellow
}

# FIND EXE
Write-Host ""
Write-Host "Checking application..." -ForegroundColor Cyan

$Exe = Join-Path $InstallDir "VortexOverlay.exe"

if (Test-Path $Exe) {

    Write-Host "[+] Vortex Overlay found." -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "[!] VortexOverlay.exe was not found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installed files are located at:"
    Write-Host $InstallDir
    Write-Host ""

    Read-Host "Press ENTER to exit"
    exit 1
}

# COMPLETE
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "       INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Location:"
Write-Host $InstallDir -ForegroundColor Gray

Write-Host ""
Write-Host "Starting Vortex Overlay..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

Start-Process $Exe

Write-Host ""
Write-Host "Vortex Overlay started." -ForegroundColor Green
