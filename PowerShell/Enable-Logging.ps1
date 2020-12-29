
function Get-AuditpolSettings {
    $Auditpol = auditpol /get /category:* 
    $AuditpolSettings = @()

    $Auditpol | 
    Select-String 'Success' |
    foreach {
        $CategoryName = ($_ -split 'Success')[0].Trim()
        $CategorySetting = 'Success ' + ($_ -split 'Success')[1].Trim()
        $Category = New-Object psobject
        Add-Member -InputObject $Category -MemberType NoteProperty -Name Category -Value $CategoryName
        Add-Member -InputObject $Category -MemberType NoteProperty -Name Setting -Value $CategorySetting
        $AuditpolSettings = $AuditpolSettings + $Category
    }

    $Auditpol | 
    Select-String 'No Auditing' |
    foreach {
        $CategoryName = ($_ -split 'No Auditing')[0].Trim()
        $CategorySetting = 'No Auditing ' + ($_ -split 'No Auditing')[1].Trim()
        $Category = New-Object psobject
        Add-Member -InputObject $Category -MemberType NoteProperty -Name Category -Value $CategoryName
        Add-Member -InputObject $Category -MemberType NoteProperty -Name Setting -Value $CategorySetting
        $AuditpolSettings = $AuditpolSettings + $Category
    }

    $ProcessCreationCategory = New-Object psobject
    Add-Member -InputObject $ProcessCreationCategory -MemberType NoteProperty -Name Category -Value 'Process Creation (Command Line)'
    $RegistryKey = 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit\'
    $RegistryKeySetting = 'ProcessCreationIncludeCmdLine_Enabled'
    $RegistryKeyValue = (Get-ItemProperty $RegistryKey).ProcessCreationIncludeCmdLine_Enabled
    if ($RegistryKeyValue -eq 1) {
        Add-Member -InputObject $ProcessCreationCategory -MemberType NoteProperty -Name Setting -Value 'Success' 
    } else { 
        Add-Member -InputObject $ProcessCreationCategory -MemberType NoteProperty -Name Setting -Value 'No Auditing'
    }
    $AuditpolSettings = $AuditpolSettings + $ProcessCreationCategory
    
    return $AuditpolSettings | Sort-Object -Property Setting -Descending
}

Get-AuditpolSettings

<# REFERENCES
https://stackoverflow.com/questions/5648931/test-if-registry-value-exists
#>
