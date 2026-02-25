# PowerShell script to install Sophos Central Endpoint on Windows (silent)
# Requires Administrator execution
# Tenant-specific URL (update if it changes)

$SophosUrl = "https://dzr-api-amzn-us-west-2-fa88.api-upe.p.hmr.sophos.com/api/download/XXXXXXXXXXXXXXXXXXXXXXX/SophosSetup.exe"
$InstallerPath = "$env:TEMP\SophosSetup.exe"
$LogPath = "$env:TEMP\SophosInstall.log"

# Logging function
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
    Write-Output "$Timestamp - $Message"
}

Write-Log "Starting Sophos installation."

# Check if already installed
$SophosService = Get-Service -Name "Sophos AutoUpdate Service" -ErrorAction SilentlyContinue
if ($SophosService -and $SophosService.Status -eq "Running") {
    Write-Log "Sophos already installed and running."
    exit 0
}

# Download installer
Write-Log "Downloading SophosSetup.exe..."
try {
    Invoke-WebRequest -Uri $SophosUrl -OutFile $InstallerPath -UseBasicParsing
    if (Test-Path $InstallerPath) {
        Write-Log "Download successful."
    } else {
        Write-Error "Download failed."
        exit 1
    }
} catch {
    Write-Log "Download error: $($_.Exception.Message)"
    exit 1
}

# Install silently (uses tenant defaults from link)
Write-Log "Running installer in silent mode..."
$Arguments = @("--quiet", "--noproxydetection")
$Process = Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow

if ($Process.ExitCode -eq 0) {
    Write-Log "Installation completed (code: $($Process.ExitCode)). Reboot recommended."
} else {
    Write-Log "Installation error (code: $($Process.ExitCode)). Check $LogPath."
    exit $Process.ExitCode
}

# Post-install verification (brief wait)
Start-Sleep -Seconds 30
$SophosService = Get-Service -Name "Sophos AutoUpdate Service" -ErrorAction SilentlyContinue
if ($SophosService -and $SophosService.Status -eq "Running") {
    Write-Log "Sophos verified: running correctly."
} else {
    Write-Log "Warning: Service not detected yet (may need reboot)."
}

# Cleanup
Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
Write-Log "Script completed. Log: $LogPath"
