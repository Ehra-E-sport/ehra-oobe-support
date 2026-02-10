<#
.SYNOPSIS
    Master Setup Controller for Ehra E-sport PCs.
    Handles: Windows Activation, Department Selection (Action1), and Branding.

.NOTES
    Run as Administrator.
#>

# 0. ENSURE ADMIN RIGHTS
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges!"
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "          EHRA E-SPORT PC OPPSETT            " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# --- STEP 1: WINDOWS ACTIVATION MODULE ---
function Invoke-WindowsActivation {
    Write-Host "`n[Step 1] Checking Windows Activation..." -ForegroundColor Yellow

    # Check current status
    $licensing = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey is not null"
    if ($licensing.LicenseStatus -eq 1) {
        Write-Host "   -> Windows is already activated!" -ForegroundColor Green
        return
    }

    Write-Host "   -> Not activated. Attempting BIOS Key retrieval..." -ForegroundColor DarkYellow
    
    # Try to get BIOS Key (OA3x)
    try {
        $biosKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
    } catch {
        $biosKey = $null
    }

    if ([string]::IsNullOrWhiteSpace($biosKey)) {
        Write-Warning "   -> No BIOS Key found."
        
        # PROMPT FOR MAK KEY
        Write-Host "   -> Please enter a valid MAK Key manually:" -ForegroundColor Yellow
        $biosKey = Read-Host "      Key (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)"
    } else {
        Write-Host "   -> Found BIOS Key: $biosKey" -ForegroundColor Cyan
    }

    if (-not [string]::IsNullOrWhiteSpace($biosKey)) {
        Write-Host "   -> Installing Key..."
        cscript /b C:\Windows\System32\slmgr.vbs /ipk $biosKey
        
        Write-Host "   -> Activating Online..."
        cscript /b C:\Windows\System32\slmgr.vbs /ato
        
        # Verify
        $licensing = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey is not null"
        if ($licensing.LicenseStatus -eq 1) {
            Write-Host "   -> Success: Windows is now ACTIVATED." -ForegroundColor Green
        } else {
            Write-Error "   -> Activation failed. Please check the key or internet connection."
        }
    } else {
        Write-Error "   -> No key provided. Skipping activation."
    }
}

# --- STEP 2: DEPARTMENT SELECTION (ACTION1) ---
function Invoke-DepartmentSetup {
    Write-Host "`n[Step 2] Department Configuration" -ForegroundColor Yellow
    
    # Define your Action1 Download Links or IDs here
    $departments = @{
        "1" = @{ Code="KVAD"; Name="Kvadrat";      InstallerUrl="https://app.eu.action1.com/agent/c7b8e104-8401-11ee-b219-bd059539eb50/Windows/agent(Ehra_E-sport_Kvadrat).msi" }
        "2" = @{ Code="RAND"; Name="Randaberg";      InstallerUrl="https://app.eu.action1.com/agent/854c5b14-9aa1-11ee-b3d6-d1e2dd4ee5b0/Windows/agent(Ehra_E-sport_Randaberg).msi" }
        "3" = @{ Code="TEST"; Name="Test Avdeling";  InstallerUrl="https://app.eu.action1.com/agent/6cf71114-05fa-11f1-9ae8-b506d187dae7/Windows/agent(Ehra_E-sport_Test_Avdeling).msi" }
    }

    Write-Host "Select the Department (Avdeling) for this PC:"
    $departments.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host "   [$($_.Key)] $($_.Value.Name)"
    }

    $selection = Read-Host "`nEnter number"

    if ($departments.ContainsKey($selection)) {
        $dept = $departments[$selection]
        Write-Host "   -> Selected: $($dept.Name)" -ForegroundColor Cyan
        Write-Host "   -> Installing Action1 Agent for $($dept.Name)..."
        
        # Example of downloading and running the Action1 installer silently
        # Note: You need to replace the logic below with your specific Action1 install command
        
        # $installerPath = "$env:TEMP\Action1Setup.exe"
        # Invoke-WebRequest -Uri $dept.Action1_Cmd -OutFile $installerPath
        # Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
        
        Write-Host "   -> (Placeholder) Action1 installed for $($dept.Name)." -ForegroundColor Green
    } else {
        Write-Warning "   -> Invalid selection. Skipping Department setup."
    }
}

# --- STEP 3: BRANDING SCRIPT ---
function Invoke-Branding {
    Write-Host "`n[Step 3] Applying Branding (Wallpaper, Themes, Support Info)..." -ForegroundColor Yellow
    
    $brandingUrl = "https://raw.githubusercontent.com/Ehra-E-sport/ehra-oobe-support/refs/heads/main/Setup-EhraPCBranding.ps1"
    
    try {
        # Securely download and run the script from memory without saving to disk
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $scriptContent = Invoke-RestMethod -Uri $brandingUrl
        Invoke-Expression $scriptContent
        Write-Host "   -> Branding script executed successfully." -ForegroundColor Green
    } catch {
        Write-Error "   -> Failed to run Branding script. Check internet connection."
        Write-Error "   -> Error: $_"
    }
}

# --- MAIN EXECUTION FLOW ---

Invoke-WindowsActivation
Invoke-DepartmentSetup
Invoke-Branding

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "         OPPSETT FERDIG - RESTARTER..        " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Pause