$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\ProgramData\EhraMagic\os-cleanupscript.ps1"'
$Trigger = New-ScheduledTaskTrigger -AtLogOn # Note: Windows doesn't have a native 'Logoff' trigger in the simple UI, so we use a Workstation Lock or a specific Event ID.
# Better: Use the Event Trigger for Logoff (Event ID 4647)
$Trigger = New-ScheduledTaskTrigger -AtLogOff 

Register-ScheduledTask -TaskName "EHRA_Magic_Cleanup" -Action $Action -Trigger $Trigger -User "System" -RunLevel Highest