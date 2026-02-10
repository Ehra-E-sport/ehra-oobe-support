# ==========================================
# EHRA E-sport - Oppsett av ny PC (v2.0)
# ==========================================

# 1. Konfigurasjon
$Sites = @{
    "1" = @{ Code="KVAD"; Name="Kvadrat";      InstallerUrl="https://app.eu.action1.com/agent/c7b8e104-8401-11ee-b219-bd059539eb50/Windows/agent(Ehra_E-sport_Kvadrat).msi" }
    "2" = @{ Code="RAND"; Name="Randaberg";      InstallerUrl="https://app.eu.action1.com/agent/854c5b14-9aa1-11ee-b3d6-d1e2dd4ee5b0/Windows/agent(Ehra_E-sport_Randaberg).msi" }
    "3" = @{ Code="TEST"; Name="Test Avdeling";  InstallerUrl="https://app.eu.action1.com/agent/6cf71114-05fa-11f1-9ae8-b506d187dae7/Windows/agent(Ehra_E-sport_Test_Avdeling).msi" }
}

# 2. Meny
Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   EHRA E-sport - Oppsett av ny PC" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
$Sites.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "Trykk [$($_.Key)] for $($_.Value.Name)"
}
Write-Host ""

$Selection = Read-Host "Velg avdelings ID"

if (-not $Sites.ContainsKey($Selection)) {
    Write-Error "Ugyldig valg. Avslutter.."
    Start-Sleep -Seconds 3
    Exit
}

$SiteConfig = $Sites[$Selection]

# 3. Generering av PC Navn
Write-Host "Henter serienummer..." -ForegroundColor Yellow

try {
    $SerialNumber = (Get-CimInstance Win32_Bios -ErrorAction Stop).SerialNumber
}
catch {
    $SerialNumber = "UNKNOWN"
}

# Liste over vanlige "ugyldige" serienummer
$BadSerials = @("System Serial Number", "To be filled by O.E.M.", "Default String", "0", "UNKNOWN", "")

if ($BadSerials -contains $SerialNumber) {
    Write-Warning "Advarsel: Ugyldig serienummer funnet ('$SerialNumber')."
    Write-Warning "Genererer tilfeldig ID i stedet for hashing for å unngå duplikater."
    # Fallback
    $ShortID = Get-Random -Minimum 100 -Maximum 999
}
else {
    Write-Host "Gyldig serienummer funnet: $SerialNumber" -ForegroundColor Gray
    # Hashing Logic
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    $HashBytes = $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SerialNumber))
    $IntVal = [BitConverter]::ToUInt16($HashBytes, 0)
    $ShortID = "{0:D3}" -f ($IntVal % 1000)
}

$NewPCName = "EHRA$($SiteConfig.Code)$ShortID"
Write-Host "Nytt PC Navn: $NewPCName" -ForegroundColor Green

# 4. Endre Navn
try {
    if ($env:COMPUTERNAME -ne $NewPCName) {
        Rename-Computer -NewName $NewPCName -Force -ErrorAction Stop
        Write-Host "Navneendring vellykket." -ForegroundColor Green
    } else {
        Write-Host "PC-navnet er allerede korrekt." -ForegroundColor Gray
    }
}
catch {
    Write-Error "Kritisk feil: Kunne ikke endre navn på PC. Sjekk tilganger."
    Write-Error $_
    # We continue anyway to try and install the software
}

# 5. Last ned og Installer Action1
$InstallerPath = "C:\Windows\Temp\Action1Agent.msi"

Write-Host "Starter nedlasting av Action1..." -ForegroundColor Yellow

try {
    # Test internet connection first
    $TestConnection = Test-Connection -ComputerName "google.com" -Count 1 -Quiet
    if (-not $TestConnection) { throw "Ingen internettforbindelse oppdaget." }

    Invoke-WebRequest -Uri $SiteConfig.InstallerUrl -OutFile $InstallerPath -ErrorAction Stop
    
    Write-Host "Installerer Action1..." -ForegroundColor Cyan
    $Process = Start-Process "msiexec.exe" -ArgumentList "/i $InstallerPath /qn" -Wait -PassThru
    
    if ($Process.ExitCode -eq 0) {
        Write-Host "Action1 installert vellykket!" -ForegroundColor Green
    } else {
        Write-Error "Installasjon feilet med feilkode: $($Process.ExitCode)"
    }
}
catch {
    Write-Error "Feil under nedlasting/installasjon: $_"
    Write-Warning "Scriptet vil fortsette til omstart, men sjekk Action1 manuelt."
    Start-Sleep -Seconds 5
}

# 6. Clean Up and Reboot
Write-Host "Ferdig. Restarter om 10 sekunder..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force