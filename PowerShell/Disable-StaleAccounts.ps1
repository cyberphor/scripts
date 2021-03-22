Import-Module ActiveDirectory

$30_Days_Ago = (Get-Date).AddDays(-30)
$Filter = { LastLogonDate -le $30_Days_Ago }
$SearchBase = Read-Host -Prompt 'Distinguished Name (OU Path in LDAP Format)'

Get-ADUser -Filter $Filter -SearchBase $SearchBase -Properties LastLogonDate,Description | 
foreach {
    if ($_.Enabled) {
        Set-ADUser $_.SamAccountName -Description $('Last Login - ' + $_.LastLogonDate)
        Disable-ADAccount $_.SamAccountName
    }
} 

# EXAMPLE OU PATH: OU=Users,OU=HQ,OU=EvilCorp,DC=vanilla,DC=sky,DC=net
