Param(
    [string]$From,
    [switch]$FromGroupPolicy,
    [switch]$Remove
)

function Install-Program {
    # backup and delete the default Filebeat configuration file
    if (Test-Path $ConfigurationFile) { 
        $OldConfiguration = Get-Content $ConfigurationFile
        Remove-Item $ConfigurationFile
        $DeletedOldConfiguration = $true
    } else {
        $DeletedOldConfiguration = $false
    }
     
    # create a new Filebeat configuration file
    New-Item -ItemType File -Name $ConfigurationFile | Out-Null 
    Add-Content -Value $Configuration -Path $ConfigurationFile
    $CreatedNewConfiguration = $true
 
    # check if the current directory contains all required files for deployment
    $Directory = (Get-ChildItem -Recurse).name
    $FilesToCopy = @()
    $Requirements | ForEach-Object {
        $RequiredFile = $_ 
        if ($Directory -contains $RequiredFile) {
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

    # remove any existing Filebeat installation folders if they exist
    if (Test-Path $InstallationFilePath) { 
        Remove-Item -Recurse $InstallationFilePath
    } 
    New-Item -ItemType Directory -Path $InstallationFilePath | Out-Null

    # copy all required files for deployment to the Filebeat installation folder
    $FilesToCopy | ForEach-Object {
        $RequiredFile = $_
        Copy-Item -Path $RequiredFile -Destination $InstallationFilePath
    }

    # register and start Filebeat as a service if it was copied to the installation folder 
    if (Test-Path "$InstallationFilePath\$Program") {
        $Binary = "`"$InstallationFilePath\$Program`""
        $Arguments = " -c `"$ConfigurationFilePath`" -path.home `"$RunTimeFilePath`" -path.data `"$RunTimeFilePath`" -path.logs `"$RunTimeFilePath\logs`""
        $BinaryPathName = $Binary + $Arguments
        New-Service -Name $Name -DisplayName $Name -Description $Description -BinaryPathName $BinaryPathName | Out-Null
        Start-Service $Name | Out-Null

    }
}

function Install-UsingCurrentDirectory {
    $Directory = (Get-ChildItem -Recurse).name
    Install-Program
    Write-Host "[+] Deployed $Name."
    Write-Host " -  Log Source: $FilePath"
    Write-Host " -  Destination Logstash Server: $LogstashServer"
}

function Install-UsingDesignatedDirectory {
    $OriginalDirectory = $pwd
    Set-Location $From
    Install-UsingCurrentDirectory
    Set-Location $OriginalDirectory
}

function Install-UsingSysVolShare {
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    $GroupPolicyObjects = Get-ChildItem -Recurse "\\$Domain\sysvol\$Domain\Policies\"
    $Directory = ($GroupPolicyObjects | Where-Object { $_.Name -eq $Program }).DirectoryName
    Install-Program
}

function Start-Program {
    if ($ServiceIsInstalled.Status -ne "Running") { 
        Start-Service -Name $Name 
        Write-Host "[+] Started $Name."
    } else {
        Write-Host "[+] $Name is already running."
    }
}

function Remove-Program {
    if (Get-Service | Where-Object { $_.Name -like $Name }) {
        Stop-Service $Name
        (Get-WmiObject -Class Win32_Service -Filter "name='$Name'").Delete() | Out-Null
        Remove-Item -Path $RunTimeFilePath -Recurse -Force
        Remove-Item -Path $InstallationFilePath -Recurse -Force
        Write-Host "[+] Removed $Name."
    } else {
        Write-Host "[x] $Name is not installed."
    }
}

function Main {
    $Name = 'Filebeat'
    $Description = 'A lightweight shipper for forwarding and centralizing log data.'  
    $Program = $Name.ToLower() + '.exe'
    $ConfigurationFile = $Name.ToLower() + '.yml'
    $Requirements = $Program, $ConfigurationFile
    
    $InstallationFilePath = $env:ProgramFiles + '\' + $Name
    $ConfigurationFilePath = $InstallationFilePath + '\' + $ConfigurationFile
    $RunTimeFilePath = $env:ProgramData + '\' + $Name

    $ServiceIsInstalled = Get-Service | Where-Object { $_.Name -like $Name }
    
    $Type = 'log'
    $FilePath = 'C:\Windows\System32\LogFiles\Firewall\*.log'
    $DocumentType = 'windowsfirewall'
    $LogType = 'windowsfirewall'
    $IpAddress = '192.168.3.9'
    $Port = '5044'
    $LogstashServer = $IpAddress + ':' + $Port

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

    if ($Remove) {
        Remove-Program 
    } elseif ($ServiceIsInstalled) { 
        Start-Program
    } elseif ($FromGroupPolicy) {
        Install-UsingSysVolShare
    } elseif ($From) {
        Install-UsingDesignatedDirectory
    } else {
        Install-UsingCurrentDirectory
    }
}

Main

# REFERENCES
# https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro
# https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell
# https://stackoverflow.com/questions/26372360/powershell-script-indentation-for-long-strings
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-service?view=powershell-7
# https://www.elastic.co/guide/en/beats/filebeat/current/command-line-options.html
