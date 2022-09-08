Param(
    [Parameter(Mandatory)][string]$Path,
    [string]$DistinguishedName,
    [string]$Domain
)

Get-Content -Path $Path |
ConvertFrom-Csv |
ForEach-Object {
    $FirstName = ($_.FirstName).Replace(" ","")
    $LastName = ($_.LastName).Replace(" ","")
    $Name = $_.LastName + ", " + $_.FirstName
    $SamAccountName = ($FirstName + "." + $LastName).ToLower()
    $UserPrincipalName = $SamAccountName + $Domain
    $Password = ConvertTo-SecureString -AsPlainText -Force "password"
    $Description = $_.Section

    if ($_.Unit -eq "BDE") {
        $Unit = "OU=Users,OU=Main,$DistinguishedName"
    } else {
        $Unit = "OU=Users,OU=" + $_.Unit.Replace(" ","") + ",$DistinguishedName"
    }

    New-ADUser `
        -GivenName $FirstName `
        -SurName $LastName `
        -Name $Name `
        -DisplayName $Name `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UserPrincipalName `
        -AccountPassword $Password `
        -ChangePasswordAtLogon $true `
        -Path $Unit `
        -Enabled $true

    Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" |
    ForEach-Object {
        Set-ADUser -Identity $_.SamAccountName -Description $Description
        Add-ADGroupMember -Identity "XMPP Users" -Members $_.SamAccountName
    }
}