<#
.SYNOPSIS
    Obtains information about computers online and within the specified network range. 
.EXAMPLE
    ./Get-AssetInventory.ps1 -FirstAddress 192.168.2.1 -LastAddress 192.168.2.254

    IpAddress    MacAddress        HostName SerialNumber   UserName       DateTimeAdded    DateTimeModified
    ---------    ----------        -------- ------------   --------       -------------    ----------------
    192.168.2.1  -                 -        -              -              2020-12-31 17:44 -               
    192.168.2.3  -                 -        -              -              2021-01-01 09:14 -                                     
    192.168.2.57 -                 -        -              -              2020-12-31 17:44 -               
    192.168.2.60 -                 -        -              -              2021-01-01 09:33 -                             
    192.168.2.75 aa:bb:cc:11:22:33 Windows  T6UsW9N8       WINDOWS\Victor 2020-12-31 17:44 2021-01-01 09:30
.INPUTS
    None.
.OUTPUTS
    None.
.LINK
    https://www.github.com/cyberphor/scripts/PowerShell/Get-AssetInventory.ps1
.NOTES
    File name: Get-AssetInventory.ps1
    Version: 7.2
    Author: Victor Fernandez III
    Creation Date: Tuesday, December 31,2020
    References:
        https://devblogs.microsoft.com/scripting/parallel-processing-with-jobs-in-powershell/
        https://social.technet.microsoft.com/Forums/Lync/en-US/ff644fca-1b25-4c8a-9a8a-ce90eb024389/in-powershell-how-do-i-pass-startjob-arguments-to-a-script-using-param-style-arguments?forum=ITCG
        https://stackoverflow.com/questions/8751187/how-to-capture-the-exception-raised-in-the-scriptblock-of-start-job
        https://ss64.com/ps/start-job.html
        https://codeandkeep.com/PowerShell-Get-Subnet-NetworkID/
        https://stackoverflow.com/questions/27613836/how-to-pass-multiple-objects-via-the-pipeline-between-two-functions-in-powershel
        https://info.sapien.com/index.php/scripting/scripting-how-tos/take-values-from-the-pipeline-in-powershell
        https://stackoverflow.com/questions/48946924/powershell-function-not-accepting-array-of-objects
        https://www.reddit.com/r/PowerShell/comments/6eyhpv/whats_the_quickest_way_to_ping_a_computer/
        https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/sort-ipv4-addresses-correctly
        https://www.sans.org/reading-room/whitepapers/critical/leveraging-asset-inventory-database-37507
        https://stackoverflow.com/questions/17696149/invoke-command-in-a-background-job
        https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7.1
        https://devblogs.microsoft.com/scripting/two-simple-powershell-methods-to-remove-the-last-letter-of-a-string/
        https://www.pluralsight.com/blog/tutorials/measure-powershell-scripts-speed
        https://stackoverflow.com/questions/34113755/need-to-make-a-powershell-script-faster/34114444
        https://gallery.technet.microsoft.com/scriptcenter/Fast-asynchronous-ping-IP-d0a5cf0e
        https://stackoverflow.com/questions/55971796/powershell-parameters-validation-and-positioning
#>

Param(
    [Parameter(Mandatory, Position = 0)][System.Net.IPAddress]$FirstAddress,
    [Parameter(Mandatory, Position = 1)][System.Net.IPAddress]$LastAddress
)

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

function Get-AssetInventory($FirstAddress, $LastAddress) {
    # if input has /, generate a range
    # if input has -, split into a range
    # if two addresses, generate a range
    # add column for device class, description, notes, etc.
    # add output to highlight what changed

    $Inventory = './AssetInventory.csv'
    if (Test-Path $Inventory) {
        $Inventory = Import-Csv $Inventory 
    } else { New-Item -ItemType File -Name $Inventory }

    $FirstNetworkID = $FirstAddress.ToString().Split('.')[0..2] -join '.'
    $LastNetworkID = $LastAddress.ToString().Split('.')[0..2] -join '.'

    if ($EndNetworkID -eq $StartNetworkID) {
        $Addresses = @()
        $FirstAddress.ToString().Split('.')[3]..$LastAddress.ToString().Split('.')[3] |
        foreach { 
            $Address = $FirstNetworkID + '.' + $_ 
            $Addresses += $Address
        }
        $Headcount = $Addresses.Count
    } else { break }

    Get-Event -SourceIdentifier "Ping-*" | Remove-Event
    Get-EventSubscriber -SourceIdentifier "Ping-*" | Unregister-Event

    $Addresses | 
    foreach {
        [string]$Event = "Ping-" + $_
        New-Variable -Name $Event -Value (New-Object System.Net.NetworkInformation.Ping)
        Register-ObjectEvent -InputObject (Get-Variable $Event -ValueOnly) -EventName PingCompleted -SourceIdentifier $Event
        (Get-Variable $Event -ValueOnly).SendAsync($_,2000,$Event)
        Remove-Variable $Event
    }

    while ($Pending -lt $Headcount) {
        Wait-Event -SourceIdentifier "Ping-*" | Out-Null
        Start-Sleep -Milliseconds 10
        $Pending = (Get-Event -SourceIdentifier "Ping-*").Count
    }

    $Assets = @()
    Get-Event -SourceIdentifier "Ping-*" | 
    foreach { 
        if ($_.SourceEventArgs.Reply.Status -eq 'Success') {
            $Asset = New-Object -TypeName psobject
            $IpAddress = ($_.SourceEventArgs.Reply).Address.IpAddressToString
            Remove-Event $_.SourceIdentifier
            Unregister-Event $_.SourceIdentifier
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name IpAddress -Value $IpAddress
            $Assets += $Asset
        }
    }

    $Assets |
    foreach {
        Start-Job -Name "Query-$_.IpAddress" -ArgumentList $_.IpAddress -ScriptBlock {
            $IpAddress = $args[0]
            $Hostname = [System.Net.Dns]::GetHostEntryAsync($IpAddress).Result.HostName
            if ($Hostname -eq $null) {
                $Hostname, $MacAddress, $SerialNumber, $UserName = '-', '-', '-', '-'
            } else { 
                $Query = Invoke-Command -ComputerName $Hostname -ArgumentList $IpAddress -ErrorAction Ignore -ScriptBlock {
                    $IpAddress = $args[0]
                    Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IpAddress -eq $IpAddress } | 
                            Select -ExpandProperty MacAddress
                    (Get-WmiObject -Class Win32_BIOS).SerialNumber
                    (Get-WmiObject -Class Win32_ComputerSystem).UserName
                }
                if ($Query -eq $null) {
                    $MacAddress, $SerialNumber, $UserName = '-', '-', '-'
                } else { 
                    $MacAddress, $SerialNumber, $UserName = $Query[0], $Query[1], $Query[2]
                }
            }
            return $Hostname,$MacAddress,$SerialNumber,$UserName
        } | Out-Null
    }

    While ((Get-Job -Name "Query-*").State -ne 'Completed') { Start-Sleep -Milliseconds 10 }

    $Assets |
    foreach {
        $Job = Receive-Job -Name "Query-$_.IpAddress"
        $Now = $_
        $Then = $Inventory | Where-Object { $_.IpAddress -eq $Now.IpAddress }
        Add-Member -InputObject $Now -MemberType NoteProperty -Name MacAddress -Value $Job[1]
        Add-Member -InputObject $Now -MemberType NoteProperty -Name HostName -Value $Job[0]
        Add-Member -InputObject $Now -MemberType NoteProperty -Name SerialNumber -Value $Job[2]
        Add-Member -InputObject $Now -MemberType NoteProperty -Name UserName -Value $Job[3]
        
        if ($Then) {
            Add-Member -InputObject $Now -MemberType NoteProperty -Name DateTimeAdded $Then.DateTimeAdded
            if ($Now.MacAddress -ne $Then.MacAddress -or
                $Now.Hostname -ne $Then.Hostname -or 
                $Now.SerialNumber -ne $Then.SerialNumber -or 
                $Now.UserName -ne $Then.Username) {
                Add-Member -InputObject $Now -MemberType NoteProperty -Name DateTimeModified -Value $(Get-Date -Format 'yyyy-MM-dd HH:mm')
            } else {
                Add-Member -InputObject $Now -MemberType NoteProperty -Name DateTimeModified -Value $Then.DateTimeModified
            }
        } else {
            Add-Member -InputObject $Now -MemberType NoteProperty -Name DateTimeAdded -Value $(Get-Date -Format 'yyyy-MM-dd HH:mm')
            Add-Member -InputObject $Now -MemberType NoteProperty -Name DateTimeModified -Value '-'
        }
    }
    Remove-Job -Name "Query-*"
    $Assets | Sort-Object { $_.IpAddress -as [Version] } | Export-Csv -NoTypeInformation './AssetInventory.csv'
    $Assets | Sort-Object { $_.IpAddress -as [Version] } | Format-Table -AutoSize
}

Get-Credentials
Get-AssetInventory $FirstAddress $LastAddress 
