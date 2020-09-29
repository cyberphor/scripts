Param(
    $ComputerName
)

function Get-AssetInventory {
    $Baseline = Test-Path $ComputerName
    $NotList = $ComputerName.GetType().Name -eq 'String'
    $Assets = @()

    if ($Baseline -and $NotList) {
        Get-Content $ComputerName |
        ForEach-Object {
            if ("$_" -as [IPAddress] -as [Bool]) {
                $Online = Test-Connection -Count 2 -ComputerName $_ -Quiet
                $IpAddress = $_
                $MacAddress = ''
                $Hostname = ''
                $SerialNumber = ''
                $CurrentUser = ''
            } else {
                $Online = Test-Connection -Count 2 -ComputerName $_ -Quiet
                $IpAddress = $Online.IPV4Address | Select -Last 1 -ExpandProperty IPAddressToString
                $MacAddress = ''
                $Hostname = $_
                $SerialNumber = ''
                $CurrentUser = ''
            }

            $Asset = New-Object -TypeName PSObject
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name Online -Value $Online 
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name IpAddress -Value $IpAddress
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name MacAddress -Value $MacAddress
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name Hostname -Value $Hostname
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name SerialNumber -Value $SerialNumber
            Add-Member -InputObject $Asset -MemberType NoteProperty -Name CurrentUser -Value $CurrentUser
            $Assets += $Asset

            }
    } else {
        $Targets = $ComputerName
    }

    $Assets | ForEach-Object {
        $Online = $_.Online
        $IpAddress = $_.IpAddress
        $MacAddress = $_.MacAddress
        $Hostname = $_.Hostname
        $SerialNumber = $_.SerialNumber
        $CurrentUser = $_.CurrentUser 
        if ($Online) {
            Write-Host "[+] $IpAddress, $MacAddress, $Hostname, $SerialNumber, $CurrentUser"
        } else {
            Write-Host "[x] $IpAddress, $MacAddress, $Hostname, $SerialNumber, $CurrentUser"
        }
    }
}

function Main {
    if ($ComputerName) {
        Get-AssetInventory 
    } else { 
        Write-Host "[x] No machines specified."
        exit
    }
}

Main

# REFERENCES
# https://stackoverflow.com/questions/16360019/how-do-i-add-multi-threading
# https://stackoverflow.com/questions/15120597/passing-multiple-values-to-a-single-powershell-script-parameter
# https://stackoverflow.com/questions/13264369/how-to-pass-array-of-arguments-to-powershell-commandline
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/start-job?view=powershell-7
# https://ridicurious.com/2018/11/14/4-ways-to-validate-ipaddress-in-powershell/
