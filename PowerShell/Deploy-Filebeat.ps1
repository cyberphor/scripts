Param(
    [switch]$CustomConfiguration,
    [switch]$GroupPolicy,
    [switch]$Remove
)

$Service = 'Filebeat'
$Description = 'A lightweight shipper for forwarding and centralizing log data.'
$ConfigFile = 'filebeat.yml'
$Requirements = $ConfigFile, 'filebeat.exe'
$ServiceIsInstalled = Get-Service | Where-Object { $_.Name -like $Service }
$ProgramFiles = "$env:ProgramFiles\$Service"

function Get-CustomConfiguration {
    $FileType = Read-Host -Prompt '[>] File Type'
    $FileType = Read-Host -Prompt '[>] File Format'
    $Filepath = Read-Host -Prompt '[>] File Path'
    $LogstashServerIPaddress = Read-Host -Prompt '[>] Logstash Server IP Address'
    $LogstashServerPort = Read-Host -Prompt '[>] Logstash Server Port'

    # more code goes here

    Write-Host "[+] Updated $ConfigFile with custom configuration settings."
}

function Set-DefaultConfiguration {

    # more code goes here

    Write-Host "[+] Setting configuration defaults."
}

function Install-UsingCurrentDirectory {
    if ($CustomConfiguration) {
        Get-NewConfiguration
    } elseif (Test-Path $ConfigFile) {
        Set-DefaultConfiguration
    } else {
        Write-Host '[x] Configuration file not found.'
        exit
    }

    $CurrentDirectory = (Get-ChildItem -Recurse).name
    $FilesToCopy = ''
    $Program = $Service.ToLower()

    if (Test-Path $ProgramFiles) { 
        Remove-Item -Recurse $ProgramFiles 
    } else { 
        New-Item -Type Directory $ProgramFiles | Out-Null 
    }

    $Requirements | ForEach-Object {
        $RequiredFile = $_ 
        if ($CurrentDirectory -contains $RequiredFile) {
            $FilesToCopy += $CurrentDirectory | Where-Object { $_.Name -eq $RequiredFile }
        } else {
            Write-Host "[x] Missing required file: $RequiredFile"
            exit
        }
    }

    $FilesToCopy | ForEach-Object {
        $RequiredFile = $_
        Copy-Item -path $RequiredFile.FullName -Destination $ProgramFiles
    }

    if (Test-Path "$ProgramFiles\$Program.exe") {
        $Binary = "$ProgramFiles\$Program.exe"
        $Config = "$ProgramFiles\$ConfigFile"
        $PathHome = "$ProgramFiles"
        $PathData = "$ProgramFiles\Data"
        $PathLogs = "$ProgramFiles\Data\logs"
        $BinaryPathName = "$Binary -c $Config -path.home $PathHome -path.data $PathData -path.logs $PathLogs"
        New-Service -Name $Service -DisplayName $Service -BinaryPathName $BinaryPathName
        Set-Service -Name $Service -StartupType Automatic
        Start-Service -Name $Service
    }
}

function Install-UsingSysVolShare {
    $ProgramFiles = "$env:ProgramFiles\$Service"
    if (Test-Path $ProgramFiles) { Remove-Item -Recurse $ProgramFiles }
    else { New-Item -Type Directory $ProgramFiles | Out-Null }

    <#
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $AllGpoFiles = Get-ChildItem -Recurse "\\$Domain\sysvol\$Domain\Policies\"
    $ServiceGPO = ($AllGpoFiles | Where-Object { $_.Name -eq "$Service.exe" }).DirectoryName
    
    Copy-Item -Path "$ServiceGPO\filebeat.exe", "$ServiceGPO\filebeat.yml" -Destination $ProgramFiles
    #>

    if (Test-Path "$ProgramFiles\$Service.exe") {
        $Binary = "$ProgramFiles\$Service.exe"
        $Config = "$ProgramFiles\$ConfigFile"
        $PathHome = "$ProgramFiles"
        $PathData = "$ProgramFiles\Data"
        $PathLogs = "$ProgramFiles\Data\logs"
        $BinaryPathName = "$Binary -c $Config -path.home $PathHome -path.data $PathData -path.logs $PathLogs"
        New-Service -Name $Service -DisplayName $Service -BinaryPathName $BinaryPathName
        Set-Service -Name $Service -StartupType Automatic
        Start-Service -Name $Service
    }
}

function Start-Program {
    $RunStatus = $Installed.Status
    if ($RunStatus -ne "Running") { Start-Service -Name $Service } 
}

function Remove-Program {
    if (Get-Service | Where-Object { $_.Name -like $Service }) {
        Stop-Service $Service
        (Get-WmiObject -Class Win32_Service -Filter "name='$Service'").Delete() | Out-Null
        Write-Host "[+] Stopped $Service."
    } 
    if (Test-Path $ProgramFiles) { 
        Remove-Item -Path $ProgramFiles -Recurse -Force
        Write-Host "[+] Removed $Service."
    } 
    
}

function Main {
    if ($Remove) {
        Remove-Program 
    } elseif ($ServiceIsInstalled) { 
        Start-Program
    } elseif ($GroupPolicy) {
        Install-UsingSysVolShare
    } else {
        Install-UsingLocalDirectory
    }
}

Main

# REFERENCES
# https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro
# https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell
