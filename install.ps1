# ============================================================
#                    VORTEX OVERLAY
#                     
#                       INSTALLER
# ============================================================

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$DownloadUrl = "https://github.com/Vortex-oZ5/Vortex-Overlay/releases/latest/download/vortex-overlay.zip"

$CorrectKey = "VORTEX05Z"

$DefaultInstallDir = Join-Path $env:LOCALAPPDATA "VortexOverlay"

$TempZip = Join-Path $env:TEMP "vortex-overlay.zip"

# RED + WHITE THEME
$Red    = "Red"
$DarkRed = "DarkRed"
$White  = "White"
$Gray   = "DarkGray"
$Green  = "Green"
$Yellow = "Yellow"


# ============================================================
# CONSOLE SETUP
# ============================================================

try {
    $Host.UI.RawUI.WindowTitle = "VORTEX OVERLAY INSTALLER"
}
catch {}

try {
    $Host.UI.RawUI.ForegroundColor = "White"
}
catch {}


# ============================================================
# HELPER - TYPE EFFECT
# ============================================================

function Write-TypeEffect {
    param(
        [string]$Text,
        [ConsoleColor]$Color = "White",
        [int]$Delay = 12
    )

    foreach ($Character in $Text.ToCharArray()) {

        Write-Host $Character -NoNewline -ForegroundColor $Color

        Start-Sleep -Milliseconds $Delay
    }

    Write-Host ""
}


# ============================================================
# HELPER - SPINNER
# ============================================================

function Show-Spinner {
    param(
        [string]$Message,
        [int]$Seconds = 2
    )

    $Frames = @(
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

    $EndTime = (Get-Date).AddSeconds($Seconds)

    $Index = 0

    while ((Get-Date) -lt $EndTime) {

        Write-Host "`r  $($Frames[$Index]) $Message" `
            -NoNewline `
            -ForegroundColor $Red

        $Index++

        if ($Index -ge $Frames.Count) {
            $Index = 0
        }

        Start-Sleep -Milliseconds 80
    }

    Write-Host "`r  [✓] $Message" -ForegroundColor $White
}


# ============================================================
# VORTEX BANNER
# ============================================================

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
    Write-Host "                  INSTALLER" -ForegroundColor $White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red

    Write-Host ""
}


# ============================================================
# ERROR FUNCTION
# ============================================================

function Show-ErrorAndExit {
    param(
        [string]$Message
    )

    Write-Host ""
    Write-Host "  [X] $Message" -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}


# ============================================================
# START
# ============================================================

Show-VortexBanner

Start-Sleep -Milliseconds 400

Write-TypeEffect `
    "  Initializing VORTEX installer..." `
    $White `
    15

Show-Spinner `
    "Preparing installation environment" `
    1


# ============================================================
# ACCESS KEY
# ============================================================

Write-Host ""

Write-Host "  ACCESS REQUIRED" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""

$EnteredKey = Read-Host "  Enter access key"

if ($EnteredKey -ne $CorrectKey) {

    Write-Host ""
    Write-Host "  [X] INVALID ACCESS KEY" -ForegroundColor $Red
    Write-Host ""
    Write-Host "  Access denied." -ForegroundColor $White
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}

Write-Host ""
Write-Host "  [✓] ACCESS GRANTED" -ForegroundColor $Red
Write-Host ""

Show-Spinner `
    "Authenticating VORTEX" `
    1


# ============================================================
# INSTALLATION LOCATION
# ============================================================

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


# ============================================================
# PREPARE DIRECTORY
# ============================================================

try {

    if (Test-Path $InstallDir) {

        Write-Host "  Existing installation detected." -ForegroundColor $Red

        Show-Spinner `
            "Removing previous installation" `
            1

        Remove-Item `
            -Path $InstallDir `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }

    New-Item `
        -ItemType Directory `
        -Path $InstallDir `
        -Force `
        -ErrorAction Stop | Out-Null

    Write-Host "  [✓] Installation directory ready." -ForegroundColor $Red
}
catch {

    Show-ErrorAndExit `
        "Could not prepare the installation directory."
}


# ============================================================
# REMOVE OLD TEMP ZIP
# ============================================================

if (Test-Path $TempZip) {

    Remove-Item `
        -Path $TempZip `
        -Force `
        -ErrorAction SilentlyContinue
}


# ============================================================
# INSTALLATION NOTICE POPUP
# ============================================================

Add-Type -AssemblyName PresentationFramework

$Message = @"
WELCOME TO VORTEX OVERLAY

Please read before continuing.

Vortex Overlay is about to be downloaded
and installed on this computer.

Windows Security may display a warning
depending on the files being installed.

Only continue if you trust this software
and its source.

Installation location:

$InstallDir

Click OK to begin the download.
"@

$PopupResult = [System.Windows.MessageBox]::Show(
    $Message,
    "VORTEX OVERLAY",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information
)

if ($PopupResult -ne [System.Windows.MessageBoxResult]::OK) {

    Write-Host ""
    Write-Host "  Installation cancelled." -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}


# ============================================================
# DOWNLOAD
# ============================================================

Clear-Host

Show-VortexBanner

Write-Host ""
Write-Host "  DOWNLOAD" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""

Write-TypeEffect `
    "  Connecting to VORTEX servers..." `
    $White `
    10

Start-Sleep -Milliseconds 500

try {

    Add-Type -AssemblyName System.Net.Http

    $Handler = New-Object System.Net.Http.HttpClientHandler

    $Handler.AllowAutoRedirect = $true

    $Client = New-Object System.Net.Http.HttpClient($Handler)

    $Client.Timeout = [TimeSpan]::FromMinutes(30)

    $Response = $Client.GetAsync(
        $DownloadUrl,
        [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
    ).Result

    if (-not $Response.IsSuccessStatusCode) {

        throw "Download failed. HTTP $([int]$Response.StatusCode)"
    }

    $TotalBytes = $Response.Content.Headers.ContentLength

    $InputStream = $Response.Content.ReadAsStreamAsync().Result

    $OutputStream = [System.IO.File]::Create($TempZip)

    $Buffer = New-Object byte[] 65536

    $TotalRead = 0

    $LastPercent = -1

    while ($true) {

        $BytesRead = $InputStream.Read(
            $Buffer,
            0,
            $Buffer.Length
        )

        if ($BytesRead -le 0) {
            break
        }

        $OutputStream.Write(
            $Buffer,
            0,
            $BytesRead
        )

        $TotalRead += $BytesRead

        if ($TotalBytes) {

            $Percent = [math]::Floor(
                ($TotalRead / $TotalBytes) * 100
            )

            if ($Percent -ne $LastPercent) {

                $LastPercent = $Percent

                $BarLength = 42

                $Filled = [math]::Floor(
                    ($Percent / 100) * $BarLength
                )

                $Empty = $BarLength - $Filled

                $Bar =
                    ("█" * $Filled) +
                    ("░" * $Empty)

                $DownloadedMB = [math]::Round(
                    $TotalRead / 1MB,
                    1
                )

                $TotalMB = [math]::Round(
                    $TotalBytes / 1MB,
                    1
                )

                Write-Host (
                    "`r  [$Bar] $Percent%  $DownloadedMB MB / $TotalMB MB"
                ) `
                    -NoNewline `
                    -ForegroundColor $Red
            }
        }
    }

    $OutputStream.Close()
    $InputStream.Close()
    $Response.Dispose()
    $Client.Dispose()

    Write-Host ""
    Write-Host ""

    Write-Host "  [✓] DOWNLOAD COMPLETE" -ForegroundColor $Red

}
catch {

    if ($OutputStream) {
        $OutputStream.Close()
    }

    if ($InputStream) {
        $InputStream.Close()
    }

    if ($Client) {
        $Client.Dispose()
    }

    if (Test-Path $TempZip) {

        Remove-Item `
            $TempZip `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Show-ErrorAndExit `
        "Download failed. Check your internet connection or download source."
}


# ============================================================
# VERIFY ZIP
# ============================================================

Write-Host ""

Show-Spinner `
    "Verifying VORTEX package" `
    1

if (-not (Test-Path $TempZip)) {

    Show-ErrorAndExit `
        "Downloaded ZIP was not found."
}

$ZipSize = (Get-Item $TempZip).Length

if ($ZipSize -lt 1024) {

    Remove-Item `
        $TempZip `
        -Force `
        -ErrorAction SilentlyContinue

    Show-ErrorAndExit `
        "Downloaded package appears to be invalid."
}

Write-Host "  [✓] PACKAGE VERIFIED" -ForegroundColor $Red
Write-Host ""


# ============================================================
# EXTRACTION
# ============================================================

Write-Host "  EXTRACTION" -ForegroundColor $Red
Write-Host "  ────────────────────────────────────────" -ForegroundColor $White
Write-Host ""

try {

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $Archive = [System.IO.Compression.ZipFile]::OpenRead($TempZip)

    $Entries = $Archive.Entries

    $FileEntries = @(
        $Entries | Where-Object {
            -not [string]::IsNullOrEmpty($_.Name)
        }
    )

    $TotalFiles = $FileEntries.Count

    if ($TotalFiles -eq 0) {

        $Archive.Dispose()

        throw "The ZIP archive contains no files."
    }

    $CurrentFile = 0

    foreach ($Entry in $Entries) {

        $RelativePath = $Entry.FullName.Replace("/", "\")

        $DestinationPath = [System.IO.Path]::GetFullPath(
            (Join-Path $InstallDir $RelativePath)
        )

        $InstallRoot = [System.IO.Path]::GetFullPath(
            $InstallDir
        )

        if (-not $DestinationPath.StartsWith(
            $InstallRoot,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {

            throw "Unsafe path detected in archive."
        }

        if ([string]::IsNullOrEmpty($Entry.Name)) {

            New-Item `
                -ItemType Directory `
                -Path $DestinationPath `
                -Force `
                -ErrorAction Stop | Out-Null

            continue
        }

        $ParentDirectory = Split-Path `
            $DestinationPath `
            -Parent

        if ($ParentDirectory) {

            New-Item `
                -ItemType Directory `
                -Path $ParentDirectory `
                -Force `
                -ErrorAction Stop | Out-Null
        }

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
            $Entry,
            $DestinationPath,
            $true
        )

        $CurrentFile++

        $Percent = [math]::Floor(
            ($CurrentFile / $TotalFiles) * 100
        )

        $BarLength = 42

        $Filled = [math]::Floor(
            ($Percent / 100) * $BarLength
        )

        $Empty = $BarLength - $Filled

        $Bar =
            ("█" * $Filled) +
            ("░" * $Empty)

        $FileName = $Entry.Name

        if ($FileName.Length -gt 30) {

            $FileName = $FileName.Substring(
                0,
                27
            ) + "..."
        }

        Write-Host (
            "`r  [$Bar] $Percent%  $CurrentFile/$TotalFiles  $FileName"
        ) `
            -NoNewline `
            -ForegroundColor $Red
    }

    $Archive.Dispose()

    Write-Host ""
    Write-Host ""

    Write-Host "  [✓] EXTRACTION COMPLETE" -ForegroundColor $Red

}
catch {

    if ($Archive) {
        $Archive.Dispose()
    }

    Write-Host ""
    Write-Host "  [X] EXTRACTION FAILED" -ForegroundColor $Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor $White
    Write-Host ""

    if (Test-Path $TempZip) {

        Remove-Item `
            $TempZip `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Read-Host "Press ENTER to close"

    exit
}


# ============================================================
# CLEANUP
# ============================================================

Write-Host ""

Show-Spinner `
    "Cleaning temporary files" `
    1

try {

    Remove-Item `
        -Path $TempZip `
        -Force `
        -ErrorAction Stop

    Write-Host "  [✓] TEMPORARY ZIP REMOVED" -ForegroundColor $Red

}
catch {

    Write-Host "  [!] ZIP could not be deleted." -ForegroundColor $Yellow
}


# ============================================================
# VERIFY INSTALLATION
# ============================================================

Write-Host ""

Show-Spinner `
    "Finalizing installation" `
    1

$InstalledFiles = Get-ChildItem `
    -Path $InstallDir `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue

if (-not $InstalledFiles) {

    Show-ErrorAndExit `
        "No files were found after extraction."
}

Write-Host ""
Write-Host "  [✓] INSTALLATION VERIFIED" -ForegroundColor $Red

Start-Sleep -Milliseconds 700


# ============================================================
# FINAL ANIMATION
# ============================================================

Clear-Host

Write-Host ""
Write-Host ""

Write-Host "              V O R T E X" `
    -ForegroundColor $Red

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

foreach ($Frame in $FinalFrames) {

    Write-Host "`r              $Frame" `
        -NoNewline `
        -ForegroundColor $Red

    Start-Sleep -Milliseconds 70
}

Write-Host ""
Write-Host ""


# ============================================================
# ALL DONE
# ============================================================

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

Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $Red

Write-Host ""

Read-Host "Press ENTER to close"
