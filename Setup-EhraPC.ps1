<#
.SYNOPSIS
    EHRA E-sport - Master Setup Controller (v3.0)
    Handles: Windows Activation -> Site Selection -> PC Renaming -> Action1 Install -> Branding -> Reboot
#>

# ADMIN CHECK
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Start dette scriptet som Administrator!"
    Start-Sleep -Seconds 3
    Exit
}

# CONFIGURATION
$Sites = @{
    "1" = @{ Code="KVAD"; Name="Kvadrat";        InstallerUrl="https://app.eu.action1.com/agent/c7b8e104-8401-11ee-b219-bd059539eb50/Windows/agent(Ehra_E-sport_Kvadrat).msi" }
    "2" = @{ Code="RAND"; Name="Randaberg";      InstallerUrl="https://app.eu.action1.com/agent/854c5b14-9aa1-11ee-b3d6-d1e2dd4ee5b0/Windows/agent(Ehra_E-sport_Randaberg).msi" }
    "3" = @{ Code="TEST"; Name="Test Avdeling";  InstallerUrl="https://app.eu.action1.com/agent/6cf71114-05fa-11f1-9ae8-b506d187dae7/Windows/agent(Ehra_E-sport_Test_Avdeling).msi" }
}
$BrandingScriptUrl = "https://raw.githubusercontent.com/Ehra-E-sport/ehra-oobe-support/refs/heads/main/Setup-EhraPCBranding.ps1"

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      EHRA E-SPORT - NY PC OPPSETT        " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# WINDOWS ACTIVATION
function Invoke-WindowsActivation {
    Write-Host "`n[Steg 1] Sjekker Windows Lisens..." -ForegroundColor Yellow
    
    $licensing = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey is not null"
    if ($licensing.LicenseStatus -eq 1) {
        Write-Host "   -> Windows er allerede aktivert." -ForegroundColor Green
        return
    }

    Write-Host "   -> Ikke aktivert. Sjekker BIOS for key..."
    try {
        $biosKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
    } catch { $biosKey = $null }

    if ([string]::IsNullOrWhiteSpace($biosKey)) {
        Write-Warning "   -> Ingen BIOS-key funnet."
        $biosKey = Read-Host "   -> Skriv inn MAK key manuelt (XXXXX-XXXXX...)"
    } else {
        Write-Host "   -> Fant BIOS key: $biosKey" -ForegroundColor Cyan
    }

    if (-not [string]::IsNullOrWhiteSpace($biosKey)) {
        Write-Host "   -> Installerer key og aktiverer..."
        cscript /b C:\Windows\System32\slmgr.vbs /ipk $biosKey
        cscript /b C:\Windows\System32\slmgr.vbs /ato
        Write-Host "   -> Aktivering OK." -ForegroundColor Green
    }
}
Invoke-WindowsActivation

# SITE SELECTION
Write-Host "`n[Steg 2] Velg Avdeling" -ForegroundColor Yellow
$Sites.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "   [$($_.Key)] $($_.Value.Name)"
}

$Selection = Read-Host "`nVelg ID"
if (-not $Sites.ContainsKey($Selection)) {
    Write-Error "Ugyldig valg. Avslutter..."
    Start-Sleep -Seconds 3
    Exit
}
$SiteConfig = $Sites[$Selection]
Write-Host "   -> Valgt: $($SiteConfig.Name) (Kode: $($SiteConfig.Code))" -ForegroundColor Green

# PC RENAMING
Write-Host "`n[Steg 3] Konfigurerer PC Navn..." -ForegroundColor Yellow

try {
    $SerialNumber = (Get-CimInstance Win32_Bios -ErrorAction Stop).SerialNumber
} catch { $SerialNumber = "UNKNOWN" }

# Sjekk mot ugyldige serienummer
$BadSerials = @("System Serial Number", "To be filled by O.E.M.", "Default String", "0", "UNKNOWN", "")

if ($BadSerials -contains $SerialNumber) {
    Write-Warning "   -> Ugyldig serienummer ('$SerialNumber'). Genererer tilfeldig ID."
    $ShortID = Get-Random -Minimum 100 -Maximum 999
} else {
    Write-Host "   -> Serienummer: $SerialNumber" -ForegroundColor Gray
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    $HashBytes = $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SerialNumber))
    $IntVal = [BitConverter]::ToUInt16($HashBytes, 0)
    $ShortID = "{0:D3}" -f ($IntVal % 1000)
}

$NewPCName = "EHRA$($SiteConfig.Code)$ShortID"
Write-Host "   -> Nytt PC Navn: $NewPCName" -ForegroundColor Cyan

try {
    if ($env:COMPUTERNAME -ne $NewPCName) {
        Rename-Computer -NewName $NewPCName -Force -ErrorAction Stop
        Write-Host "   -> Navneendring satt til neste omstart." -ForegroundColor Green
    } else {
        Write-Host "   -> PC-navnet er allerede korrekt." -ForegroundColor Gray
    }
} catch {
    Write-Error "   -> Feil ved navneendring: $_"
}

# ACTION1 INSTALL
Write-Host "`n[Steg 4] Installerer Action1 ($($SiteConfig.Name))..." -ForegroundColor Yellow
$InstallerPath = "$env:TEMP\Action1Agent.msi"

try {
    Invoke-WebRequest -Uri $SiteConfig.InstallerUrl -OutFile $InstallerPath -ErrorAction Stop
    
    $Process = Start-Process "msiexec.exe" -ArgumentList "/i `"$InstallerPath`" /qn" -Wait -PassThru
    
    if ($Process.ExitCode -eq 0) {
        Write-Host "   -> Action1 installert!" -ForegroundColor Green
    } else {
        Write-Error "   -> Installasjon feilet. Kode: $($Process.ExitCode)"
    }
} catch {
    Write-Error "   -> Kunne ikke laste ned/installere Action1: $_"
}

# BRANDING SCRIPT
Write-Host "`n[Steg 5] Rebranding..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $BrandingContent = Invoke-RestMethod -Uri $BrandingScriptUrl
    Invoke-Expression $BrandingContent
    Write-Host "   -> Branding OK." -ForegroundColor Green
} catch {
    Write-Error "   -> Branding feilet: $_"
}

# REBOOT
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   OPPSETT FERDIG - RESTARTER OM 10 SEK   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Start-Sleep -Seconds 10
Restart-Computer -Force