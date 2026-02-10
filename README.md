# ehra-oobe-support
Scripts for maintaining Ehra E-sport computers

# How to use ..

## Prepare bootable USB
Prepare USB with W11-25h2 iso.
Copy the autounattend.xml to usb root.

## Boot from USB
Press keystroke when prompted to start install.
No input should be needed before ready in Windows.


# Todo for new EHRA PCs
Auto install Windows 11 with drivers
Create local administrator user "admin" & local standard user "esport"
Disable or turn off ads and AI features




Configure cleanup scripts on logon/logoff
Install apps


## Setup-EhraPC.ps1
Windows Activation: Checks BIOS (OA3x) first. If missing, asks you for a MAK key.
Site Selection: You pick the location (Kvadrat, Randaberg, etc.).
Renaming Logic: It uses your exact hashing method (SHA256) or the random fallback for bad serials to generate EHRA-SITE-XXX.
Action1 Install: Downloads the specific MSI for that site and installs it.
Branding: Downloads and runs your GitHub branding script.
Reboot: Finalizes the rename.