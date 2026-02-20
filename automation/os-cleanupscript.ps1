# 1. Force kill processes that lock folders
$Targets = "msedge", "mscorsvw", "SearchHost", "StartMenuExperienceHost", "Widgets"
Stop-Process -Name $Targets -Force -ErrorAction SilentlyContinue

# 2. Define the folders to wipe
$UserPath = "$env:LOCALAPPDATA"
$WipeList = @(
    "$UserPath\Microsoft\Edge\User Data",        # All Edge History/Profiles
    "$env:APPDATA\Microsoft\Teams",              # Teams Cache
    "$UserPath\Temp",                            # System Temp
    "$UserPath\Microsoft\Windows\History",       # Windows Explorer History
    "$UserPath\ConnectedDevicesPlatform"         # "Continue where you left off" data
)

# 3. Execute the wipe
foreach ($Folder in $WipeList) {
    if (Test-Path $Folder) {
        Remove-Item -Path "$Folder\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Clear the Recent Files list
$Recent = [Environment]::GetFolderPath("Recent")
Remove-Item -Path "$Recent\*" -Recurse -Force -ErrorAction SilentlyContinue