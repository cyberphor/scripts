# ------------------------
# EVENT LOG ANALYSIS
# ------------------------
# 
# QUESTION: FIELD TO PARSE
# Time: TimeCreated
# EventId: Id
# EventCategory: LevelDisplayName 
# UserAccount: UserId; Message - Security ID
# Description: Message
# Hostname: Message
# IpAddress: Message - Source Address, Source Port, Destination Address, Destination Port 
# Files: Message
# Folders: Message
# Printers: Message
# Services: Message

$LogName = 'Security'
$EventId = '4625'

Get-WinEvent -LogName $LogName | 
Where-Object { $_.Id -eq $EventId } |
Select-Object -First 1 | 
Select-Object *
