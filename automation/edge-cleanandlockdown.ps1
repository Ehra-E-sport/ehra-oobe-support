# 1. Kill Edge and all its background helpers
Stop-Process -Name "msedge" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2 # Give it a moment to release file locks

# 2. THE NUCLEAR OPTION: Wipe the User Data / History Cache
# This deletes the 'Default' profile folder where history/cookies live.
$edgeUserDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
if (Test-Path $edgeUserDataPath) {
    Remove-Item -Path $edgeUserDataPath -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Hard-Set Registry Policies (Targeting HKLM to override users)
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force }

$settings = @{
    "InPrivateModeAvailability"     = 2
    "HideFirstRunExperience"        = 1
    "RestoreOnStartup"              = 4
    "StartupBoostEnabled"           = 0
    "ContinueRunningInBackground"   = 0
    "ClearBrowsingDataOnExit"       = 1
    "HubsSidebarEnabled"            = 0
    "ShowHubsSidebar"               = 0
    "EdgeAssistantEnabled"          = 0 
    "EdgeCopilotEnabled"            = 0 # The specific 2026 toggle
    "ComposeAllowed"                = 0
    "UserFeedbackAllowed"           = 0 # Stops 'How is Edge?' prompts
}

$settings.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path $regPath -Name $_.Key -Value $_.Value
}

# 4. Kill the Bing/Copilot "Discovery" Button Specifically
$bingPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended"
if (!(Test-Path $bingPath)) { New-Item -Path $bingPath -Force }
Set-ItemProperty -Path $bingPath -Name "HubsSidebarEnabled" -Value 0

# 5. Fix Shortcuts with "Super Arguments"
$arguments = "--inprivate --no-first-run --no-default-browser-check --disable-features=msEdgeSidebar,msEdgeCompose,msSidebarSearch,msEdgeWallet https://ehraesport.no"
$WshShell = New-Object -ComObject WScript.Shell
$shortcuts = Get-ChildItem -Path "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop" -Filter "*.lnk"

foreach ($lnk in $shortcuts) {
    $shortcut = $WshShell.CreateShortcut($lnk.FullName)
    if ($shortcut.TargetPath -like "*msedge.exe*") {
        $shortcut.Arguments = $arguments
        $shortcut.Save()
    }
}

Write-Host "Edge has been fully reset and locked for EHRA Esport."