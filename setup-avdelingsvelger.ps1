# 1. Legg inn riktig
$Sites = @{
    "1" = @{ Code="KVAD"; Name="Kvadrat";      InstallerUrl="https://app.eu.action1.com/agent/c7b8e104-8401-11ee-b219-bd059539eb50/Windows/agent(Ehra_E-sport_Kvadrat).msi" }
    "2" = @{ Code="RAND"; Name="Randaberg";      InstallerUrl="https://app.eu.action1.com/agent/854c5b14-9aa1-11ee-b3d6-d1e2dd4ee5b0/Windows/agent(Ehra_E-sport_Randaberg).msi" }
    "3" = @{ Code="TEST"; Name="Test Avdeling";  InstallerUrl="https://app.eu.action1.com/agent/6cf71114-05fa-11f1-9ae8-b506d187dae7/Windows/agent(Ehra_E-sport_Test_Avdeling).msi" }
}

# 2. The Interactive Menu
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
    Start-Sleep -Seconds 5
    Exit
}

$SiteConfig = $Sites[$Selection]

# 3. Generate Computer Name (SiteCode + SerialNumber or Random)
# Using Get-Random for simplicity, but you could use BIOS SerialNumber
$RandomID = Get-Random -Minimum 1 -Maximum 99
$NewPCName = "EHRA$($SiteConfig.Code)$RandomID"

Write-Host "Setter opp PC'en som: $NewPCName" -ForegroundColor Green

# 4. Rename Computer
Rename-Computer -NewName $NewPCName -Force -ErrorAction SilentlyContinue

# 5. Download and Install Action1
Write-Host "Laster ned Action1 Agent for $($SiteConfig.Name)..."
$InstallerPath = "C:\Windows\Temp\Action1Agent.msi"
Invoke-WebRequest -Uri $SiteConfig.InstallerUrl -OutFile $InstallerPath

Write-Host "Installerer Action1..."
# /qn for quiet install (no UI)
Start-Process "msiexec.exe" -ArgumentList "/i $InstallerPath /qn" -Wait

# 6. Clean Up and Reboot
Write-Host "Installasjon ferdig. Restarter om 10 sekunder..."
Start-Sleep -Seconds 10
Restart-Computer -Force