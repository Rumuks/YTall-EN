# =================================================================
# ytall Project - v17.1
# =================================================================

# --- 0. Parameters ---
param(
    # Used by the bootstrapper to delete the original script file after a successful move.
    [string]$OriginalPath
)

# --- 1. Bootstrapper ---
# This section makes the script a portable installer.
if ($OriginalPath -eq "" -and $MyInvocation.MyCommand.Path) {
    try {
        $initialScriptPath = $MyInvocation.MyCommand.Path
        $currentDir = Split-Path -Path $initialScriptPath -Parent
        $currentFolderName = Split-Path $currentDir -Leaf

        if ($currentFolderName -ne 'ytall') {
            Write-Host ">>> ytall Bootstrapper: Starting stage 1 installation..." -ForegroundColor Green
            $ytallDir = Join-Path $currentDir "ytall"
            
            if (-not (Test-Path $ytallDir -PathType Container)) {
                Write-Host " -> Creating 'ytall' folder: $ytallDir" -ForegroundColor Cyan
                New-Item -Path $ytallDir -ItemType Directory | Out-Null
            }

            $newScriptPath = Join-Path $ytallDir (Split-Path $initialScriptPath -Leaf)

            Write-Host " -> Copying script into the 'ytall' folder..." -ForegroundColor Cyan
            Copy-Item -Path $initialScriptPath -Destination $newScriptPath -Force

            Write-Host " -> Continuing stage 2 installation inside the 'ytall' folder..." -ForegroundColor Cyan
            Write-Host " -> This window will close automatically shortly." -ForegroundColor Yellow
            
            $mainScriptPathToRun = Join-Path $ytallDir "run_ytall.ps1"
            $arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$mainScriptPathToRun`" -OriginalPath `"$initialScriptPath`""
            Start-Process powershell.exe -ArgumentList $arguments
            
            Start-Sleep -Seconds 3
            return
        }
    } catch {
        Write-Host "A critical error occurred while running the bootstrapper: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        return
    }
}
# --- End of Bootstrapper ---


# --- 2. Path and Configuration ---
$ErrorActionPreference = "Stop"
$baseDir = $PSScriptRoot 
$detailsDir = Join-Path $baseDir "details"
$engineDir = Join-Path $baseDir "engine"
$tempDir = Join-Path $baseDir "temp"
$convertDir = Join-Path $baseDir "Convert"
$completeDir = Join-Path $baseDir "Complete"
$logFile = Join-Path $detailsDir "debug_log.txt"
$cookieFile = Join-Path $detailsDir "cookies.txt"
$mp3ListFile = Join-Path $baseDir "mp3.txt"
$mp4ListFile = Join-Path $baseDir "mp4.txt"
$readmeFile = Join-Path $baseDir "README.md"
$eulaAcceptedFile = Join-Path $detailsDir "eula_accepted.txt"
$licenseFile = Join-Path $detailsDir "LICENSE"
$configFile = Join-Path $detailsDir "config.ini"
$ytDlpPath = Join-Path $engineDir "yt-dlp.exe"
$ffmpegPath = Join-Path $engineDir "ffmpeg.exe"
$ffprobePath = Join-Path $engineDir "ffprobe.exe"
$ytDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

# --- Content Strings ---
$eulaText = @'
==============================[ Legal Notice (End User License Agreement) ]==============================

**1. Agreement to Terms**
By using this script, you are considered to have fully read, understood, and agreed to everything below.

**2. Purpose and Intended Scope of Use**
This script is a tool that helps automate content downloading and conversion. It must be used only for the following purposes:
-   Content for which you personally own the copyright
-   Content the copyright holder has explicitly permitted for download (e.g., under a Creative Commons (CC) license)
-   Personal, non-commercial archiving (within the scope permitted by law, such as fair use)

**3. Prohibited Uses**
-   Using this script for commercial redistribution, resale, or any other for-profit activity is strictly prohibited.
-   This script does not circumvent any technical protection measures (such as DRM) and is not designed for that purpose.

**4. Third-Party Open Source Notice**
This script operates based on the following powerful open-source tools. These tools are downloaded from their respective official distribution channels at the time the script runs, and are not redistributed by this project.
-   **yt-dlp:** The Unlicense (https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE)
-   **ffmpeg:** LGPL/GPL (https://www.ffmpeg.org/legal.html)

**5. Disclaimer of Warranty and Limitation of Liability (No Warranty)**
This script is provided "AS IS" without any warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.
The developer shall not be liable, under any circumstances, for any direct, indirect, incidental, or consequential damages (including data loss, business interruption, etc.) arising from the use or misuse of this script.

**6. User Responsibility**
-   The user is responsible for complying with the terms of service of all platforms, including YouTube and Google. This project is not affiliated with those companies in any way.
-   The user bears full legal responsibility for complying with the copyright laws and related regulations of their country and region of residence.

==============================================================================================
'@
$readmeContent = @'
# YTall (Downloader Project)

A PowerShell script for conveniently downloading YouTube videos/audio and encoding video into high quality.

---

## 🚀 Getting Started

1.  Place the `run_ytall.ps1` file in a location of your choice (e.g., your desktop).
2.  Right-click the `run_ytall.ps1` file and select **[Run with PowerShell]**.
    -   On first run, the script will automatically create the `ytall` folder and download/install all required files. (The original file is automatically deleted after installation.)
3.  Agree to the legal notice (EULA) by typing `y`, then choose whether to create a desktop shortcut (`y` or `n`) to complete installation.
4.  Once installation finishes, the `README.md` file opens automatically. **(Important: please read it at least once!)**
5.  Add the YouTube links you want to download to `mp3.txt` or `mp4.txt` inside the `ytall` folder and save.
6.  Run the `YTall` shortcut created on your desktop, or `YTall.bat` inside the `ytall` folder, to start downloading.

---

## 🍪 How to Use Cookies (age verification, etc.)

To download videos that require sign-in or age verification, you need to copy your browser's cookie values into the `details/cookies.txt` file. Choose one of the methods below.

**Note:** Cookies may contain sensitive personal information, so never share this file with anyone else.

### Method 1: Using a Browser Extension (Recommended)

The most convenient method is to use an extension that easily exports cookies to a file.

*   **Chrome / Microsoft Edge:**
    (Edge is built on the same base as Chrome, so it supports most extensions from the Chrome Web Store.)
    1.  Install the **[Get cookies.txt LOCALLY](https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc)** extension. (Team lead's recommendation)
    2.  Open the YouTube page you want to get cookies from.
    3.  Click the extension icon (lock shape) next to the address bar, then click **[Export]**.
    4.  The `cookies.txt` file will be downloaded.
    5.  **Copy the entire contents** of the downloaded `cookies.txt` file, then **paste it over (overwrite)** the `cookies.txt` file located in the `ytall/details/` folder and save.

*   **Firefox:**
    1.  Install a cookie-export add-on such as **[cookies.txt](https://addons.mozilla.org/ko/firefox/addon/cookies-txt/)**.
    2.  Open the YouTube page you want to get cookies from.
    3.  Click the cookie-shaped icon next to the address bar, then click **"Download cookies.txt"**.
    4.  The `cookies.txt` file will be downloaded.
    5.  **Copy the entire contents** of the downloaded `cookies.txt` file, then **paste it over (overwrite)** the `cookies.txt` file located in the `ytall/details/` folder and save.

---

### Method 2: Manual Extraction via Developer Tools (if you don't have an extension installed)

#### Extracting Cookies in Chrome / Microsoft Edge

1.  Open the YouTube page containing the video you want to download.
2.  Press **F12** on your keyboard to open **Developer Tools**.
3.  Click the **[Network]** tab.
4.  Refresh the page (**F5**).
5.  Click on an item in the list that starts with `watch?v=`.
6.  In the right pane, select the **[Headers]** tab and scroll to the **Request Headers** section.
7.  Find the `cookie:` entry and copy the entire value.
8.  Paste it into `ytall/details/cookies.txt` and save.

#### Extracting Cookies in Firefox

1.  Open the YouTube page containing the video you want to download.
2.  Press **F12** to open **Developer Tools**.
3.  Click the **[Network]** tab and refresh the page (**F5**).
4.  Click on an item that starts with `watch?v=`.
5.  In the right pane, select the **[Headers]** tab and find **Request Headers**.
6.  Right-click the `Cookie` entry's value and select **[Copy All]**.
7.  Paste it into `ytall/details/cookies.txt` and save.

---

## 🔧 Advanced Settings (config.ini)

You can edit the `details/config.ini` file to control several behaviors of the script.

### [Encoding] Section (encoding-related)
-   **Encoder**: Choose the `gpu` (NVIDIA) or `cpu` encoder. (Automatically falls back to cpu if no NVIDIA graphics card is present.)
-   **Resolution**: Specifies the vertical resolution of the video (e.g., 720, 1080).
-   **MaxRate**: Limits the maximum bitrate during encoding to prevent the file size from becoming excessively large (e.g., 5M, 10M).
-   **GpuCq**: GPU encoding quality (lower = higher quality; recommended: 20-25).
-   **GpuPreset**: GPU encoding speed/quality balance. `p1` (fastest) ~ `p7` (best quality).
-   **CpuCrf**: CPU encoding quality (lower = higher quality; recommended: 22-28).
-   **CpuPreset**: CPU encoding speed/compression ratio. `ultrafast` ~ `veryslow`.

### [General] Section (general settings)
-   **EnableEncoding**: If set to `true`, downloaded MP4 videos are re-encoded with the HEVC (H.265) codec. If set to `false`, the encoding step is skipped and the original downloaded file is used as-is.
-   **ProcessPlaylists**: If set to `true`, when `mp3.txt` or `mp4.txt` contains a playlist link, every video/audio track in the playlist is downloaded. If left as `false`, only the single video from the playlist link itself is downloaded.
    -   **Note:** Once a playlist link has been processed, it is automatically removed from the list file; if some videos failed, only the individual links for those failed videos remain. So if new videos are later added to the playlist, you'll need to re-add the original playlist link to the list file to fetch them.
-   **PlaySoundOnComplete**: If set to `true`, a completion notification sound plays once all jobs are finished.
-   **MinFreeSpaceGB**: Specifies the minimum required free disk space (GB) when the script runs. If available space is less than this, the job is halted for safety.
-   **EmbedThumbnail**: If set to `true`, the video's thumbnail is automatically fetched and embedded as album art when downloading MP3.
-   **EmbedMetadata**: If set to `true`, metadata such as song title, artist, and composer is automatically written inside the MP3 file.
---

## ❤️ Support the Developer (Sponsorship)

If you enjoyed this project, please consider sending the developer a little support. It's a huge help in building better projects!

-   [Support via Ctee](https://ctee.kr/place/rumuk)
'@
$licenseContent = @'
MIT License

Copyright (c) 2024 ytall Project Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@
$defaultConfigContent = @'
# ytall config file (see README.md for details)
[Encoding]
Encoder = gpu
Resolution = 720
GpuCq = 23
GpuPreset = p7
MaxRate = 5M
CpuCrf = 24
CpuPreset = medium

[General]
# Determines whether to re-encode as HEVC (H.265) after downloading MP4.
# If set to false, the downloaded original file is used as-is. (faster)
EnableEncoding = true
# If set to true, the entire playlist is downloaded when a playlist link is found.
ProcessPlaylists = false
# If set to true, a notification sound plays when all jobs are complete.
PlaySoundOnComplete = true
# Specifies the minimum free disk space (GB) required before downloading.
MinFreeSpaceGB = 2
# If set to true, embeds the thumbnail as album art when downloading MP3.
EmbedThumbnail = true
# If set to true, embeds song title, artist, and composer (channel name) metadata inside the MP3 file.
EmbedMetadata = false
'@
$batFileContent = @'
chcp 65001 > nul
setlocal
set "scriptPath=%~dp0run_ytall.ps1"
if not exist "%scriptPath%" (
    echo. & echo [ERROR] Could not find the run_ytall.ps1 script file. & echo.
    pause & exit /b 1
)
:: Use 'start' to launch PowerShell in a new window and detach it from the batch process.
:: This prevents the "Terminate batch job (Y/N)?" prompt on Ctrl+C.
start "YTall Downloader" powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%scriptPath%"
endlocal
exit /b 0
'@

# --- Global Settings & Hashes ---
$defaultConfig = @{ Encoder = "gpu"; Resolution = "720"; GpuCq = "23"; GpuPreset = "p7"; MaxRate = "5M"; CpuCrf = "24"; CpuPreset = "medium"; ProcessPlaylists = $false; PlaySoundOnComplete = $true; MinFreeSpaceGB = 2; EmbedThumbnail = $true; EnableEncoding = $true; EmbedMetadata = $false }
$IP_BAN_KEYWORDS = @("HTTP Error 429", "too many requests")
$COOKIE_KEYWORDS = @("HTTP Error 403", "sign in to confirm your age", "who have enabled it", "netscape format")
$COOLDOWN_SECONDS = 10

# --- Helper Functions ---
function Handle-CookieError {
    Write-Log "Download failed due to a cookie problem. Clearing the existing cookie file." -Color Yellow
    Clear-Content $cookieFile -ErrorAction SilentlyContinue
    Write-Log "To download age-restricted videos, you need to paste a new cookie value into 'details/cookies.txt'." -Color Yellow
    Write-Log "See the README.md file for detailed instructions. Opening it automatically." -Color Cyan
    
    try {
        Start-Process notepad.exe $readmeFile
    } catch {
        Write-Log "Failed to open README.md. Please check the file directly in the 'ytall' folder." -Color Red
    }
    
    $script:haltScript = $true
    Write-Log "[CRITICAL] Halting the job. Please apply the new cookie and run again." -Color Red
}

function Write-Log {
    param([string]$Message, [string]$Color = "Gray")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    if (Test-Path $logFile) { $logMessage | Out-File -FilePath $logFile -Append -Encoding utf8 }
    Write-Host $logMessage -ForegroundColor $Color
}

function Update-LinkFileAtomic {
    param([string]$FilePath, [System.Collections.Generic.List[string]]$RemainingList)
    $tempDirForAtomic = Join-Path $baseDir "temp"
    if (-not (Test-Path $tempDirForAtomic -PathType Container)) { New-Item -Path $tempDirForAtomic -ItemType Directory | Out-Null }
    $tempFileName = "$(Split-Path $FilePath -Leaf).tmp"
    $tempPath = Join-Path $tempDirForAtomic $tempFileName
    Set-Content -Path $tempPath -Value $RemainingList -Encoding utf8
    Move-Item -Path $tempPath -Destination $FilePath -Force
}

function Install-Deno {
    Write-Log "[INSTALL] Downloading Deno (JS runtime for yt-dlp)..." -Color Cyan
    $denoZipPath = Join-Path $tempDir "deno.zip"
    $denoUrl = "https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip"
    try {
        Invoke-WebRequest -Uri $denoUrl -OutFile $denoZipPath -UseBasicParsing
        Write-Log "-> deno.zip download complete. Extracting..." -Color Cyan
        Expand-Archive -Path $denoZipPath -DestinationPath $engineDir -Force
        Write-Log "-> Deno installed successfully." -Color Green
    } catch {
        Write-Log "[INSTALL] WARNING: Failed to install Deno. Some videos may fail to download. Error: $_" -Color Yellow
    } finally {
        if (Test-Path $denoZipPath) { Remove-Item $denoZipPath -Force -ErrorAction SilentlyContinue }
    }
}

function Install-YtDlp {
    Write-Log "[INSTALL] Downloading yt-dlp.exe..." -Color Cyan
    try {
        Invoke-WebRequest -Uri $ytDlpUrl -OutFile $ytDlpPath -UseBasicParsing
        Write-Log "-> yt-dlp download complete." -Color Green
    } catch {
        throw "FATAL: Failed to download yt-dlp.exe. Error: $_"
    }
}

function Install-Ffmpeg {
    Write-Log "[INSTALL] Downloading ffmpeg..." -Color Cyan
    $ffmpegZipPath = Join-Path $tempDir "ffmpeg.zip"
    $ffmpegExtractPath = Join-Path $tempDir "ffmpeg_extracted"
    
    try {
        # Dynamically find the latest ffmpeg build URL from the correct GitHub API
        Write-Log "-> Finding latest ffmpeg build from GyanD/codexffmpeg..." -Color Gray
        $apiUrl = "https://api.github.com/repos/GyanD/codexffmpeg/releases/latest"
        $latestRelease = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        $asset = $latestRelease.assets | Where-Object { $_.name -like '*essentials_build.zip' } | Select-Object -First 1
        
        if (-not $asset) {
            throw "Could not find a suitable ffmpeg asset (e.g., '...essentials_build.zip') in the latest GitHub release."
        }
        
        $dynamicFfmpegUrl = $asset.browser_download_url
        Write-Log "-> Found asset: $($asset.name). Downloading..." -Color Gray

        Invoke-WebRequest -Uri $dynamicFfmpegUrl -OutFile $ffmpegZipPath -UseBasicParsing
        Write-Log "-> ffmpeg.zip download complete. Extracting..." -Color Cyan
        Expand-Archive -Path $ffmpegZipPath -DestinationPath $ffmpegExtractPath -Force
        # The new zip structure might be different, let's find the bin directory more robustly
        $binDir = Get-ChildItem -Path $ffmpegExtractPath -Filter "bin" -Recurse -Directory | Select-Object -First 1
        if (-not $binDir) {
            # Fallback for flat structure
            $binDir = Get-ChildItem -Path $ffmpegExtractPath -Directory | Select-Object -First 1
        }

        $ffmpegSource = Join-Path $binDir.FullName "ffmpeg.exe"
        $ffprobeSource = Join-Path $binDir.FullName "ffprobe.exe"
        Move-Item -Path $ffmpegSource -Destination $engineDir -Force
        Move-Item -Path $ffprobeSource -Destination $engineDir -Force
        Write-Log "-> ffmpeg installation complete." -Color Green
        
        # Save the release tag for future update checks
        $versionFile = Join-Path $detailsDir "ffmpeg_version.txt"
        Set-Content -Path $versionFile -Value $latestRelease.tag_name
    } catch {
        throw "FATAL: Failed during ffmpeg installation. Error: $_"
    } finally {
        if (Test-Path $ffmpegZipPath) { Remove-Item $ffmpegZipPath -Force -ErrorAction SilentlyContinue }
        if (Test-Path $ffmpegExtractPath) { Remove-Item $ffmpegExtractPath -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Update-Engine {
    [CmdletBinding()]
    param()

    $updateCheckFile = Join-Path $detailsDir "last_update_check.txt"
    $updateCheckInterval = New-TimeSpan -Days 7
    $needsCheck = $true

    if (Test-Path $updateCheckFile) {
        try {
            $lastCheck = Get-Date (Get-Content $updateCheckFile)
            if ((Get-Date) - $lastCheck -lt $updateCheckInterval) {
                $needsCheck = $false
            }
        } catch {
            Write-Log "Could not parse date from '$updateCheckFile'. Forcing update check." -Color Yellow
        }
    }

    if (-not $needsCheck) {
        return
    }

    Write-Log "Checking for engine updates..." -Color Cyan

    # --- yt-dlp update check (version comparison) ---
    try {
        Write-Log "[Update] Checking yt-dlp version..." -Color Gray
        $localYtDlpVersion = (& $ytDlpPath --version).Trim()
        
        $githubApiUrl = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
        $latestRelease = Invoke-RestMethod -Uri $githubApiUrl -UseBasicParsing
        $remoteYtDlpVersion = $latestRelease.tag_name.Trim()

        if ($localYtDlpVersion -ne $remoteYtDlpVersion) {
            Write-Log "-> New yt-dlp version found (Local: $localYtDlpVersion, Remote: $remoteYtDlpVersion). Updating..." -Color Yellow
            Install-YtDlp
        } else {
            Write-Log "-> yt-dlp is up to date." -Color Green
        }
    } catch {
        Write-Log "[Update] Failed to check for yt-dlp updates. Error: $_" -Color Red
    }

    # --- ffmpeg update check (release tag comparison) ---
    try {
        Write-Log "[Update] Checking ffmpeg version..." -Color Gray
        $ffmpegVersionFile = Join-Path $detailsDir "ffmpeg_version.txt"
        $localFfmpegTag = ""
        if (Test-Path $ffmpegVersionFile) {
            $localFfmpegTag = Get-Content $ffmpegVersionFile
        }

        $apiUrl = "https://api.github.com/repos/GyanD/codexffmpeg/releases/latest"
        $latestRelease = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        $remoteFfmpegTag = $latestRelease.tag_name

        if ($localFfmpegTag -ne $remoteFfmpegTag) {
            Write-Log "-> New ffmpeg build found (Local: $localFfmpegTag, Remote: $remoteFfmpegTag). Updating..." -Color Yellow
            Install-Ffmpeg
        } else {
            Write-Log "-> ffmpeg is up to date." -Color Green
        }
    } catch {
        Write-Log "[Update] Failed to check for ffmpeg updates. Error: $_" -Color Red
    }

    # --- Update the timestamp ---
    try {
        Set-Content -Path $updateCheckFile -Value (Get-Date).ToString("o")
    } catch {
        Write-Log "Failed to write update timestamp to $updateCheckFile" -Color Red
    }
    Write-Log "Finished checking for updates.`n"
}

function Ensure-EngineExists {
    [CmdletBinding()]
    param()
    
    $didInstall = $false
    Write-Log "Verifying required engine components..."
    
    $denoPath = Join-Path $engineDir "deno.exe"
    if (-not (Test-Path $denoPath -PathType Leaf)) {
        $didInstall = $true
        Install-Deno
    }

    if (-not (Test-Path $ytDlpPath -PathType Leaf)) {
        $didInstall = $true
        Install-YtDlp
    }
    
    if ((-not (Test-Path $ffmpegPath -PathType Leaf)) -or (-not (Test-Path $ffprobePath -PathType Leaf))) {
        $didInstall = $true
        Install-Ffmpeg
    }
    
    if (-not $didInstall) {
        Write-Log "-> All components present." -Color Green
    }
    Write-Log ""
    return $didInstall
}

function Get-Safe-FilePath {
    param(
        [PSCustomObject]$Info,
        [string]$Extension,
        [string]$TargetDir
    )
    # Restore the original format and use a blacklist for invalid chars to support all languages
    $safeOutputTitle = ($Info.channel + " - " + $Info.title) -replace '[\\/:*?"<>|]', '_'
    # Also, trim and collapse multiple spaces to keep it clean.
    $safeOutputTitle = $safeOutputTitle.Trim() -replace '\s+', ' '
    if ($safeOutputTitle.Length -gt 150) { $safeOutputTitle = $safeOutputTitle.Substring(0, 150) }
    $outputFile = Join-Path $TargetDir "$safeOutputTitle.$Extension"

    # Check for filename collisions and append a number if necessary
    $counter = 1
    $originalBaseName = [System.IO.Path]::GetFileNameWithoutExtension($outputFile)
    while (Test-Path $outputFile) {
        $newFilename = "$originalBaseName`_($counter).$Extension"
        $outputFile = Join-Path $TargetDir $newFilename
        $counter++
    }
    return $outputFile
}

function Invoke-YtDlp {
    param([array]$Arguments, [switch]$Silent, [switch]$NoCooldown)
    
    $output = [System.Collections.Generic.List[string]]::new()
    $progressShown = $false
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    
    try {
        & $ytDlpPath "--newline" "--color" "never" $Arguments 2>&1 | ForEach-Object {
            $line = $_.ToString()
            $output.Add($line)
            if ($line -match '^\[download\]\s+\d{1,3}(?:\.\d+)?%') {
                Write-Host ("`r" + $line.PadRight(120)) -NoNewline
                $progressShown = $true
            } else {
                if ($progressShown) { Write-Host "" }
                if (-not $Silent) {
                    Write-Log $line -Color "Yellow"
                }
                $progressShown = $false
            }
        }
    } finally {
        $ErrorActionPreference = $prevEAP
    }
    
    if ($progressShown) { Write-Host "" }
    
    if ($LASTEXITCODE -eq 0) {
        if (-not $NoCooldown) {
            Write-Log "-> yt-dlp execution finished. Cooling down for $COOLDOWN_SECONDS seconds..." -Color Gray
            Start-Sleep -Seconds $COOLDOWN_SECONDS
        } else {
            Write-Log "-> yt-dlp execution finished (cooldown skipped)." -Color DarkGray
        }
        return [PSCustomObject]@{ Status = 'Success'; Output = $output }
    }
    
    $outputString = $output -join [System.Environment]::NewLine
    $lowerOutput = $outputString.ToLower()
    
    foreach ($keyword in $IP_BAN_KEYWORDS) {
        if ($lowerOutput -match $keyword) { return [PSCustomObject]@{ Status = 'IpBanError'; Output = $outputString } }
    }
    foreach ($keyword in $COOKIE_KEYWORDS) {
        if ($lowerOutput -match $keyword) { return [PSCustomObject]@{ Status = 'CookieError'; Output = $outputString } }
    }
    
    return [PSCustomObject]@{ Status = 'GenericError'; Output = $outputString }
}

function Invoke-Ffmpeg {
    [CmdletBinding()]
    param(
        [array]$Arguments,
        [double]$TotalSeconds = 0,
        [datetime]$StartTime
    )

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $progressShown = $false
    
    try {
        & $ffmpegPath $Arguments 2>&1 | ForEach-Object {
            $line = $_.ToString()
            if ($line -like '*Late SEI is not implemented*') {
                # This is a non-critical warning we want to hide.
                continue
            }

            # Updated regex to capture speed
            if ($line -match "frame=\s*(\d+)\s*fps=\s*([\d\.]+).*time=\s*(\d{2}):(\d{2}):(\d{2})\.\d+.*speed=\s*([\d\.]+)x") {
                if ($TotalSeconds -gt 0) {
                    $frame = $Matches[1]
                    $hours = [int]$Matches[3]; $minutes = [int]$Matches[4]; $seconds = [int]$Matches[5]
                    $speed = $Matches[6]
                    $currentSeconds = ($hours * 3600) + ($minutes * 60) + $seconds
                    
                    if ($currentSeconds -gt 0) {
                        $percentage = ($currentSeconds / $TotalSeconds) * 100
                        $elapsedTime = (Get-Date) - $StartTime
                        $elapsedString = $elapsedTime.ToString('hh\:mm\:ss')
                        $etaSeconds = ($elapsedTime.TotalSeconds / $currentSeconds) * ($TotalSeconds - $currentSeconds)
                        if ($etaSeconds -lt 0) { $etaSeconds = 0 }
                        $eta = [System.TimeSpan]::FromSeconds($etaSeconds)
                        $etaString = $eta.ToString('hh\:mm\:ss')
                        
                        # Write the progress bar in pieces for coloring
                        Write-Host "`r[CONVERT] " -NoNewline
                        Write-Host ("[{0:N2}%]" -f $percentage) -ForegroundColor Yellow -NoNewline
                        
                        $restOfString = " Frame: {0} | Time: {1}:{2}:{3} | Speed: {4}x | Elapsed: {5} | ETA: {6}" -f $frame, $hours.ToString("00"), $minutes.ToString("00"), $seconds.ToString("00"), $speed, $elapsedString, $etaString
                        Write-Host $restOfString.PadRight(100) -NoNewline
                    }
                } else {
                    # Fallback for when duration is not available
                    $progressLine = "[CONVERT] " + $line.Trim()
                    Write-Host ("`r" + $progressLine.PadRight(120)) -NoNewline
                }
                $progressShown = $true
            } else {
                if ($progressShown) {
                    Write-Host ""
                    $progressShown = $false
                }
                Write-Host $line
            }
        }
    } finally {
        $ErrorActionPreference = $prevEAP
    }
    
    if ($progressShown) { Write-Host "" }

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        Write-Log "ffmpeg process exited with a non-zero code: $LASTEXITCODE." -Color Red
        return $false
    }
}

function Parse-Config {
    param([string]$FilePath, [hashtable]$Defaults)
    
    $configFromFile = @{}
    if (Test-Path $FilePath) {
        Get-Content $FilePath | ForEach-Object {
            $line = $_.Trim()
            if ($line -and $line -notmatch '^\s*#' -and $line -match '=') {
                $key, $value = $line.Split('=', 2)
                $configFromFile[$key.Trim()] = $value.Trim()
            }
        }
    }
    
    $finalConfig = $Defaults.Clone()
    foreach ($key in $configFromFile.Keys) {
        if ($finalConfig.ContainsKey($key)) {
            $value = $configFromFile[$key]
            # Check if the default value is a boolean, if so, parse the string to a proper boolean
            if ($Defaults[$key] -is [bool]) {
                # Explicitly compare against 'true', case-insensitive. Other values become false.
                $finalConfig[$key] = ($value -eq 'true')
            } else {
                $finalConfig[$key] = $value
            }
        }
    }
    return [PSCustomObject]$finalConfig
}

function Process-UrlType {
    param(
        [ValidateSet('mp3', 'mp4')][string]$Type,
        [System.Collections.Generic.List[string]]$UrlList,
        [string]$LinkFile,
        [ref]$SucceededCount,
        [System.Collections.Generic.List[string]]$FailedUrlList
    )

    $urlsToProcess = [System.Collections.Generic.List[string]]::new($UrlList) # Iterate over a copy
    
    foreach ($url in $urlsToProcess) {
        if ($haltScript) { break }
        
        $playlistFullySuccessful = $true
        $failedVideosInPlaylist = [System.Collections.Generic.List[string]]::new()
        $isVideoList = $false # Initialize per-URL

        try {
            Write-Log "[$($Type.ToUpper())] Fetching metadata for URL: $url"
            $metaArguments = @("--dump-json", "--no-download", "--cookies", $cookieFile, "--ffmpeg-location", $engineDir, $url)
            if (-not $config.ProcessPlaylists) { $metaArguments += "--no-playlist" }

            $infoJsonOutput = & $ytDlpPath $metaArguments 2>&1
            if ($LASTEXITCODE -ne 0) {
                $errorOutput = $infoJsonOutput -join "`n"; $lowerOutput = $errorOutput.ToLower(); $status = 'GenericError'
                foreach ($keyword in $IP_BAN_KEYWORDS) { if ($lowerOutput -match $keyword) { $status = 'IpBanError'; break } }
                foreach ($keyword in $COOKIE_KEYWORDS) { if ($lowerOutput -match $keyword) { $status = 'CookieError'; break } }
                throw $status
            }
            
            $allInfoJson = $infoJsonOutput | Where-Object { $_.TrimStart().StartsWith('{') }
            if (-not $allInfoJson) { throw "Could not find any JSON in yt-dlp output." }

            $isVideoList = $allInfoJson.Count -gt 1

            foreach ($jsonLine in $allInfoJson) {
                if ($haltScript) { throw "Script halted by user or critical error." }
                
                $script:completedTasks++
                $info = $null; $finalOutputFile = $null; $tempFile1 = $null; $tempFile2 = $null; $tempFile3 = $null; $tempFile2_orig = $null
                $videoSuccessful = $false
                try {
                    $info = $jsonLine | ConvertFrom-Json
                    Write-Log "[$($Type.ToUpper())] [$($script:completedTasks)/$($script:totalTasks)] Processing Video: $($info.title)"
                    
                    if ($Type -eq 'mp3') {
                        $finalOutputFile = Get-Safe-FilePath -Info $info -Extension "mp3" -TargetDir $completeDir
                        if ($config.EmbedThumbnail) {
                            $tempFile1 = Join-Path $tempDir "$($info.id).mp3"
                            $audioResult = Invoke-YtDlp -Arguments @("-N", "8", "--cookies", $cookieFile, "-x", "--audio-format", "mp3", "--ffmpeg-location", $engineDir, "-o", $tempFile1, $info.webpage_url, "--no-playlist")
                            if ($audioResult.Status -ne 'Success') { throw $audioResult.Status }
                            if ((Invoke-YtDlp -Arguments @("--skip-download", "--write-thumbnail", "--ffmpeg-location", $engineDir, "-o", (Join-Path $tempDir "%(id)s.%(ext)s"), $info.webpage_url, "--no-playlist") -Silent -NoCooldown).Status -eq 'Success') {
                                $tempFile2_orig = Get-ChildItem -Path $tempDir -Filter "$($info.id).*" | Where-Object { $_.Extension -in ".jpg", ".jpeg", ".png", ".webp" } | Select-Object -First 1
                                if ($tempFile2_orig) {
                                    $tempFile2 = Join-Path $tempDir "$($info.id).jpg"
                                    Invoke-Ffmpeg -Arguments @("-i", $tempFile2_orig.FullName, "-y", "-frames:v", "1", $tempFile2)
                                    if (-not (Invoke-Ffmpeg -Arguments @("-i", $tempFile1, "-i", $tempFile2, "-map", "0:a:0", "-map", "1:v:0", "-c:a", "copy", "-c:v", "mjpeg", "-disposition:v:0", "attached_pic", "-id3v2_version", "3", $finalOutputFile))) { throw "ffmpeg failed to embed thumbnail." }
                                } else {
                                    Write-Log "[MP3] WARNING: Thumbnail downloaded but could not be found. Moving audio without thumbnail." -Color Yellow
                                    Move-Item -Path $tempFile1 -Destination $finalOutputFile -Force
                                }
                            } else {
                                Write-Log "[MP3] WARNING: Thumbnail download failed, proceeding without it." -Color Yellow
                                Move-Item -Path $tempFile1 -Destination $finalOutputFile -Force
                            }
                        } else {
                            $dlResult = Invoke-YtDlp -Arguments @("-N", "8", "--cookies", $cookieFile, "-x", "--audio-format", "mp3", "--ffmpeg-location", $engineDir, "-o", $finalOutputFile, $info.webpage_url, "--no-playlist")
                            if ($dlResult.Status -ne 'Success') { throw $dlResult.Status }
                        }
                        if ($config.EmbedMetadata) {
                            $tempFile3 = Join-Path $tempDir "meta_$($info.id).mp3"
                            if ((Invoke-Ffmpeg -Arguments @("-i", $finalOutputFile, "-map", "0", "-c", "copy", "-metadata", "title=$($info.title)", "-metadata", "artist=$($info.channel)", "-metadata", "composer=$($info.channel)", "-y", $tempFile3))) {
                                Move-Item -Path $tempFile3 -Destination $finalOutputFile -Force
                            } else { Write-Log "[MP3] WARNING: Failed to embed metadata for '$($info.title)'. Continuing..." -Color Yellow }
                        }
                    } elseif ($Type -eq 'mp4') {
                        $tempFile1 = Join-Path $convertDir "$($info.id).mp4"
                        $dlResult = Invoke-YtDlp -Arguments @("-N", "8", "--cookies", $cookieFile, "--ffmpeg-location", $engineDir, "-f", "bestvideo[height<=$($config.Resolution)][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best", "--merge-output-format", "mp4", "-o", $tempFile1, $info.webpage_url, "--no-playlist")
                        if ($dlResult.Status -ne 'Success') { throw $dlResult.Status }
                        if (-not (Test-Path $tempFile1)) { throw "File not found in Convert dir after download." }
                        $finalOutputFile = Get-Safe-FilePath -Info $info -Extension "mp4" -TargetDir $completeDir
                        if ($config.EnableEncoding) {
                            $inputArgs = @(); $outputArgs = @()
                            if ($config.Encoder -eq 'gpu' -and (Test-Path (Join-Path $env:SystemRoot "System32\nvml.dll"))) { $inputArgs += @("-hwaccel", "cuda"); $outputArgs += @("-c:v", "hevc_nvenc", "-vf", "scale=-2:$($config.Resolution)", "-cq", $config.GpuCq, "-preset", $config.GpuPreset, "-maxrate", $config.MaxRate, "-c:a", "copy") }
                            else { $outputArgs += @("-c:v", "libx264", "-vf", "scale=-2:$($config.Resolution)", "-crf", $config.CpuCrf, "-preset", $config.CpuPreset, "-maxrate", $config.MaxRate, "-c:a", "copy") }
                            if (-not (Invoke-Ffmpeg -Arguments ($inputArgs + @("-y", "-i", $tempFile1) + $outputArgs + $finalOutputFile) -TotalSeconds $info.duration -StartTime (Get-Date))) { throw "ffmpeg encoding failed." }
                        } else { Move-Item -Path $tempFile1 -Destination $finalOutputFile -Force }
                    }
                    $videoSuccessful = $true
                    Write-Log "[$($Type.ToUpper())] SUCCESS: Processing complete for '$($info.title)'." -Color Green
                } catch {
                    $playlistFullySuccessful = $false
                    if ($info) { $failedVideosInPlaylist.Add($info.webpage_url) }
                    $errorMessage = $_.ToString()
                    Write-Log "[$($Type.ToUpper())] FAILED video '$(if ($info) { $info.title } else { 'N/A' })' from playlist '$url'. Error: $errorMessage" -Color Red
                    if ($errorMessage -like '*CookieError*' -or $errorMessage -like '*IpBanError*') { throw }
                } finally {
                    foreach($tempPath in @($tempFile1, $tempFile2, $tempFile3, $tempFile2_orig.FullName)) {
                        if ($tempPath -and (Test-Path $tempPath)) { Remove-Item $tempPath -Force -ErrorAction SilentlyContinue }
                    }
                    if (-not $videoSuccessful -and $finalOutputFile -and (Test-Path $finalOutputFile)) {
                        Write-Log "-> Cleaning up incomplete final file: $finalOutputFile" -Color Yellow
                        Remove-Item $finalOutputFile -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        } catch {
            $playlistFullySuccessful = $false
            $errorMessage = $_.ToString()
            Write-Log "[$($Type.ToUpper())] FAILED processing of URL '$url'. Error: $errorMessage" -Color Red
            if (-not $FailedUrlList.Contains($url)) { $FailedUrlList.Add($url) }
            if ($errorMessage -like '*CookieError*') { Handle-CookieError }
            elseif ($errorMessage -like '*IpBanError*') {
                $script:haltScript = $true
                Write-Log "[CRITICAL] Your IP appears to be blocked. Please try again later. Halting the job." -Color Red
            }
        }
        
        $currentRemaining = [System.Collections.Generic.List[string]]::new($UrlList)
        if ($playlistFullySuccessful) {
            $currentRemaining.Remove($url)
            $SucceededCount.Value++
            Write-Log "[$($Type.ToUpper())] SUCCESS: Entire URL '$url' processed successfully." -Color Green
        } else {
            if ($isVideoList) {
                $currentRemaining.Remove($url)
                $currentRemaining.AddRange($failedVideosInPlaylist)
            }
            if (-not $FailedUrlList.Contains($url)) { $FailedUrlList.Add($url) }
            Write-Log "[$($Type.ToUpper())] PARTIAL/FAIL: URL '$url' had at least one failure. Failed videos will be retried." -Color Yellow
        }
        Update-LinkFileAtomic -FilePath $LinkFile -RemainingList $currentRemaining
        $UrlList.Clear()
        $UrlList.AddRange($currentRemaining)
    }
}

# --- Main Execution Block ---
$failedMp3Urls = [System.Collections.Generic.List[string]]::new(); $failedMp4Urls = [System.Collections.Generic.List[string]]::new(); $succeededMp3Count = 0; $succeededMp4Count = 0; $haltScript = $false; $jobRun = $true; $didPerformSetupActions = $false; $isCompleteFirstRun = $false

try {
    # This part of the bootstrapper logic remains in the main script to handle the post-move cleanup.
    if ($OriginalPath -and (Test-Path $OriginalPath)) { 
        1..3 | ForEach-Object {
            Start-Sleep -Seconds 1
            if (-not (Test-Path $OriginalPath)) { return } # Exit loop if already deleted
            Remove-Item -Path $OriginalPath -Force -ErrorAction SilentlyContinue 
        }
        if (Test-Path $OriginalPath) {
            Write-Log "-> WARNING: Could not delete the original script file. You may need to delete it manually: $OriginalPath" -Color Yellow
        }
    }
    
    # --- Initial Setup on First Run ---
    if (-not (Test-Path $detailsDir -PathType Container)) { 
        $didPerformSetupActions = $true
        New-Item -Path $detailsDir -ItemType Directory | Out-Null 
    }

    if (-not (Test-Path $eulaAcceptedFile -PathType Leaf)) { 
        $isCompleteFirstRun = $true
        $didPerformSetupActions = $true
        Write-Host ""
        Write-Host $eulaText -ForegroundColor Yellow
        $agreement = ""
        while ($agreement -ne 'y' -and $agreement -ne 'n') {
            $agreement = Read-Host "`nDo you agree to the above? [y/n]"
        }
        if ($agreement -ne 'y') { 
            Write-Host "You did not agree, so the process is being stopped." -ForegroundColor Red
            return 
        }
        Set-Content -Path $eulaAcceptedFile -Value "EULA accepted on: $(Get-Date)"
        Write-Host "$([char]27)[92mThank you for agreeing.$([char]27)[0m" # Using bright green ANSI code
    }

    # Structure verification and file creation
    if (-not (Test-Path $logFile)) { New-Item -Path $logFile -ItemType File | Out-Null }
    Clear-Content $logFile
    Write-Host "======================================================" -ForegroundColor Magenta
    Write-Log "Starting ytall Downloader v17.1..." -Color Cyan
    Write-Host "======================================================" -ForegroundColor Magenta
    
    Write-Log "Verifying project structure..."
    foreach ($dir in @($engineDir, $tempDir, $convertDir, $completeDir)) { 
        Write-Log "--> Checking dir: $dir" -Color DarkGray
        if (-not (Test-Path $dir)) { 
            $didPerformSetupActions = $true
            Write-Log "--> Creating dir: $dir" -Color Yellow
            New-Item -Path $dir -ItemType Directory | Out-Null 
        } 
    }
    foreach ($file in @($mp3ListFile, $mp4ListFile, $cookieFile)) { 
        Write-Log "--> Checking file: $file" -Color DarkGray
        if (-not (Test-Path $file)) { 
            $didPerformSetupActions = $true
            Write-Log "--> Creating file: $file" -Color Yellow
            New-Item -Path $file -ItemType File | Out-Null 
        } 
    }
    Write-Log "--> Checking config file..." -Color DarkGray
    if (-not (Test-Path $configFile)) { 
        $didPerformSetupActions = $true
        Write-Log "--> Creating config file..." -Color Yellow
        Set-Content -Path $configFile -Value $defaultConfigContent -Encoding utf8 
    }

    Write-Log "--> Checking bat file..." -Color DarkGray
    $batFilePath = Join-Path $baseDir "YTall.bat"
    if (-not (Test-Path $batFilePath)) { 
        $didPerformSetupActions = $true
        Write-Log "--> Creating bat file..." -Color Yellow
        Set-Content -Path $batFilePath -Value $batFileContent -Encoding Ascii 
    }

    Write-Log "--> Checking readme file..." -Color DarkGray
    if (-not (Test-Path $readmeFile)) { 
        $didPerformSetupActions = $true
        Write-Log "--> Creating readme file..." -Color Yellow
        Set-Content -Path $readmeFile -Value $readmeContent -Encoding utf8 
    }
    Write-Log "--> Checking license file..." -Color DarkGray
    if (-not (Test-Path $licenseFile)) {
        $didPerformSetupActions = $true
        Write-Log "--> Creating license file..." -Color Yellow
        Set-Content -Path $licenseFile -Value $licenseContent -Encoding utf8
    }
    Write-Log "--> File checks complete." -Color DarkGray
    
    if ($didPerformSetupActions -and -not $isCompleteFirstRun) { 
        Write-Log "-> Project structure verified and repaired." -Color Green 
    }

    if (Ensure-EngineExists) { 
        $didPerformSetupActions = $true 
    }

    if ($isCompleteFirstRun) {
        Write-Log "==================== [ INSTALLATION COMPLETE ] ====================" -Color Green
        Write-Log "All necessary folders and files have been set up." -Color Green
        $createShortcut = ""
        while ($createShortcut -ne 'y' -and $createShortcut -ne 'n') {
            $createShortcut = Read-Host "Would you like to create a 'YTall' shortcut on your desktop? [y/n]"
        }
        if ($createShortcut -eq 'y') { 
            try { 
                $wshell = New-Object -ComObject WScript.Shell
                $desktopPath = $wshell.SpecialFolders.Item("Desktop")
                $shortcutPath = Join-Path $desktopPath "YTall.lnk"
                $shortcut = $wshell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = "powershell.exe"
                $shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$PSScriptRoot\run_ytall.ps1`""
                $shortcut.WorkingDirectory = $baseDir
                $shortcut.IconLocation = "System32\imageres.dll,8"
                $shortcut.Save()
                Write-Log "-> Created the 'YTall' shortcut on your desktop." -Color Green 
            } catch { 
                Write-Log "-> Failed to create the shortcut. Error: $_" -Color Red 
            } 
        }
        Write-Log "Opening the README.md file automatically so you can learn how to use the script." -Color Cyan
        try {
            Start-Process notepad.exe $readmeFile
        } catch {
            Write-Log "Failed to open README.md. Please check the file directly in the 'ytall' folder." -Color Red
        }
        Write-Log "Stopping here. Please add links to mp3.txt or mp4.txt and run again." -Color Yellow
        $jobRun = $false
        return
    }
    
    # --- Regular Job Execution ---
    Update-Engine
    
    $config = Parse-Config -FilePath $configFile -Defaults $defaultConfig
    Write-Log "Config loaded. Encoder: $($config.Encoder.ToUpper()), Playlist Processing: $($config.ProcessPlaylists)" -Color Cyan
    
    # Check for free disk space
    try {
        if ($baseDir.StartsWith("\\")) {
            Write-Log "-> Skipping disk space check on UNC path." -Color Yellow
        } else {
            $drive = Get-PSDrive -Name $baseDir.Substring(0, 1)
            $minFreeBytes = [long]([double]$config.MinFreeSpaceGB * 1GB)
            if ($drive.Free -lt $minFreeBytes) {
                $availableGB = [math]::Round($drive.Free / 1GB, 2)
                throw "Insufficient disk space. Available: $($availableGB) GB, Required: $($config.MinFreeSpaceGB) GB. Halting."
            }
            Write-Log "Disk space check passed. Available: $([math]::Round($drive.Free / 1GB, 2)) GB" -Color Green
        }
    } catch {
        if ($_.Exception.Message -like '*Cannot convert value*') {
             Write-Log "[CRITICAL] Invalid value for 'MinFreeSpaceGB' in config.ini. Please use a number (e.g., 2 or 2.5)." -Color Red
        } else {
            Write-Log "[CRITICAL] $_" -Color Red
        }
        $jobRun = $false
        return
    }

    Get-ChildItem -Path $tempDir -File | Remove-Item -Force -ErrorAction SilentlyContinue

    $remainingMp3Urls = [System.Collections.Generic.List[string]]::new()
    if (Test-Path $mp3ListFile) { 
        # Force the result into an array and explicitly cast to [string[]] for type safety with AddRange.
        $mp3content = [string[]]@(
            Get-Content $mp3ListFile -Encoding utf8 |
            Where-Object { $_.Trim() -ne "" } |
            Select-Object -Unique
        )
        if ($mp3content) { 
            $remainingMp3Urls.AddRange($mp3content) 
        } 
    }
    $remainingMp4Urls = [System.Collections.Generic.List[string]]::new()
    if (Test-Path $mp4ListFile) { 
        # Force the result into an array and explicitly cast to [string[]] for type safety with AddRange.
        $mp4content = [string[]]@(
            Get-Content $mp4ListFile -Encoding utf8 |
            Where-Object { $_.Trim() -ne "" } |
            Select-Object -Unique
        )
        if ($mp4content) { 
            $remainingMp4Urls.AddRange($mp4content) 
        } 
    }

    if ($remainingMp3Urls.Count -eq 0 -and $remainingMp4Urls.Count -eq 0) { 
        $jobRun = $false
        Write-Log "No links to process. Exiting."
        return 
    }

    $totalTasks = $remainingMp3Urls.Count + $remainingMp4Urls.Count
    $completedTasks = 0
    Write-Log "Processing $totalTasks total tasks..."

    # --- MP3 Processing ---
    if ($remainingMp3Urls.Count -gt 0) {
        Write-Log "`n1. Starting MP3 processing..."
        Process-UrlType -Type 'mp3' -UrlList $remainingMp3Urls -LinkFile $mp3ListFile -SucceededCount ([ref]$succeededMp3Count) -FailedUrlList $failedMp3Urls
    }

    # --- MP4 Processing ---
    if (-not $haltScript -and $remainingMp4Urls.Count -gt 0) {
        Write-Log "`n2. Starting MP4 processing (Download & Encode)..."
        Process-UrlType -Type 'mp4' -UrlList $remainingMp4Urls -LinkFile $mp4ListFile -SucceededCount ([ref]$succeededMp4Count) -FailedUrlList $failedMp4Urls
    }
}
catch {
    Write-Log "An unexpected terminating error occurred: $($_.Exception.Message)" -Color Red
    Write-Log $_.ToString() -Color Red
}
finally {
    if ($jobRun -and -not $isCompleteFirstRun) {
        if ($config.PlaySoundOnComplete) {
            Write-Log "Playing completion sound..." -Color Cyan
            try { [System.Media.SystemSounds]::Asterisk.Play() } catch {}
        }
        Write-Host ""
        Write-Host "================== FINAL JOB REPORT ==================" -ForegroundColor Magenta
        Write-Host ""
        if ($haltScript) { 
            Write-Log "[HALTED] Script stopped early due to a critical error." -Color Yellow
            Write-Host "" 
        }
        
        Write-Host "[MP3] " -NoNewline; Write-Host "$($succeededMp3Count) succeeded" -ForegroundColor Green -NoNewline; Write-Host ". "; Write-Host "$($failedMp3Urls.Count) failed" -ForegroundColor Red -NoNewline; Write-Host "."
        Write-Host "[MP4] " -NoNewline; Write-Host "$($succeededMp4Count) succeeded" -ForegroundColor Green -NoNewline; Write-Host ". "; Write-Host "$($failedMp4Urls.Count) failed" -ForegroundColor Red -NoNewline; Write-Host "."

        Write-Host "" 
        Write-Host "======================================================" -ForegroundColor Magenta
        Write-Host ""
    }
    Write-Log "Process finished. Press Enter to exit..."
    Read-Host | Out-Null
}