
$Log = ForwardedEvents
$Log = Security
$CsvFilePath = "~/Desktop/LogReview_$(Get-Date -Format yyyymmdd-HHMM).csv"

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

    return $Event 
} 

function New-LogReview {
    Get-WinEvent -LogName $Log | 
    ForEach-Object {
        if ($_.Id -eq 4688) { 
            $_ | 
            Get-ProcessExecution |
            Export-Csv -Append -Path $CsvFilePath
        }
    } 
}

function Export-LogReview {
    $Excel = New-Object -ComObject excel.application
    $Excel.Visible = $true
    $Workbook = $Excel.Workbooks.Add()
    $Sheet = $Workbook.Worksheets.Item(1)
    $Sheet.Name = 'ProcessExecution'

    $Sheet.Cells.Item(1,1) = 'TimeCreated'
    $Sheet.Cells.Item(1,2) = 'RecordId'
    $Sheet.Cells.Item(1,3) = 'UserName'
    $Sheet.Cells.Item(1,4) = 'Sid'
    $Sheet.Cells.Item(1,5) = 'ParentProcessName'
    $Sheet.Cells.Item(1,6) = 'CommandLine'

    $CsvFilePath = '.\ProcessExecution_20202704_061228.csv'
    $Records = Import-Csv -Path $CsvFilePath
    $Offset = 2

    foreach ($Record in $Records) {
        $Record
        $Excel.Cells.Item($Offset,1) = $Record.TimeCreated
        $Sheet.Cells.Item($Offset,2) = $Record.RecordId
        $Sheet.Cells.Item($Offset,3) = $Record.UserName
        $Sheet.Cells.Item($Offset,4) = $Record.Sid
        $Sheet.Cells.Item($Offset,5) = $Record.ParentProcessName
        $Sheet.Cells.Item($Offset,6) = $Record.CommandLine
        $Offset++
    }

    $ExcelFilePath = "./LogReview_$(Get-Date -Format yyyymmdd-HHMM).csv"
    $Workbook.SaveAs($ExcelFilePath)
    $Excel.Quit()
}

<#
REFERENCES
https://social.technet.microsoft.com/Forums/scriptcenter/en-US/2a3abb64-a686-4664-a08f-5a425da831bc/parsing-of-message-field-of-event-log-entry-using-powershell?forum=ITCG
https://powershell.org/forums/topic/get-info-from-an-eventlog-message-generaldetails-pane/
https://community.spiceworks.com/how_to/137203-create-an-excel-file-from-within-powershell
https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1

------------------------
EVENT LOG ANALYSIS
------------------------
 
(QUESTION: FIELD TO PARSE)
Time: TimeCreated
EventId: Id
EventCategory: LevelDisplayName 
UserAccount: UserId; Message - Security ID
Description: Message
Hostname: Message
IpAddress: Message - Source Address, Source Port, Destination Address, Destination Port 
Files: Message
Folders: Message
Printers: Message
Services: Message
#>
