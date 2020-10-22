# ACCOUNTS: Users
Get-WmiObject -Class Win32_UserAccount | Select -ExpandProperty Name

# ACCOUNTS: Local Administrators
net localgroup administrators | Where-Object { $_ -and $_ -notmatch "The command completed successfully." } | Select -Skip 4

# SMB USAGE: Local shares
Get-SmbShare | Select Name, Path | Sort-Object -Property Path | Format-Table -AutoSize

# SMB USAGE: Inbound SMB Sessions
Get-SmbSession

# SMB USAGE: Outbound SMB Sessions
net use

# NETWORK USAGE: TCP Ports
Get-NetTCPConnection
