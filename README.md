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
Login: central.sophos.com > My Products > Partner Portal  
↓  
My Business > Customers > Select Customer > Launch Customer  
↓  
My Products > Endpoint Protection > Installers  
↓  
Right-click "Download Complete Windows Installer" > Copy link address  

text

**Unique per tenant; expires ~30 days—regen if fails.**  
**Example**: `https://dzr-api-amzn-us-west-2-fa88/XXXXX/SophosSetup.exe`

### 2. Login to ITSupport247 (ConnectWise Automate)
Go to user.itsupport247.net > Connect Asio (or Automation dashboard)
↓
Navigate: Automation > Scripts > New > PowerShell Script

text

### 3. Create & Customize Script
Name: Sophos Endpoint Install - [Customer Name]
Category: Application (for inventory tracking)
Language: PowerShell

text

**Paste this robust script** (replace `$SOPHOS_URL` with Step 1 link):

```powershell
# Sophos Silent Install Script
$SOPHOS_URL = "PASTE_LINK_HERE"
# ... (full script as provided previously)
text
Run As: Local System
Timeout: 900s (15min)
Save > Test Run on single agent
4. Deploy & Schedule
text
Targets: Select client/group (test 1st)
Run Now or Schedule (e.g., off-hours)
Monitor: Agent > Scripts tab > Logs (%ProgramData%\ConnectWise\Logs)
text

**Copy-paste ready for GitHub README.md!** ✅
