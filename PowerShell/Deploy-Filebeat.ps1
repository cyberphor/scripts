Param(
    [switch]$CustomConfiguration,
    [switch]$GroupPolicy,
    [switch]$Remove
)

function Install-UsingCurrentDirectory {
    if ($CustomConfiguration) {
        $Type = Read-Host -Prompt '[>] Input Type'
        $FilePath = Read-Host -Prompt '[>] Filepath'
        #$DocumentType = Read-Host -Prompt '[>] Document Type'
        #$LogType = Read-Host -Prompt '[>] Log Type'
        $IpAddress = Read-Host -Prompt '[>] Logstash Server IP Addresss'
        $Port = Read-Host -Prompt '[>] Logstash Server Port'
        $LogstashServer = $IpAddress + ':' + $Port
    } else {
        $Type = 'log'
        $FilePath = 'C:\Windows\System32\LogFiles\Firewall\*.log'
        $DocumentType = 'windowsfirewall'
        $LogType = 'windowsfirewall'
        $IpAddress = '192.168.3.9'
        $Port = '5044'
        $LogstashServer = $IpAddress + ':' + $Port
    }
    
    $Configuration = @(
        "filebeat.prospectors:",
        "- type: $Type",
        "  paths:",
        "    - '$FilePath'",
        "name: $env:COMPUTERNAME",
        "document_type: $DocumentType",
        "logtype: $LogType",
        "output.logstash:",
        "  hosts: ['$LogstashServer']"
    ) -join "`r`n"

    if (Test-Path $ConfigFile) { 
        $OldConfiguration = Get-Content $ConfigFile
        Remove-Item $ConfigFile
        $DeletedOldConfiguration = $true
    } else {
        $DeletedOldConfiguration = $false
    }
     
    New-Item -ItemType File -Name $ConfigFile | Out-Null 
    Add-Content -Value $Configuration -Path $ConfigFile
    $CreatedNewConfiguration = $true
 
    $CurrentDirectory = (Get-ChildItem -Recurse).name
    $FilesToCopy = @()
    $Requirements | ForEach-Object {
        $RequiredFile = $_ 
        if ($CurrentDirectory -contains $RequiredFile) {
            $FilesToCopy += $RequiredFile
        } else {
            if ($CreatedNewConfiguration) {
                Remove-Item $ConfigFile
            } 
            if ($DeletedOldConfiguration) {
                New-Item -ItemType File -Name $ConfigFile | Out-Null
                Add-Content -Value $OldConfiguration -Path $ConfigFile
            }
            Write-Host "[x] Missing required file: $RequiredFile"
            exit
        }
    }

    if (Test-Path $ProgramFolder) { 
        Remove-Item -Recurse $ProgramFolder
    } 
    New-Item -ItemType Directory -Path $ProgramFolder 

    $FilesToCopy | ForEach-Object {
        $RequiredFile = $_
        Copy-Item -Path $RequiredFile -Destination $ProgramFolder
    }

    if (Test-Path "$ProgramFolder\$Program.exe") {
        $Binary = "$ProgramFolder\$Program.exe"
        $Config = "$ProgramFolder\$ConfigFile"
        $PathHome = "$ProgramFolder"
        $PathData = "$ProgramFolder\Data"
        $PathLogs = "$ProgramFolder\Data\logs"
        $BinaryPathName = "$Binary -c $Config -path.home $PathHome -path.data $PathData -path.logs $PathLogs"
        New-Service -Name $Service -DisplayName $Service -Description $Description -BinaryPathName $BinaryPathName 
        Set-Service -Name $Service -StartupType Automatic
        Start-Service -Name $Service
    }
}

function Install-UsingSysVolShare {
    $ProgramFolder = "$env:ProgramFiles\$Service"
    if (Test-Path $ProgramFolder) { Remove-Item -Recurse $ProgramFolder }
    else { New-Item -Type Directory $ProgramFolder | Out-Null }

    <#
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $AllGpoFiles = Get-ChildItem -Recurse "\\$Domain\sysvol\$Domain\Policies\"
    $ServiceGPO = ($AllGpoFiles | Where-Object { $_.Name -eq "$Service.exe" }).DirectoryName
    
    Copy-Item -Path "$ServiceGPO\filebeat.exe", "$ServiceGPO\filebeat.yml" -Destination $ProgramFolder
    #>

    if (Test-Path "$ProgramFolder\$Service.exe") {
        $Binary = "$ProgramFolder\$Service.exe"
        $Config = "$ProgramFolder\$ConfigFile"
        $PathHome = "$ProgramFolder"
        $PathData = "$ProgramFolder\Data"
        $PathLogs = "$ProgramFolder\Data\logs"
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
    if (Test-Path $ProgramFolder) { 
        Remove-Item -Path $ProgramFolder -Recurse -Force
        Write-Host "[+] Removed $Service."
    } 
    
}

function Main {
    $Service = 'Filebeat'
    $Program = $Service.ToLower()
    $Description = 'A lightweight shipper for forwarding and centralizing log data.'
    $ConfigFile = 'filebeat.yml'
    $Requirements = $ConfigFile, 'filebeat.exe'
    $ServiceIsInstalled = Get-Service | Where-Object { $_.Name -like $Service }
    $ProgramFolder = "$env:ProgramFiles\$Service"

    if ($Remove) {
        Remove-Program 
    } elseif ($ServiceIsInstalled) { 
        Start-Program
    } elseif ($GroupPolicy) {
        Install-UsingSysVolShare
    } else {
        Install-UsingCurrentDirectory
    }
}

Main

# REFERENCES
# https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro
# https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell
# https://stackoverflow.com/questions/26372360/powershell-script-indentation-for-long-strings
