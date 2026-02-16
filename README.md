# Improved Guide: Deploy Sophos Endpoint via ITSupport247 (ConnectWise Automate)

**Author**: Luis Lazo  
**Collaborators**: George Udosen (Teacher), Perplexity AI  
**Date**: Feb 15, 2026  
**Purpose**: Silently push Sophos Central Endpoint to Windows devices per customer tenant using PowerShell in ITSupport247 (ConnectWise Automate CC/Asio).

## Prerequisites
- Sophos Central **Partner** access
- ITSupport247 login (`user.itsupport247.net`)
- Test on 1-2 clean VMs first (no existing AV)
- Run as **Local System** (default in Automate)

## Step-by-Step Instructions

### 1. Get Tenant-Specific Installer Link
Login: central.sophos.com > My Products > Partner Portal > My Business > Customers  
![customer](/images/customer.png)  
↓  
> Select Customer > Launch Customer  
![lauch](/images/launch.png)  
↓  
My Products > Endpoint Protection > Installers  
![installers](/images/installers.png)  
↓  
Right-click "Download Complete Windows Installer" > Copy link address
![copy](/images/link.png)

**Unique per tenant; expires ~30 days—regen if fails.**  
**Example**: `https://dzr-api-amzn-us-west-2-fa88/XXXXX/SophosSetup.exe`

### 2. Login to ITSupport247 (ConnectWise Automate)
Go to user.itsupport247.net > Connect Asio (or Automation dashboard)  
![task](/images/task.png)  
↓
Navigate: Automation > Scripts > New > PowerShell Script  
![script](/images/script.png)  


### 3. Create & Customize Script
Name: Sophos Endpoint Install - [Customer Name]
Category: Application (for inventory tracking)
Language: PowerShell

![save](/images/save.png)  

**Paste this robust script** (replace `$SOPHOS_URL` with Step 1 link):

# PowerShell script to install Sophos Central Endpoint on Windows (silent)
# Requires Administrator execution
# Tenant-specific URL (update if it changes)

$SophosUrl = "https://dzr-api-amzn-us-west-2-fa88.api-upe.p.hmr.sophos.com/api/download/d2470ade9216b9781c5096e328b5c3d3/SophosSetup.exe"
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
