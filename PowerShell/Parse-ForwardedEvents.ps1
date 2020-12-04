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

function Get-ProcessExecution {
    Param([Parameter(ValueFromPipeline)]$Data)
    $XmlData = [xml]$Data.ToXml()

    $Event = New-Object -TypeName psobject -Property @{
        TimeCreated = $Data.TimeCreated 
        RecordId = $Data.RecordId 
        UserName = $XmlData.Event.EventData.Data[1].'#text'
        Sid = $XmlData.Event.EventData.Data[0].'#text'
        ParentProcessName = $XmlData.Event.EventData.Data[13].'#text'
        CommandLine = $XmlData.Event.EventData.Data[8].'#text'
    }

    $Event | 
    ConvertTo-Csv -NoTypeInformation | 
    Select-Object -Skip 1 |
    Out-File ProcessExecution_$(Get-Date -Format yyyymmdd_HHMM).csv -Append
} 

function Get-LogonFailure {
    
}

Get-WinEvent -LogName ForwardedEvents | 
ForEach-Object {
    if ($_.Id -eq 4688) { $_ | Get-ProcessExecution }
    if ($_.Id -eq 4625) { $_ | Get-LogonFailure }
} 

# REFERENCES
# https://social.technet.microsoft.com/Forums/scriptcenter/en-US/2a3abb64-a686-4664-a08f-5a425da831bc/parsing-of-message-field-of-event-log-entry-using-powershell?forum=ITCG
# https://powershell.org/forums/topic/get-info-from-an-eventlog-message-generaldetails-pane/
