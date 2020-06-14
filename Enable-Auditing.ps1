function Audit-SexySix {
    $Auditpol = 'C:\Windows\System32\auditpol.exe'
    if ($Auditpol) {
        $Events = '/subcategory:"Process Creation","File Share","File System","Registry","Filtering Platform Connection"'

        $Settings = '/set', $Events, '/success:enable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow

        $Settings = '/set', '/subcategory:"Logon"', '/success:disable', '/failure:disable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow
    }
}

function Audit-CliUsage {
    $Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
    $ValueName = 'ProcessCreationIncludeCmdLine_Enabled'
    $Value = 1
    $Type = 'Dword'

    if (-not (Test-Path $Key)) {
        New-Item –Path $Key –Name $ValueName
        New-ItemProperty -Path $Key -Name $ValueName -Value $Value  -PropertyType $Type
    }
}

Audit-SexySix
Audit-CliUsage
