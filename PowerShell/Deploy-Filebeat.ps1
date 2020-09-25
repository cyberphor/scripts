Param(
    [switch]$CustomConfiguration,
    [switch]$GroupPolicy,
    [switch]$Remove
)

function Install-UsingCurrentDirectory {
    if ($CustomConfiguration) {
        $Type = Read-Host -Prompt '[>] Input Type'
        $FilePath = Read-Host -Prompt '[>] Filepath'
        $DocumentType = Read-Host -Prompt '[>] Document Type'
        $LogType = Read-Host -Prompt '[>] Log Type'
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
        "  enabled: true",
        "  paths:",
        "    - $FilePath",
        "  document_type: $DocumentType", 
        "  logtype: $LogType", 
        "output.logstash:", 
        "   hosts: ['$LogstashServer']"
    ) -join "`r`n"

    if (Test-Path $ConfigurationFile) { 
        $OldConfiguration = Get-Content $ConfigurationFile
        Remove-Item $ConfigurationFile
        $DeletedOldConfiguration = $true
    } else {
        $DeletedOldConfiguration = $false
    }
     
    New-Item -ItemType File -Name $ConfigurationFile | Out-Null 
    Add-Content -Value $Configuration -Path $ConfigurationFile
    $CreatedNewConfiguration = $true
 
    $CurrentDirectory = (Get-ChildItem -Recurse).name
    $FilesToCopy = @()
    $Requirements | ForEach-Object {
        $RequiredFile = $_ 
        if ($CurrentDirectory -contains $RequiredFile) {
            $FilesToCopy += $RequiredFile
        } else {
            if ($CreatedNewConfiguration) {
                Remove-Item $ConfigurationFile
            } 
            if ($DeletedOldConfiguration) {
                New-Item -ItemType File -Name $ConfigurationFile | Out-Null
                Add-Content -Value $OldConfiguration -Path $ConfigurationFile
            }
            Write-Host "[x] Missing required file: $RequiredFile"
            exit
        }
    }

    if (Test-Path $InstallationFilePath) { 
        Remove-Item -Recurse $InstallationFilePath
    } 
    New-Item -ItemType Directory -Path $InstallationFilePath 

    $FilesToCopy | ForEach-Object {
        $RequiredFile = $_
        Copy-Item -Path $RequiredFile -Destination $InstallationFilePath
    }

    if (Test-Path "$InstallationFilePath\$Program") {
        $Binary = "`"$InstallationFilePath\$Program`""
        $Arguments = " -c `"$ConfigurationFilePath`" -path.home `"$InstallationFilePath`" -path.data `"$InstallationFilePath`" -path.logs `"$InstallationFilePath\logs`""
        $BinaryPathName = $Binary + $Arguments
        New-Service -Name $Name -DisplayName $Name -Description $Description -BinaryPathName $BinaryPathName
        Start-Service $Name
        Get-Service $Name
    }
}

function Install-UsingSysVolShare {
    $InstallationFilePath = "$env:ProgramFiles\$Service"
    if (Test-Path $InstallationFilePath) { Remove-Item -Recurse $InstallationFilePath }
    else { New-Item -Type Directory $InstallationFilePath | Out-Null }

    <#
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $AllGpoFiles = Get-ChildItem -Recurse "\\$Domain\sysvol\$Domain\Policies\"
    $ServiceGPO = ($AllGpoFiles | Where-Object { $_.Name -eq "$Service.exe" }).DirectoryName
    
    Copy-Item -Path "$ServiceGPO\filebeat.exe", "$ServiceGPO\filebeat.yml" -Destination $InstallationFilePath
    #>

    if (Test-Path "$InstallationFilePath\$Service.exe") {
        $Binary = "$InstallationFilePath\$Service.exe"
        $Config = "$InstallationFilePath\$ConfigurationFile"
        $PathHome = "$InstallationFilePath"
        $PathData = "$InstallationFilePath\Data"
        $PathLogs = "$InstallationFilePath\Data\logs"
        $BinaryPathName = "$Binary -c $Config -path.home $PathHome -path.data $PathData -path.logs $PathLogs"
        New-Service -Name $Service -DisplayName $Service -Description $Description -BinaryPathName $BinaryPathName
        Set-Service -Name $Service -StartupType Automatic
        Start-Service -Name $Service
    }
}

function Start-Program {
    $RunStatus = $Installed.Status
    if ($RunStatus -ne "Running") { 
        Start-Service -Name $Name 
        Write-Host "[>] Started $Name."
    } 
}

function Remove-Program {
    if (Get-Service | Where-Object { $_.Name -like $Name }) {
        Stop-Service $Name
        (Get-WmiObject -Class Win32_Service -Filter "name='$Name'").Delete() | Out-Null
        Write-Host "[+] Stopped $Name."
    } 
    if (Test-Path $InstallationFilePath) { 
        Remove-Item -Path $InstallationFilePath -Recurse -Force
        Write-Host "[+] Removed $Name."
    }     
}

function Main {
    $Name = 'Filebeat'
    $Description = 'A lightweight shipper for forwarding and centralizing log data.'  
    $Program = $Name.ToLower() + '.exe'
    $ConfigurationFile = $Name.ToLower() + '.yml'
    $Requirements = $Program, $ConfigurationFile
    $ServiceIsInstalled = Get-Service | Where-Object { $_.Name -like $Name }
    $InstallationFilePath = $env:ProgramData + '\' + $Name
    $ConfigurationFilePath = $InstallationFilePath + '\' + $ConfigurationFile

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
