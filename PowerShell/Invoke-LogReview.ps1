
function Get-Credentials {
    $UserId = [Security.Principal.WindowsIdentity]::GetCurrent()
    $AdminId = [Security.Principal.WindowsBuiltInRole]::Administrator
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal($UserId)
    $RunningAsAdmin = $CurrentUser.IsInRole($AdminId)
    if (-not $RunningAsAdmin) { 
        Write-Output "`n[x] This script requires administrator privileges.`n"
        break
    }
}

function Get-Logon {
    Param([Parameter(ValueFromPipeline)]$Data)
    $XmlData = [xml]$Data.ToXml()

    $Event = New-Object -TypeName psobject
    Add-Member -InputObject $Event -MemberType NoteProperty -Name TimeCreated -Value $Data.TimeCreated
    Add-Member -InputObject $Event -MemberType NoteProperty -Name RecordId -Value $Data.RecordId
    Add-Member -InputObject $Event -MemberType NoteProperty -Name EventId -Value $Data.Id 
    Add-Member -InputObject $Event -MemberType NoteProperty -Name UserName -Value $XmlData.Event.EventData.Data[5].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name Sid -Value $XmlData.Event.EventData.Data[0].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name LogonType -Value $XmlData.Event.EventData.Data[8].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name IpAddress -Value $XmlData.Event.EventData.Data[18].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name Port -Value $XmlData.Event.EventData.Data[19].'#text'
    return $Event
}

function Get-Logoff {
    Param([Parameter(ValueFromPipeline)]$Data)
    $XmlData = [xml]$Data.ToXml()

    $Event = New-Object -TypeName psobject
    Add-Member -InputObject $Event -MemberType NoteProperty -Name TimeCreated -Value $Data.TimeCreated
    Add-Member -InputObject $Event -MemberType NoteProperty -Name RecordId -Value $Data.RecordId
    Add-Member -InputObject $Event -MemberType NoteProperty -Name EventId -Value $Data.Id 
    Add-Member -InputObject $Event -MemberType NoteProperty -Name UserName -Value $XmlData.Event.EventData.Data[5].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name Sid -Value $XmlData.Event.EventData.Data[0].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name LogonType -Value $XmlData.Event.EventData.Data[10].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name IpAddress -Value $XmlData.Event.EventData.Data[19].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name Port -Value $XmlData.Event.EventData.Data[20].'#text'
    return $Event
}

function Get-ProcessCreation {
    Param([Parameter(ValueFromPipeline)]$Data)
    $XmlData = [xml]$Data.ToXml()

    $Category = 'ProcessCreation'
    $Event = New-Object -TypeName psobject
    Add-Member -InputObject $Event -MemberType NoteProperty -Name TimeCreated -Value $Data.TimeCreated
    Add-Member -InputObject $Event -MemberType NoteProperty -Name RecordId -Value $Data.RecordId
    Add-Member -InputObject $Event -MemberType NoteProperty -Name EventId -Value $Data.Id 
    Add-Member -InputObject $Event -MemberType NoteProperty -Name UserName -Value $XmlData.Event.EventData.Data[1].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name Sid -Value $XmlData.Event.EventData.Data[0].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name ParentProcessName -Value $XmlData.Event.EventData.Data[13].'#text'
    Add-Member -InputObject $Event -MemberType NoteProperty -Name CommandLine -Value $XmlData.Event.EventData.Data[8].'#text'
    return $Event 
}

function New-LogReview {
    $Log = "Security"
    $DateTime = Get-Date -Format yyyy-MM-dd-HHmm
    $SearchCriteria = @{ LogName = $Log; Id = 4624,4625,4688 }
    Get-WinEvent -FilterHashtable $SearchCriteria | 
    ForEach-Object { 
        if ($_.Id -eq '4624') {
            $Category = 'LogonLogoff'
            $_ | 
            Get-Logon | 
            Export-Csv -NoTypeInformation -Append -Path "./$Category-$DateTime.csv"
        } elseif ($_.Id -eq '4625') {
            $Category = 'LogonLogoff'
            $_ | 
            Get-Logoff | 
            Export-Csv -NoTypeInformation -Append -Path "./$Category-$DateTime.csv"
        } elseif ($_.Id -eq '4688') {
            $Category = 'ProcessCreation'
            $_ | 
            Get-ProcessCreation | 
            Export-Csv -NoTypeInformation -Append -Path "./$Category-$DateTime.csv"
        }
    }
}

Get-Credentials
New-LogReview

<#
REFERENCES
https://social.technet.microsoft.com/Forums/scriptcenter/en-US/2a3abb64-a686-4664-a08f-5a425da831bc/parsing-of-message-field-of-event-log-entry-using-powershell?forum=ITCG
https://powershell.org/forums/topic/get-info-from-an-eventlog-message-generaldetails-pane/
https://community.spiceworks.com/how_to/137203-create-an-excel-file-from-within-powershell
https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1
https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4624
#>
