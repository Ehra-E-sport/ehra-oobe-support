#############################################################
# Ehra E-sport
# 
# Dette skriptet forvaltes sentralt og vil utføre følgende:
# 1. Liste med URL'ene du ønsker blokkere
# 2. Slå av "DNS over HTTPS" slik at brukere vil slite med å unngå blokkeringen.
# 3. Oppdatere host filen.
# 4. Til slutt ta en flush av dns for å sikre at endringen trer i kraft umiddelbart etter skriptet har kjørt.
#
# av christer.tysdal@ehraesport.no
#############################################################

# ==========================================================
# 1. URL - Roblox kjente URL'er
# ==========================================================
$blockedList = @(
    "abtesting.roblox.com",
    "api.roblox.com",
    "assetdelivery.roblox.com",
    "assetgame.roblox.com",
    "badges.roblox.com",
    "bronze.roblox.com",
    "c0.rbxcdn.com",
    "c4.rbxcdn.com",
    "c5.rbxcdn.com",
    "c6.rbxcdn.com",
    "captcha.roblox.com",
    "cdg1-128-116-122-3.roblox.com",
    "cdn.arkoselabs.com",
    "chat.roblox.com",
    "chatsite.roblox.com",
    "cientsettings.api.roblox.com",
    "clientsettingscdn.roblox.com",
    "css.rbxcdn.com",
    "ecsv2.roblox.com",
    "ephemeralcounters.api.roblox.com",
    "followings.roblox.com",
    "gameinternationalization.roblox.com",
    "games.roblox.com",
    "images.rbxcdn.com",
    "inventory.roblox.com",
    "js.rbxcdn.com",
    "lax1-128-116-116-3.roblox.com",
    "lms.roblox.com",
    "nrt1-128-116-120-3.roblox.com",
    "presence.roblox.com",
    "realtime.roblox.com",
    "roblox-api.arkoselabs.com",
    "roblox.com",
    "roblox.en.softonic.com",
    "robloxforums.com",
    "setup.rbxcdn.com",
    "setup.roblox.com",
    "static.rbxcdn.com",
    "t0.rbxcdn.com",
    "t2.rbxcdn.com",
    "t3.rbxcdn.com",
    "t5.rbxcdn.com",
    "t7.rbxcdn.com",
    "thumbnails.roblox.com",
    "versioncompatibility.api.roblox.com",
    "web.roblox.com",
    "www.roblox.com"
)

# ==========================================================
# 2. Slå av DNS over HTTPS (DoH)
# ==========================================================
$regPathSystem = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
if (!(Test-Path $regPathSystem)) { New-Item -Path $regPathSystem -Force }
Set-ItemProperty -Path $regPathSystem -Name "EnableAutoDoh" -Value 0 -Type DWord

# Edge
$regPathEdge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (!(Test-Path $regPathEdge)) { New-Item -Path $regPathEdge -Force }
Set-ItemProperty -Path $regPathEdge -Name "BuiltInDnsClientEnabled" -Value 0 -Type DWord

# Chrome
$regPathChrome = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (!(Test-Path $regPathChrome)) { New-Item -Path $regPathChrome -Force }
Set-ItemProperty -Path $regPathChrome -Name "BuiltInDnsClientEnabled" -Value 0 -Type DWord

# ==========================================================
# 3. Oppdatere host filen
# ==========================================================
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

if ((Get-Item $hostsPath).IsReadOnly) {
    Set-ItemProperty -Path $hostsPath -Name IsReadOnly -Value $false
}

foreach ($url in $blockedList) {
    $entry = "127.0.0.1 $url"
    if (!(Select-String -Path $hostsPath -Pattern [regex]::Escape($url) -Quiet)) {
        Add-Content -Path $hostsPath -Value "`n$entry"
        Write-Host "Blokkert: $url"
    }
}

# ==========================================================
# 4. Flush
# ==========================================================
ipconfig /flushdns
Write-Host "Host fil oppdatert og flush av DNS er fullført."
