$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $registryPath)) { New-Item -Path $registryPath -Force }

# --- 1. FORCE HOMEPAGE EVERYWHERE ---
# This forces the "Home" button and the startup behavior to your URL
Set-ItemProperty -Path $registryPath -Name "RestoreOnStartup" -Value 4
Set-ItemProperty -Path $registryPath -Name "HomepageLocation" -Value "https://ehraesport.no"
Set-ItemProperty -Path $registryPath -Name "HomepageIsNewTabPage" -Value 0
$urlPath = "$registryPath\RestoreOnStartupURLs"
if (!(Test-Path $urlPath)) { New-Item -Path $urlPath -Force }
Set-ItemProperty -Path $urlPath -Name "1" -Value "https://ehraesport.no"

# --- 2. KILL HISTORY & BACKGROUND PROCESSES ---
# Startup Boost keeps Edge "alive" in the background, preventing history wipe.
Set-ItemProperty -Path $registryPath -Name "StartupBoostEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "ClearBrowsingDataOnExit" -Value 1
Set-ItemProperty -Path $registryPath -Name "InPrivateModeAvailability" -Value 2

# --- 3. KILL COPILOT & AI COMPLETELY ---
# These are the 25h2 specific keys to remove the Sidebar and Copilot icon
Set-ItemProperty -Path $registryPath -Name "HubsSidebarEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeAssistantEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "ComposeAllowed" -Value 0
Set-ItemProperty -Path $registryPath -Name "VisualSearchEnabled" -Value 0
# This specifically targets the "Discover" (Copilot) button
Set-ItemProperty -Path $registryPath -Name "ShowHubsSidebar" -Value 0

# --- 4. CLEANUP UI ---
Set-ItemProperty -Path $registryPath -Name "HideFirstRunExperience" -Value 1
Set-ItemProperty -Path $registryPath -Name "InPrivateBrowsingNotificationsEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "PasswordManagerEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeShoppingAssistantEnabled" -Value 0

Write-Host "Aggressive Edge Lockdown Applied. Restart Edge to see changes."