# 1. Kill all running Edge processes so settings can apply
Stop-Process -Name "msedge" -ErrorAction SilentlyContinue

# 2. Hard-Set Registry Policies (Targeting the 'Mandatory' hive)
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force }

$settings = @{
    "InPrivateModeAvailability" = 2
    "HideFirstRunExperience" = 1
    "RestoreOnStartup" = 4
    "StartupBoostEnabled" = 0
    "HubsSidebarEnabled" = 0
    "EdgeShoppingAssistantEnabled" = 0
    "PasswordManagerEnabled" = 0
    "ClearBrowsingDataOnExit" = 1
}

$settings.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path $regPath -Name $_.Key -Value $_.Value
}

# 3. Rewrite Shortcuts (Desktop & Taskbar)
# This forces Edge to launch with specific 'Arguments'
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$arguments = "--inprivate --no-first-run --disable-features=msEdgeSidebar,msEdgeCompose https://ehraesport.no"

$WshShell = New-Object -ComObject WScript.Shell
$shortcuts = Get-ChildItem -Path "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop" -Filter "*.lnk"

foreach ($lnk in $shortcuts) {
    $shortcut = $WshShell.CreateShortcut($lnk.FullName)
    if ($shortcut.TargetPath -like "*msedge.exe*") {
        $shortcut.Arguments = $arguments
        $shortcut.Save()
    }
}

Write-Host "Edge has been lobotomized and shortcuts updated for EHRA Esport."