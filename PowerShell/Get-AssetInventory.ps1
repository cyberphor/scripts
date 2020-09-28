Param(
    $ComputerName
)

function Get-AssetInventory {
    $ScriptBlock = {
        Param($Target)
        Write-Host "[+] $Target, MAC Address, Hostname, Serial Number, User"
    }

    $Targets | ForEach-Object {
        Start-Job -ScriptBlock $ScriptBlock -ArgumentList $_ | Out-Null
    }

    Get-Job | Wait-Job | Receive-Job
}

function Main {
    if (($ComputerName.GetType().Name -eq 'String') -and (Test-Path $ComputerName)) {
        $Targets = Get-Content $ComputerName
    } elseif ($ComputerName.GetType().Name -eq 'Object[]') {
        $Targets = $ComputerName  
    } elseif ($ComputerName.GetType().Name -eq 'String') {
        $Targets = $ComputerName
    } else {
        Write-Host "[x] No machines specified."
        exit
    }

    Get-AssetInventory
}

Main

# REFERENCES
# https://stackoverflow.com/questions/16360019/how-do-i-add-multi-threading
# https://stackoverflow.com/questions/15120597/passing-multiple-values-to-a-single-powershell-script-parameter
# https://stackoverflow.com/questions/13264369/how-to-pass-array-of-arguments-to-powershell-commandline
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/start-job?view=powershell-7
