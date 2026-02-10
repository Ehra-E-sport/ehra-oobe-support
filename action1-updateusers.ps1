# Action1 - Update Users

<#
.SYNOPSIS
    Updates passwords for local 'admin' and 'esport' accounts and sets them to never expire.
    
.NOTES
    Designed for Action1 deployment on Windows 11 Home.
    Ensure you define $AdminPassword and $EsportPassword as parameters in Action1.
#>

# 1. Define the target accounts
$AdminUser = "admin"
$EsportUser = "esport"

# 2. Function to handle the update logic to keep the script clean
function Update-LocalAccount {
    param (
        [string]$UserName,
        [string]$NewPassword
    )

    try {
        if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
            # Convert plain text password to SecureString (required by Windows)
            $SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

            # Update the password
            Set-LocalUser -Name $UserName -Password $SecurePassword
            
            # Set 'Password Never Expires' to True
            Set-LocalUser -Name $UserName -PasswordNeverExpires $true

            Write-Host "SUCCESS: Updated password and expiration settings for user '$UserName'."
        }
        else {
            Write-Warning "SKIPPED: User '$UserName' was not found on this computer."
        }
    }
    catch {
        Write-Error "FAILURE: Could not update '$UserName'. Error: $_"
    }
}

# 3. Execution - Action1 will inject the values for these variables if defined in parameters
# If you are testing locally, uncomment the lines below and fill in passwords to test.
# $AdminPassword = "TestPassword123!"
# $EsportPassword = "TestPassword123!"

Write-Host "Starting Account Update..."

# Run for Admin
if ($AdminPassword) {
    Update-LocalAccount -UserName $AdminUser -NewPassword $AdminPassword
} else {
    Write-Warning "Parameter `$AdminPassword is empty. Skipping Admin update."
}

# Run for Esport User
if ($EsportPassword) {
    Update-LocalAccount -UserName $EsportUser -NewPassword $EsportPassword
} else {
    Write-Warning "Parameter `$EsportPassword is empty. Skipping Esport user update."
}