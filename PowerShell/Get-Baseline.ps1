# Accounts
Get-WmiObject -Class Win32_UserAccount | Select -ExpandProperty Name
net localgroup Administrators