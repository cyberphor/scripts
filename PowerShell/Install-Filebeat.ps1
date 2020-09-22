$Service = 'Filebeat'
$Description = 'A lightweight shipper for forwarding and centralizing log data.'
$Installed = Get-Service | Where-Object { $_.Name -like $Service }
$RunStatus = $Installed.Status

if ($Installed) {
    if ($RunStatus -ne "Running") { Start-Service -Name $Service } 
} else {
    $LocalFolder = "$env:ProgramData\$Service"
    if (Test-Path $LocalFolder) { Remove-Item -Recurse $LocalFolder }
    else { New-Item -Type Directory $LocalFolder | Out-Null }

    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $AllGpoFiles = Get-ChildItem -Recurse "\\$Domain\sysvol\$Domain\Policies\"
    $ServiceGPO = ($AllGpoFiles | Where-Object { $_.Name -eq "$Service.exe" }).DirectoryName
    Copy-Item -Path "$ServiceGPO\winlogbeat.exe", "$ServiceGPO\winlogbeat.yml", "$ServiceGPO\sysmonsubscription.xml" -Destination $LocalFolder
 
    if (Test-Path "$LocalFolder\$Service.exe") {
        $Binary = "$LocalFolder\$Service.exe"
        $Config = "$LocalFolder\winlogbeat.yml"
        $PathHome = "$LocalFolder"
        $PathData = "$LocalFolder\Data"
        $PathLogs = "$LocalFolder\Data\logs"
        $BinaryPathName = "$Binary -c $Config -path.home $PathHome -path.data $PathData -path.logs $PathLogs"
        New-Service -Name $Service -DisplayName $Service -BinaryPathName $BinaryPathName
        Set-Service -Name $Service -StartupType Automatic
        Start-Service -Name $Service
    }
}

# REFERENCES
# https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro
