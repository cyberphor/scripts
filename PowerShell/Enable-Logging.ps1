
function Enable-Logging {
    $Auditpol = 'C:\Windows\System32\auditpol.exe'
    if (Test-Path $Auditpol) {
        $Categories = 
            "Process Creation",
            "File Share",
            "File System",
            "Registry",
            "Filtering Platform Connection",
            "Logon"

        $Settings = '/set', "/subcategory:$Categories", '/success:enable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow

        $Settings = '/set', "/subcategory:$Categories", '/success:enable', '/failure:enable'
        Start-Process -FilePath $Auditpol -ArgumentList $Settings -NoNewWindow
    }

    $Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
    if (-not (Test-Path $Key)) {
        $ValueName = 'ProcessCreationIncludeCmdLine_Enabled'
        $Value = 1
        $Type = 'Dword'
        New-Item –Path $Key –Name $ValueName
        New-ItemProperty -Path $Key -Name $ValueName -Value $Value -PropertyType $Type
    }
}

Enable-Logging 
