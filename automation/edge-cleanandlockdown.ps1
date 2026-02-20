# Create the Policy Key if it doesn't exist
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# 1. Force InPrivate Mode (Users cannot open normal windows)
# 0 = Enabled, 1 = Disabled, 2 = Forced
Set-ItemProperty -Path $registryPath -Name "InPrivateModeAvailability" -Value 2

# 2. Disable Password Manager and Saving
Set-ItemProperty -Path $registryPath -Name "PasswordManagerEnabled" -Value 0

# 3. Clear all data on exit (History, Cookies, Cache, etc.)
Set-ItemProperty -Path $registryPath -Name "ClearBrowsingDataOnExit" -Value 1

# 4. Disable AI, Sidebar, and Copilot features
Set-ItemProperty -Path $registryPath -Name "HubsSidebarEnabled" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeComposeAllowed" -Value 0
Set-ItemProperty -Path $registryPath -Name "EdgeWalletExtensionEnabled" -Value 0

# 5. Disable Shopping and Coupons
Set-ItemProperty -Path $registryPath -Name "EdgeShoppingAssistantEnabled" -Value 0

# 6. Set Homepage and Restore on Startup
Set-ItemProperty -Path $registryPath -Name "RestoreOnStartup" -Value 4
New-Item -Path "$registryPath\RestoreOnStartupURLs" -Force
Set-ItemProperty -Path "$registryPath\RestoreOnStartupURLs" -Name "1" -Value "https://ehraesport.no"

# 7. Disable "First Run Experience" and Welcome Screens
Set-ItemProperty -Path $registryPath -Name "HideFirstRunExperience" -Value 1

# 8. Set Default Search Engine to Google (Optional, but cleaner)
Set-ItemProperty -Path $registryPath -Name "DefaultSearchProviderEnabled" -Value 1
Set-ItemProperty -Path $registryPath -Name "DefaultSearchProviderSearchURL" -Value "https://www.google.com/search?q={searchTerms}"

Write-Host "Edge er konfigurert for Ehra E-sport."