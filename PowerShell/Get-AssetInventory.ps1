<#
.SYNOPSIS
    Queries Active Directory for all domain-joined computers and then, uses this data to collect the IP and MAC address of each. 
.EXAMPLE
    ./Get-AssetInventory.ps1
    ./Get-AssetInventory.ps1 -OU 'DC=vanilla,DC=sky,DC=net'
.INPUTS
    The Active Directory Organizational Unit (OU) you want to query.
.OUTPUTS
    Prints data collected in CSV-format to the console. 
.LINK
    https://www.github.com/cyberphor
.NOTES
    File name: Get-AssetInventory.ps1
    Version: 1.0
    Author: Victor Fernandez III
    Creation Date: Saturday, August 8th, 2020
    Purpose: Enhances the process of maintaining an asset inventory.
#>

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

$Computers = Get-ADComputer -Filter * -SearchBase $OU |
Select-Object -ExpandProperty Name
$Records = @()

$Computers | ForEach-Object {
    If (Test-Connection -ComputerName $_ -Count 2 -Quiet) {
        try {
            $Machine = $_
            Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Machine -ErrorAction SilentlyContinue |
            Select-Object IPAddress, MacAddress, Description |
            Where-Object { $_.Description -like 'Intel*' } | 
            ForEach-Object {
                $NetworkCard = $_
                $NetworkCard | ForEach-Object {
                    $_.IPAddress | 
                    ForEach-Object {
                        $Entry = New-Object -TypeName PSObject
                        Add-Member -InputObject $Entry -MemberType NoteProperty -Name Hostname -Value $Machine 
                        Add-Member -InputObject $Entry -MemberType NoteProperty -Name IPAddress -Value $_
                        Add-Member -InputObject $Entry -MemberType NoteProperty -Name MacAddress -Value $NetworkCard.MacAddress
                        $Records += $Entry
                    }
                }
            } 
        } catch {
        }
    }
}

$Records | 
Sort-Object -Property Name, IPAddress |
ConvertTo-Csv

# References
# https://www.chrisjhart.com/Windows-10-ssh-copy-id/
