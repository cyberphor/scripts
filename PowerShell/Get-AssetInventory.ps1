
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
    $Assets = $(
        '192.168.3.1',
        '192.168.3.2',
        '192.168.3.3'
    )
    
    return $Assets
}

function Get-AssetsOnline {
    Param([Parameter(ValueFromPipeline)]$Assets)
    Process {
        $Jobs = @()
        $AssetsOnline = @()
        
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
                $AssetsOnline += $_
            }
        }

        return $AssetsOnline
    }
}

function New-AssetInventory {
    Get-Assets |
    Get-AssetsOnline
}

Get-Credentials
New-AssetInventory

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
#>
