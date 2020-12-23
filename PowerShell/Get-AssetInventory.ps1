Param(
    [string]$File,
    [ipaddress]$NetworkId,
    [switch]$ExportToFile
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

function Get-Assets {
    if ($File) {
        $Addresses = Get-Content $File
    } elseif ($NetworkId) {
        $Addresses = @()
        1..254 |
        ForEach-Object {
            $Addresses += $NetworkId -replace ".$","$_"
        }
    } else {
        $Addresses = @()
        $NetworkId = 
            '192.168.2.0',
            '192.168.3.0'
        $NetworkId |
        ForEach-Object {
            $Network = $_
            99..100 |
            ForEach-Object {
                $Addresses += $Network -replace ".$","$_"
            }
        }
    }
        
    $Addresses | 
    ForEach-Object {
        $Timeout = 50
        $Ping = New-Object System.Net.NetworkInformation.Ping
        $Status = $Ping.Send($_, $Timeout).Status
        if ($Status -eq 'Success') {
            Start-Job -Name $_ -ArgumentList $_ -ScriptBlock {
                $IpAddress = $args[0] 
                $HostName = (Resolve-DnsName $args[0] -ErrorAction Ignore).NameHost
                if ($HostName) {
                    Invoke-Command -ComputerName $HostName -ArgumentList $IpAddress,$HostName -ErrorAction Ignore -ScriptBlock {
                        $IpAddress = $args[0]
                        $MacAddress = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | 
                            Where-Object { $_.IpAddress -eq $IpAddress } | 
                            Select -ExpandProperty MacAddress
                        $SerialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
                        $UserName = (Get-WmiObject -Class Win32_ComputerSystem).UserName
                        $MacAddress,$args[1],$SerialNumber,$UserName
                    }
                } 
            } | Out-Null
            
            $Asset = New-Object -TypeName psobject
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name Address -Value $_
            return $Asset
        }
    }
}

function Get-Attributes {
    Param([Parameter(ValueFromPipeline)]$Asset)
    Process {
        While ((Get-Job -Name $Asset.Address).State -ne 'Completed') {
            Start-Sleep -Milliseconds 50
        }

        $Attributes = (Receive-Job -Name $Asset.Address)
        Remove-Job -Name $Asset.Address

        if ($Attributes -ne $null) {
            $MacAddress = $Attributes[0]
            $HostName = $Attributes[1]
            $SerialNumber = $Attributes[2]
            $UserName = $Attributes[3]
        } else {
            $MacAddress = '-'
            $HostName = '-'
            $SerialNumber = '-'
            $UserName = '-'
        }

        Add-Member -InputObject $Asset -MemberType NoteProperty -Name MacAddress -Value $MacAddress
        Add-Member -InputObject $Asset -MemberType NoteProperty -Name HostName -Value $HostName
        Add-Member -InputObject $Asset -MemberType NoteProperty -Name SerialNumber -Value $SerialNumber
        Add-Member -InputObject $Asset -MemberType NoteProperty -Name UserName -Value $UserName
        Clear-Variable MacAddress,HostName,SerialNumber,UserName
        $Asset
    }
}

function New-AssetInventory {
    Get-Assets |
    Get-Attributes |
    Sort-Object { $_.Address -as [Version] }
}

Get-Credentials
if ($ExportToFile) {
    $Dropbox = "C:\Users\Public\Documents\AssetInventory\"
    if (-not(Test-Path $Dropbox)) {
        New-Item -ItemType Directory $Dropbox  | 
        Out-Null
    }
    $CsvFile = $Dropbox + "AssetInventory_$(Get-Date -Format yyyy-MM-dd_hhmm).csv"
    New-AssetInventory |
    Export-Csv -NoTypeInformation $CsvFile
    Invoke-Item $Dropbox 
} else {
    New-AssetInventory |
    Format-Table -AutoSize
}

<# REFERENCES
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
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7.1
#>
