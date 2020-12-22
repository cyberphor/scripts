Param(
    [switch]$ExportToCsvFile,
    [string]$File
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
        $Assets = Get-Content $File
    } else { 
        $Assets = $(
            '192.168.3.1',
            '192.168.3.2',
            '192.168.3.3',
            '192.168.3.100'
            '192.168.2.75',
            '192.168.24.1',
            '192.168.148.1'
        )
    }
        
    return $Assets
}

function Get-Addresses {
    Param([Parameter(ValueFromPipeline)]$Assets)
    Process {
        $Jobs = @()
        $Addresses = @()
        
        $Assets | 
        ForEach-Object {      
            Start-Job -Name $_ -ArgumentList $_ -ScriptBlock { 
                $Timeout = 50
                $Ping = New-Object System.Net.NetworkInformation.Ping
                $Ping.Send($args[0], $Timeout)
            } | Out-Null
            $Jobs += $_
        }

        While ((Get-Job).State -ne 'Completed') {
            Start-Sleep -Seconds 1
        }

        $Jobs | 
        ForEach-Object {
            $Status = (Receive-Job -Name $_ -ErrorAction Ignore).Status
            if ($Status -eq 'Success') {
                $Addresses += $_
            }
        }

        return $Addresses
    }
}

function Get-Names {
    Param([Parameter(ValueFromPipeline)]$Addresses)
    Process {
        $Jobs = @()
        $Names = @()
        
        $Addresses | 
        ForEach-Object {      
            Start-Job -Name $_ -ArgumentList $_ -ScriptBlock { 
                Resolve-DnsName $args[0] -ErrorAction Ignore
                #Resolve-DnsName $args[0] -DnsOnly -ErrorAction Ignore
            } | Out-Null
            $Jobs += $_
        }

        While ((Get-Job).State -ne 'Completed') {
            Start-Sleep -Seconds 1
        }

        $Jobs | 
        ForEach-Object {
            $Name = (Receive-Job -Name $_ -ErrorAction Ignore).NameHost
            $Names += $Name
        }

        return $Names
    }
}

function Get-AssetInventory {
    Param([Parameter(ValueFromPipeline)]$Names)
    Process {
        $Jobs = @()
        $AssetInventory = @()
        
        $Names | 
        ForEach-Object {
            Start-Job -Name $_ -ArgumentList $_ -ScriptBlock {
                Invoke-Command -ComputerName $args[0] -ScriptBlock {
                    (Get-WmiObject -Class Win32_ComputerSystem).UserName
                    (Get-WmiObject -Class Win32_BIOS).SerialNumber
                }
            } | Out-Null
            $Jobs += $_
        }

        While ((Get-Job).State -ne 'Completed') {
            Start-Sleep -Seconds 1
        }

        $Jobs | 
        ForEach-Object {
            if ($_ -ne $null) {
                $Data = Receive-Job -Name $_ -ErrorAction Ignore
                if ($Data -ne $null) {
                    $Asset = New-Object -TypeName psobject
                    Add-Member -InputObject $Asset -MemberType NoteProperty -Name IpAddress '-'
                    Add-Member -InputObject $Asset -MemberType NoteProperty -Name MacAddress '-'
                    Add-Member -InputObject $Asset -MemberType NoteProperty -Name CurrentUser $Data[0]
                    Add-Member -InputObject $Asset -MemberType NoteProperty -Name SerialNumber $Data[1]
                    $AssetInventory += $Asset
                }
            }
        }

        return $AssetInventory
    }
}

function New-AssetInventory {
    Get-Assets |
    Get-Addresses |
    Get-Names |
    Get-AssetInventory #|
    #Sort-Object { $_.Address -as [Version] }
}

Get-Credentials
if ($ExportToCsvFile) {
    New-AssetInventory |
    Export-Csv -NoTypeInformation "C:\Users\Public\Documents\AssetInventory_$(Get-Date -Format yyyy-MM-dd_hhmm).csv"
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
#>
