# 1. Powershell script som skal kjøres ved oppstart for å tømme alle brukerens mapper og Recycle Bin, samt rydde opp i Edge data. Dette er en "Deep Clean" for å sikre at ingen personlige data eller filer blir liggende igjen etter bruk.
# 2. Skriptet lagres i ProgramData og kjøres via en Scheduled Task som kjører ved oppstart under SYSTEM-kontoen for å sikre at det har nødvendige rettigheter og kjøres uansett hvilken bruker som logger inn.
$scriptContent = @'
# Stop any pre-launched Edge processes
Stop-Process -Name "msedge", "SearchHost" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Target all local user profiles (skipping system accounts)
$UserProfiles = Get-ChildItem "C:\Users" | Where-Object { $_.Name -notmatch "Public|Default|All Users|Administrator" }

foreach ($Profile in $UserProfiles) {
    $PPath = $Profile.FullName
    
    # --- 1. EDGE CLEANUP & FIRST-RUN BYPASS ---
    $edgePath = "$PPath\AppData\Local\Microsoft\Edge\User Data"
    if (Test-Path $edgePath) {
        Remove-Item -Path $edgePath -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Create marker so Edge doesn't show the Welcome Wizard
    New-Item -Path "$edgePath\Default" -ItemType Directory -Force -ErrorAction SilentlyContinue
    New-Item -Path "$edgePath\First Run" -ItemType File -Force -ErrorAction SilentlyContinue

    # --- 2. USER FOLDER WIPE (Documents, Downloads, etc.) ---
    # We delete the CONTENTS of these folders, not the folders themselves
    $FoldersToEmpty = @(
        "Documents",
        "Downloads",
        "Music",
        "Pictures",
        "Videos",
        "Desktop",
        "AppData\Local\Temp"
    )

    foreach ($SubFolder in $FoldersToEmpty) {
        $Target = Join-Path $PPath $SubFolder
        if (Test-Path $Target) {
            Get-ChildItem -Path $Target -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- 3. SYSTEM-WIDE RECYCLE BIN WIPE ---
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
'@

# 2. Lagre script i programdata
$scriptPath = "C:\ProgramData\EhraMagic\os-cleanupscript.ps1"
$scriptContent | Out-File -FilePath $scriptPath -Force -Encoding UTF8

# 3. Scheduled Task (Trigger: At Startup)
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

Register-ScheduledTask -TaskName "EHRA_MAGIC_WIPE" `
                       -Action $Action `
                       -Trigger $Trigger `
                       -User "SYSTEM" `
                       -RunLevel Highest `
                       -Force

Write-Host "Ehra Deep Cleanup Task Registered. Recycle bin and all user folders will be emptied on reboot."