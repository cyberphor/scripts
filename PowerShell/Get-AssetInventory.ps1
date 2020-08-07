Param(
    [string]$OU = (Get-ADDomain -Current LocalComputer).DistinguishedName
)

$UserId = [Security.Principal.WindowsIdentity]::GetCurrent()
$AdminId = [Security.Principal.WindowsBuiltInRole]::Administrator
$CurrentUser = New-Object Security.Principal.WindowsPrincipal($UserId)
$RunningAsAdmin = $CurrentUser.IsInRole($AdminId)
if (-not $RunningAsAdmin) { 
    Write-Output "`n[x] This script requires administrator privileges.`n"
    exit
}

$Records = @()

$Computers = Get-ADComputer -Filter * -SearchBase $OU |
Select-Object -ExpandProperty Name

$Computers | ForEach-Object {
    If (Test-Connection -ComputerName $_ -Count 2 -Quiet) {
        try {
            $Machine = $_
            Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Machine -ErrorAction SilentlyContinue |
            Where-Object { $_.Description -like 'Intel*' } | 
            ForEach-Object {
                $NetworkCard = $_
                $NetworkCard | ForEach-Object {  
                    $NetworkCard.IPAddress | 
                    ForEach-Object { 
                        $Entry = $Machine, $_, $NetworkCard.MacAddress, $NetworkCard.Description
                        $Records += $Entry
                    }
                } 
            } 
        } catch {
            continue
        }
    }
}

$Records
