# Create the Policy Key if it doesn't exist
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $registryPath)) { New-Item -Path $registryPath -Force }

# 1. Force InPrivate Mode & Silence Notifications
Set-ItemProperty -Path $registryPath -Name "InPrivateModeAvailability" -Value 2
Set-ItemProperty -Path $registryPath -Name "InPrivateBrowsingNotificationsEnabled" -Value 0

# 2. Disable Password Manager and Saving
Set-ItemProperty -Path $registryPath -Name "PasswordManagerEnabled" -Value 0

# 3. Clear all data on exit
Set-ItemProperty -Path $registryPath -Name "ClearBrowsingDataOnExit" -Value 1

# 4. Disable AI, Sidebar, Copilot, and Wallet
Set-ItemProperty -Path $registryPath -Name "HubsSidebarEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeComposeAllowed" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeWalletExtensionEnabled" -Value 0

# 5. Disable Shopping and Coupons
Set-ItemProperty -Path $registryPath -Name "EdgeShoppingAssistantEnabled" -Value 0

# 6. Force Homepage / Startup (Updated for 25h2)
Set-ItemProperty -Path $registryPath -Name "RestoreOnStartup" -Value 4
Set-ItemProperty -Path $registryPath -Name "NewTabPageLocation" -Value "https://ehraesport.no"
$urlPath = "$registryPath\RestoreOnStartupURLs"
if (!(Test-Path $urlPath)) { New-Item -Path $urlPath -Force }
Set-ItemProperty -Path $urlPath -Name "1" -Value "https://ehraesport.no"

# 7. Disable "First Run Experience" and Welcome Screens
Set-ItemProperty -Path $registryPath -Name "HideFirstRunExperience" -Value 1

# 8. Set Default Search Engine to Google
Set-ItemProperty -Path $registryPath -Name "DefaultSearchProviderEnabled" -Value 1
Set-ItemProperty -Path $registryPath -Name "DefaultSearchProviderSearchURL" -Value "https://www.google.com/search?q={searchTerms}"

Write-Host "Edge er konfigurert for Ehra E-sport."