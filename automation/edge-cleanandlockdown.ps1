# 1. Force kill all Edge processes to ensure settings apply
Stop-Process -Name "msedge" -ErrorAction SilentlyContinue

# 2. Set Mandatory Registry Policies
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force }

$settings = @{
    "InPrivateModeAvailability"     = 2     # Forces InPrivate
    "HideFirstRunExperience"        = 1     # No "Welcome to Edge"
    "RestoreOnStartup"              = 4     # Open specific URLs
    "StartupBoostEnabled"           = 0     # Necessary for history wipe on close
    "ContinueRunningInBackground"   = 0     # Forces Edge to actually die when closed
    "ClearBrowsingDataOnExit"       = 1     # Nuclear wipe
    "PasswordManagerEnabled"        = 0     # No password saving
    "EdgeShoppingAssistantEnabled"  = 0     # No coupon popups
    "HubsSidebarEnabled"            = 0     # Kills the sidebar
    "ShowHubsSidebar"               = 0     # Kills the sidebar button
    "EdgeCopilotEnabled"            = 0     # NEW: 2026 Copilot policy
    "VisualSearchEnabled"           = 0     # No AI icons on images
    "EdgeCollectionsEnabled"        = 0     # Removes "Collections" bloat
}

$settings.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path $regPath -Name $_.Key -Value $_.Value
}

# 3. Kill the "History Leak" to Windows Search
# This stops Edge from sharing history with the Windows Start Menu/Search
$winSearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Set-ItemProperty -Path $winSearchPath -Name "ShareBrowsingDataWithWindowsSearchAllowed" -Value 0

# 4. Set the Homepage URLs
$urlPath = "$regPath\RestoreOnStartupURLs"
if (!(Test-Path $urlPath)) { New-Item -Path $urlPath -Force }
Set-ItemProperty -Path $urlPath -Name "1" -Value "https://ehraesport.no"

# 5. Rewrite Shortcuts (Desktop & Public Desktop)
$arguments = "--inprivate --no-first-run --disable-features=msEdgeSidebar,msEdgeCompose,msEdgeWallet https://ehraesport.no"
$WshShell = New-Object -ComObject WScript.Shell
$shortcuts = Get-ChildItem -Path "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop" -Filter "*.lnk"

foreach ($lnk in $shortcuts) {
    $shortcut = $WshShell.CreateShortcut($lnk.FullName)
    if ($shortcut.TargetPath -like "*msedge.exe*") {
        $shortcut.Arguments = $arguments
        $shortcut.Save()
    }
}

Write-Host "Edge has been fully silenced for Ehra E-sport."