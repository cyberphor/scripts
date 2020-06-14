
function Install-RequiredFeatures() {
    if ((Get-WindowsFeature AD-Domain-Services).InstallState -ne 'Installed') {
        Write-Host "[!] Installing the 'Active Directory Domain Services' feature."
        $ExitCode = (Install-WindowsFeature AD-Domain-Services -IncludeManagementTools).ExitCode
        Write-Host " ---> $ExitCode"
    } else { Write-Host "[+] The 'Active Directory Domain Services' feature is already installed." }

    if ((Get-WindowsFeature DNS).InstallState -ne 'Installed') {
        Write-Host "[!] Installing the 'Domain Name System (DNS)' feature."
        $ExitCode = (Install-WindowsFeature DNS -IncludeManagementTools).ExitCode
        Write-Host " ---> $ExitCode"
    } else { Write-Host "[+] The 'Domain Name System (DNS)' feature is already installed." }
}

function Create-Forest() {
    if (-not (Get-Service | Where-Object { $_.Name -eq 'adws' })) {
        $Domain = 'vanilla.sky.net'
        Write-Host "[!] Deploying the '" + $Domain + "' domain."
        $Password = ConvertTo-SecureString 'AdministratorPassword2020!' -AsPlainText -Force # change me
        Install-ADDSForest -DomainName $Domain -InstallDns -SafeModeAdministratorPassword $Password -Force
    }
    if ($env:COMPUTERNAME -ne 'T800') { Rename-Computer -NewName 'T800' -Force }
}

function Create-DomainAdmin() {
    $FirstName = 'Elliot' # change me
    $LastName = 'Alderson' # change me
    $FullName = $LastName + ', ' + $FirstName
    $SamAccountName = $FirstName.ToLower() + '.' + $LastName.ToLower()
    $UserPrincipalName = $SamAccountName + '@' + $Domain
    $Description = 'Your Security Administrator' # change me
    $Group = 'Domain Admins' # change me
    New-ADUser `
        -GivenName $FirstName `
        -Surname $LastName `
        -Name $FullName `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UserPrincipalName `
        -AccountPassword $Password `
        -ChangePasswordAtLogon $true
        -Description $Description 
    Enable-ADAccount -Identity $SamAccountName
    Add-ADGroupMember -Identity $Group -Members $SamAccountName
}

Install-RequiredFeatures
Create-Forest
Create-DomainAdmin
