# ============================================================
#                    VORTEX OVERLAY
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

$Green  = "Green"
$Cyan   = "Cyan"
$Yellow = "Yellow"
$Red    = "Red"
$White  = "White"
$Gray   = "Gray"


# ============================================================
# FUNCTION - VORTEX BANNER
# ============================================================

function Show-VortexBanner {

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
}


# ============================================================
# FUNCTION - ERROR
# ============================================================

function Show-ErrorAndExit($Message) {

    Write-Host ""
    Write-Host "[X] $Message" -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}


# ============================================================
# START
# ============================================================

Show-VortexBanner


# ============================================================
# ACCESS KEY
# ============================================================

$EnteredKey = Read-Host "Enter access key"

if ($EnteredKey -ne $CorrectKey) {

    Write-Host ""
    Write-Host "[X] INVALID ACCESS KEY" -ForegroundColor $Red
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}

Write-Host ""
Write-Host "[+] Access key accepted." -ForegroundColor $Green
Write-Host ""


# ============================================================
# INSTALLATION LOCATION
# ============================================================

Write-Host "Where should Vortex Overlay be installed?" -ForegroundColor $Cyan
Write-Host ""

Write-Host "Default:" -ForegroundColor $Gray
Write-Host "$DefaultInstallDir" -ForegroundColor $White
Write-Host ""

$InstallInput = Read-Host "Enter installation path (Press ENTER for default)"

if ([string]::IsNullOrWhiteSpace($InstallInput)) {

    $InstallDir = $DefaultInstallDir

}
else {

    $InstallDir = $InstallInput.Trim().Trim('"')
}

Write-Host ""
Write-Host "Installation location:" -ForegroundColor $Gray
Write-Host $InstallDir -ForegroundColor $White
Write-Host ""


# ============================================================
# CREATE INSTALL DIRECTORY
# ============================================================

try {

    if (Test-Path $InstallDir) {

        Write-Host "Removing previous installation..." -ForegroundColor $Yellow

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

    Write-Host "[+] Installation directory ready." -ForegroundColor $Green

}
catch {

    Show-ErrorAndExit "Could not prepare installation directory."
}


# ============================================================
# DELETE OLD TEMP ZIP
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
Welcome to Vortex Overlay!

Please read the instructions carefully.

Make sure all that you turned of windows protection.
GO TO: virus&threats protection , manage settings,
turn off the protections.

Click OK to start downloading.
"@
$PopupResult = [System.Windows.MessageBox]::Show(
    $Message,
    "VORTEX OVERLAY",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information
)

if ($PopupResult -ne [System.Windows.MessageBoxResult]::OK) {

    Write-Host ""
    Write-Host "Installation cancelled." -ForegroundColor $Yellow
    Write-Host ""

    Read-Host "Press ENTER to close"

    exit
}


# ============================================================
# DOWNLOAD
# ============================================================

Write-Host ""
Write-Host "Downloading Vortex Overlay..." -ForegroundColor $Cyan
Write-Host ""

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

                $BarLength = 40

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
                ) -NoNewline -ForegroundColor $Green
            }
        }
    }

    $OutputStream.Close()
    $InputStream.Close()
    $Response.Dispose()
    $Client.Dispose()

    Write-Host ""
    Write-Host ""

    Write-Host "[+] Download completed." -ForegroundColor $Green

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

    Show-ErrorAndExit "Download failed. Check your internet connection or download source."
}


# ============================================================
# VERIFY ZIP
# ============================================================

Write-Host ""
Write-Host "Verifying package..." -ForegroundColor $Cyan

if (-not (Test-Path $TempZip)) {

    Show-ErrorAndExit "Downloaded ZIP was not found."
}

$ZipSize = (Get-Item $TempZip).Length

if ($ZipSize -lt 1024) {

    Remove-Item `
        $TempZip `
        -Force `
        -ErrorAction SilentlyContinue

    Show-ErrorAndExit "Downloaded package appears to be invalid."
}

Write-Host "[+] Package verified." -ForegroundColor $Green
Write-Host ""


# ============================================================
# EXTRACTION
# CUSTOM ANIMATION
# ============================================================

Write-Host "Extracting Vortex Overlay..." -ForegroundColor $Cyan
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

        # Security check against ZIP path traversal
        $DestinationPath = [System.IO.Path]::GetFullPath(
            (Join-Path $InstallDir $RelativePath)
        )

        $InstallRoot = [System.IO.Path]::GetFullPath($InstallDir)

        if (-not $DestinationPath.StartsWith(
            $InstallRoot,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {

            throw "Unsafe path detected in archive."
        }

        # Directory
        if ([string]::IsNullOrEmpty($Entry.Name)) {

            New-Item `
                -ItemType Directory `
                -Path $DestinationPath `
                -Force `
                -ErrorAction Stop | Out-Null

            continue
        }

        # Create parent directory
        $ParentDirectory = Split-Path $DestinationPath -Parent

        if ($ParentDirectory) {

            New-Item `
                -ItemType Directory `
                -Path $ParentDirectory `
                -Force `
                -ErrorAction Stop | Out-Null
        }

        # Extract file
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
            $Entry,
            $DestinationPath,
            $true
        )

        $CurrentFile++

        $Percent = [math]::Floor(
            ($CurrentFile / $TotalFiles) * 100
        )

        $BarLength = 40

        $Filled = [math]::Floor(
            ($Percent / 100) * $BarLength
        )

        $Empty = $BarLength - $Filled

        $Bar =
            ("█" * $Filled) +
            ("░" * $Empty)

        $FileName = $Entry.Name

        if ($FileName.Length -gt 35) {

            $FileName = $FileName.Substring(
                0,
                32
            ) + "..."
        }

        Write-Host (
            "`r  [$Bar] $Percent%  $CurrentFile/$TotalFiles  $FileName"
        ) -NoNewline -ForegroundColor $Green
    }

    $Archive.Dispose()

    Write-Host ""
    Write-Host ""

    Write-Host "[+] Extraction completed." -ForegroundColor $Green

}
catch {

    if ($Archive) {
        $Archive.Dispose()
    }

    Write-Host ""
    Write-Host ""
    Write-Host "[X] EXTRACTION FAILED" -ForegroundColor $Red
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

    exit
}


# ============================================================
# DELETE ZIP
# ============================================================

Write-Host ""
Write-Host "Cleaning temporary files..." -ForegroundColor $Cyan

try {

    Remove-Item `
        -Path $TempZip `
        -Force `
        -ErrorAction Stop

    Write-Host "[+] ZIP file deleted." -ForegroundColor $Green

}
catch {

    Write-Host "[!] ZIP could not be deleted." -ForegroundColor $Yellow
}


# ============================================================
# VERIFY INSTALLATION
# ============================================================

Write-Host ""
Write-Host "Checking installation..." -ForegroundColor $Cyan

$InstalledFiles = Get-ChildItem `
    -Path $InstallDir `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue

if (-not $InstalledFiles) {

    Show-ErrorAndExit "No files were found after extraction."
}

Write-Host "[+] Installation verified." -ForegroundColor $Green

Start-Sleep -Milliseconds 500


# ============================================================
# ALL DONE
# ============================================================

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

Read-Host "Press ENTER to close"
