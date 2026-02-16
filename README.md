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

ver [script](script.ps1)  


# Cleanup
Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
Write-Log "Script completed. Log: $LogPath"
