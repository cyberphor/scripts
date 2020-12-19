
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

function Get-BaselineProcessDeviations {

    # Get-Process | Select -ExpandProperty Name | Sort-Object | Get-Unique |
    # ForEach-Object { "'" + $_ + "'," }
    $BaselineProcesses = 
        'ApplicationFrameHost',
        'csrss',
        'ctfmon',
        'dasHost',
        'dllhost',
        'dwm',
        'explorer',
        'fontdrvhost',
        'Idle',
        'jhi_service',
        'LockApp',
        'lsass',
        'Memory Compression',
        'Microsoft.Photos',
        'ONENOTEM',
        'powershell_ise',
        'Registry',
        'RtkAudUService64',
        'RuntimeBroker',
        'SearchIndexer',
        'SearchUI',
        'SecurityHealthService',
        'SecurityHealthSystray',
        'services',
        'SgrmBroker',
        'ShellExperienceHost',
        'sihost',
        'SkypeApp',
        'SkypeBackgroundHost',
        'smartscreen',
        'smss',
        'spoolsv',
        'svchost',
        'System',
        'SystemSettings',
        'taskhostw',
        'unsecapp',
        'UsbClientService',
        'Video.UI',
        'wininit',
        'winlogon'

    Get-Process |
    ForEach-Object {
        if ($_.Name -notin $BaselineProcesses) {
            $Process = New-Object -TypeName psobject
            Add-Member -InputObject $Process -MemberType NoteProperty -Name StartTime -Value $_.StartTime
            #Add-Member -InputObject $Port -MemberType NoteProperty -Name Hostname -Value $Hostname
            Add-Member -InputObject $Process -MemberType NoteProperty -Name Id -Value $_.Id
            Add-Member -InputObject $Process -MemberType NoteProperty -Name Name -Value $_.Name
            Add-Member -InputObject $Process -MemberType NoteProperty -Name Path -Value $_.Path
            return $Process
        }
    } 
}

function Get-BaselinePortDeviations {

    #Get-NetTCPConnection | Select -ExpandProperty LocalPort | Sort-Object | Get-Unique |
    #ForEach-Object { "'" + $_ + "'," }
    $BaselinePorts = 
        '135',
        '139',
        '443',
        '445'

    Get-NetTCPConnection |
    ForEach-Object {
        if ($_.LocalPort -notin $BaselinePorts) {
            $Port = New-Object -TypeName psobject
            Add-Member -InputObject $Port -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime
            #Add-Member -InputObject $Port -MemberType NoteProperty -Name Hostname -Value $Hostname
            Add-Member -InputObject $Port -MemberType NoteProperty -Name OwningProcess -Value $_.OwningProcess
            Add-Member -InputObject $Port -MemberType NoteProperty -Name LocalPort -Value $_.LocalPort
            Add-Member -InputObject $Port -MemberType NoteProperty -Name RemotePort -Value $_.RemotePort
            Add-Member -InputObject $Port -MemberType NoteProperty -Name RemoteAddress -Value $_.RemoteAddress
            return $Port
        }
    }
}

function Get-BaselineUserDeviations {

    #Get-WmiObject -Class Win32_UserAccount | Select -ExpandProperty Name | Sort-Object | Get-Unique |
    #ForEach-Object { "'" + $_ + "'," }
    $BaselineUsers = 
        'Administrator',
        'Guest',
        'Victor'

    Get-WmiObject -Class Win32_UserAccount  |
    ForEach-Object {
        if ($_.Name -notin $BaselineUsers) {
            $User = New-Object -TypeName psobject
            #Add-Member -InputObject $User -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime
            #Add-Member -InputObject $User -MemberType NoteProperty -Name Hostname -Value $Hostname
            Add-Member -InputObject $User -MemberType NoteProperty -Name Name -Value $_.Name
            Add-Member -InputObject $User -MemberType NoteProperty -Name Sid -Value $_.Sid
            return $User
        }
    }
}

function Get-BaselineAdminDeviations {

    #Get-LocalGroupMember -Group "Administrators" | Select -ExpandProperty Name | 
    #ForEach-Object { "'" + ($_).Split('\')[1] + "'," }
    $BaselineAdmins = 
        'Administrator',
        'Elliot'

    Get-LocalGroupMember -Group "Administrators" | 
    ForEach-Object {
        $Name = ($_.Name).Split('\')[1]
        if ($Name -notin $BaselineAdmins) {
            $Admin = New-Object -TypeName psobject
            #Add-Member -InputObject $User -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime
            #Add-Member -InputObject $User -MemberType NoteProperty -Name Hostname -Value $Hostname
            Add-Member -InputObject $Admin -MemberType NoteProperty -Name Name -Value $_.Name
            Add-Member -InputObject $Admin -MemberType NoteProperty -Name Sid -Value $_.Sid
            return $Admin
        }
    }
}

function New-SystemSecurityBaselineAudit {

    $Dropbox = "C:\Users\Public\BaselineAudit"
    $Folder = $Dropbox + "\BaselineAudit_" + $(Get-Date -Format yyyy-MM-dd-HHmm)
    
    if (-not(Test-Path $Dropbox)) {
        New-Item -ItemType Directory $Dropbox  | 
        Out-Null
    }

    if (-not(Test-Path $Folder)) {
        New-Item -ItemType Directory $Folder  | 
        Out-Null
    }

    Get-BaselineProcessDeviations | Export-Csv -NoTypeInformation -Append -Path "$Folder\Processes.csv"
    Get-BaselinePortDeviations | Export-Csv -NoTypeInformation -Append -Path "$Folder\Ports.csv"
    Get-BaselineUserDeviations | Export-Csv -NoTypeInformation -Append -Path "$Folder\Users.csv"
    Get-BaselineAdminDeviations | Export-Csv -NoTypeInformation -Append -Path "$Folder\Admins.csv"
}

Get-Credentials
New-SystemSecurityBaselineAudit

<#
# SMB USAGE: Local shares
Get-SmbShare | Select Name, Path | Sort-Object -Property Path | Format-Table -AutoSize

# SMB USAGE: Inbound SMB Sessions
Get-SmbSession

# SMB USAGE: Outbound SMB Sessions
net use
#>
