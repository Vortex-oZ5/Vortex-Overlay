# ============================================================
#                    VORTEX OVERLAY
#                     INSTALLER
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

$DownloadUrl = "https://github.com/Vortex-oZ5/Vortex-Overlay/releases/latest/download/vortex-overlay.zip"

$InstallDir = Join-Path $env:LOCALAPPDATA "VortexOverlay"

$TempZip = Join-Path $env:TEMP "vortex-overlay.zip"

$CorrectKey = "VORTEX05Z"

$Green  = "Green"
$Cyan   = "Cyan"
$Yellow = "Yellow"
$Red    = "Red"
$White  = "White"
$Gray   = "Gray"


# ------------------------------------------------------------
# VORTEX BANNER
# ------------------------------------------------------------

Clear-Host

Write-Host ""

Write-Host "██╗   ██╗ ██████╗ ██████╗ ████████╗███████╗██╗  ██╗" -ForegroundColor $Green
Write-Host "██║   ██║██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝" -ForegroundColor $Green
Write-Host "██║   ██║██║   ██║██████╔╝   ██║   █████╗   ╚███╔╝ " -ForegroundColor $Green
Write-Host "╚██╗ ██╔╝██║   ██║██╔══██╗   ██║   ██╔══╝   ██╔██╗ " -ForegroundColor $Green
Write-Host " ╚████╔╝ ╚██████╔╝██║  ██║   ██║   ███████╗██╔╝ ██╗" -ForegroundColor $Green
Write-Host "  ╚═══╝   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝" -ForegroundColor $Green

Write-Host ""
Write-Host "                 VORTEX OVERLAY" -ForegroundColor $White
Write-Host ""

Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host "                    INSTALLER" -ForegroundColor $Green
Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host ""


# ------------------------------------------------------------
# ACCESS KEY
# ------------------------------------------------------------

$EnteredKey = Read-Host "Enter access key"

if ($EnteredKey -ne $CorrectKey) {

    Write-Host ""
    Write-Host "[X] INVALID ACCESS KEY" -ForegroundColor $Red
    Write-Host ""
    Read-Host "Press ENTER to close"

    return
}

Write-Host ""
Write-Host "[+] Access key accepted." -ForegroundColor $Green
Write-Host ""


# ------------------------------------------------------------
# PREPARE INSTALLATION
# ------------------------------------------------------------

Write-Host "Preparing installation..." -ForegroundColor $Cyan

if (Test-Path $InstallDir) {

    try {

        Remove-Item `
            -Path $InstallDir `
            -Recurse `
            -Force

        Write-Host "[+] Previous installation removed." -ForegroundColor $Green

    }
    catch {

        Write-Host ""
        Write-Host "[X] Could not remove previous installation." -ForegroundColor $Red
        Write-Host $_.Exception.Message -ForegroundColor $Red
        Write-Host ""

        Read-Host "Press ENTER to close"

        return
    }
}

New-Item `
    -ItemType Directory `
    -Path $InstallDir `
    -Force | Out-Null


# ------------------------------------------------------------
# REMOVE OLD ZIP
# ------------------------------------------------------------

if (Test-Path $TempZip) {

    Remove-Item `
        -Path $TempZip `
        -Force `
        -ErrorAction SilentlyContinue
}


# ------------------------------------------------------------
# DOWNLOAD
# ------------------------------------------------------------

Write-Host ""
Write-Host "Downloading Vortex Overlay..." -ForegroundColor $Cyan
Write-Host ""

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

        throw "GitHub returned HTTP $([int]$response.StatusCode) $($response.ReasonPhrase)"
    }

    $totalBytes = $response.Content.Headers.ContentLength

    $inputStream = $response.Content.ReadAsStreamAsync().Result

    $outputStream = [System.IO.File]::Create($TempZip)

    $buffer = New-Object byte[] 65536

    $totalRead = 0

    $lastPercent = -1

    while ($true) {

        $bytesRead = $inputStream.Read(
            $buffer,
            0,
            $buffer.Length
        )

        if ($bytesRead -le 0) {
            break
        }

        $outputStream.Write(
            $buffer,
            0,
            $bytesRead
        )

        $totalRead += $bytesRead

        if ($totalBytes) {

            $percent = [math]::Floor(
                ($totalRead / $totalBytes) * 100
            )

            if ($percent -ne $lastPercent) {

                $lastPercent = $percent

                $barLength = 40

                $filled = [math]::Floor(
                    ($percent / 100) * $barLength
                )

                $empty = $barLength - $filled

                $bar =
                    ("█" * $filled) +
                    ("░" * $empty)

                $mbDownloaded = [math]::Round(
                    $totalRead / 1MB,
                    1
                )

                $mbTotal = [math]::Round(
                    $totalBytes / 1MB,
                    1
                )

                Write-Host (
                    "`r  [$bar] $percent%  $mbDownloaded MB / $mbTotal MB"
                ) -NoNewline -ForegroundColor $Green
            }
        }
    }

    $outputStream.Close()
    $inputStream.Close()
    $response.Dispose()
    $client.Dispose()

    Write-Host ""
    Write-Host ""

    Write-Host "[+] Download completed." -ForegroundColor $Green

}
catch {

    Write-Host ""
    Write-Host ""
    Write-Host "[X] DOWNLOAD FAILED" -ForegroundColor $Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor $Red
    Write-Host ""

    if (Test-Path $TempZip) {

        Remove-Item `
            $TempZip `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Read-Host "Press ENTER to close"

    return
}


# ------------------------------------------------------------
# VERIFY ZIP
# ------------------------------------------------------------

Write-Host "Verifying downloaded package..." -ForegroundColor $Cyan

if (-not (Test-Path $TempZip)) {

    Write-Host ""
    Write-Host "[X] Downloaded ZIP was not found." -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    return
}

$zipSize = (Get-Item $TempZip).Length

if ($zipSize -lt 1024) {

    Write-Host ""
    Write-Host "[X] Downloaded file appears to be invalid." -ForegroundColor $Red
    Write-Host ""

    Remove-Item `
        $TempZip `
        -Force `
        -ErrorAction SilentlyContinue

    Read-Host "Press ENTER to close"

    return
}

Write-Host "[+] Package verified." -ForegroundColor $Green
Write-Host ""


# ------------------------------------------------------------
# EXTRACT
# ------------------------------------------------------------

Write-Host "Extracting Vortex Overlay..." -ForegroundColor $Cyan
Write-Host ""

try {

    Expand-Archive `
        -Path $TempZip `
        -DestinationPath $InstallDir `
        -Force

    Write-Host "[+] Extraction completed." -ForegroundColor $Green

}
catch {

    Write-Host ""
    Write-Host "[X] EXTRACTION FAILED" -ForegroundColor $Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor $Yellow
    Write-Host $_.Exception.Message -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    return
}


# ------------------------------------------------------------
# DELETE ZIP
# ------------------------------------------------------------

Write-Host ""
Write-Host "Cleaning temporary files..." -ForegroundColor $Cyan

try {

    Remove-Item `
        -Path $TempZip `
        -Force

    Write-Host "[+] ZIP file deleted." -ForegroundColor $Green

}
catch {

    Write-Host "[!] Could not delete temporary ZIP." -ForegroundColor $Yellow
}


# ------------------------------------------------------------
# VERIFY INSTALLATION
# ------------------------------------------------------------

Write-Host ""
Write-Host "Checking installation..." -ForegroundColor $Cyan

$files = Get-ChildItem `
    -Path $InstallDir `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue

if (-not $files) {

    Write-Host ""
    Write-Host "[X] No files were found after extraction." -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    return
}

Write-Host "[+] Installation files verified." -ForegroundColor $Green


# ------------------------------------------------------------
# ALL DONE ASCII BANNER
# ------------------------------------------------------------

Start-Sleep -Milliseconds 700

Clear-Host

Write-Host ""

Write-Host " █████╗ ██╗     ██╗          ██████╗  ██████╗ ███╗   ██╗███████╗" -ForegroundColor $Green
Write-Host "██╔══██╗██║     ██║         ██╔═══██╗██╔═══██╗████╗  ██║██╔════╝" -ForegroundColor $Green
Write-Host "███████║██║     ██║         ██║   ██║██║   ██║██╔██╗ ██║█████╗  " -ForegroundColor $Green
Write-Host "██╔══██║██║     ██║         ██║   ██║██║   ██║██║╚██╗██║██╔══╝  " -ForegroundColor $Green
Write-Host "██║  ██║███████╗███████╗    ╚██████╔╝╚██████╔╝██║ ╚████║███████╗" -ForegroundColor $Green
Write-Host "╚═╝  ╚═╝╚══════╝╚══════╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝" -ForegroundColor $Green

Write-Host ""

Write-Host "                 GOOD TO GO....." -ForegroundColor $White

Write-Host ""

Write-Host "================================================" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "        Vortex Overlay installed successfully." -ForegroundColor $Green
Write-Host ""
Write-Host "        Location:" -ForegroundColor $Gray
Write-Host "        $InstallDir" -ForegroundColor $White
Write-Host ""
Write-Host "        ZIP file automatically deleted." -ForegroundColor $Gray
Write-Host ""
Write-Host "================================================" -ForegroundColor DarkGreen

Write-Host ""


# ------------------------------------------------------------
# FINISH
# ------------------------------------------------------------

Read-Host "Press ENTER to close"
