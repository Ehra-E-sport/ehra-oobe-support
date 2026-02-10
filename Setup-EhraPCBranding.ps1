# Setup-EhraPCBranding

# --- Configuration ---
$imageUrl     = "https://ehbranding.blob.core.windows.net/backgrounds/ehra_background_color_03_1920x1080.png"
$savePath     = "C:\Windows\lockscreen.png"
$registryCSP  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$registryPol  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$contentPath  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

# 1. Download the image (Ensure C:\Windows is accessible; requires Admin)
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $savePath -ErrorAction Stop
    $absolutePath = (Get-Item $savePath).FullName
    Write-Host "Image saved successfully to $absolutePath" -ForegroundColor Green
} catch {
    Write-Error "Failed to download image: $($_.Exception.Message)"
    exit
}

# 2. Apply PersonalizationCSP Settings (Local Machine)
if (-not (Test-Path $registryCSP)) { New-Item -Path $registryCSP -Force | Out-Null }

Set-ItemProperty -Path $registryCSP -Name "LockScreenImage"       -Value $absolutePath -Type String
Set-ItemProperty -Path $registryCSP -Name "LockScreenImagePath"   -Value $absolutePath -Type String
Set-ItemProperty -Path $registryCSP -Name "LockScreenImageUrl"    -Value $absolutePath -Type String
Set-ItemProperty -Path $registryCSP -Name "LockScreenImageStatus" -Value 1             -Type DWord

# 3. Apply Group Policy Overrides (Force the image and lock it)
if (-not (Test-Path $registryPol)) { New-Item -Path $registryPol -Force | Out-Null }

Set-ItemProperty -Path $registryPol -Name "LockScreenImage"      -Value $absolutePath -Type String
Set-ItemProperty -Path $registryPol -Name "NoChangingLockScreen" -Value 1             -Type DWord

Write-Host "Lock screen configuration complete. A restart or logoff may be required." -ForegroundColor Cyan