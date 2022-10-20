function Convert-CensusDataToNameList {
    Param([Parameter(Mandatory)][string]$InputFile)
    if (Test-Path $InputFile) {
        Get-Content $InputFile | 
        ForEach-Object { 
            $RandomName = $_.Split(' ')[0].ToLower()
            (Get-Culture).TextInfo.ToTitleCase($RandomName)
        }
    } else {
        Write-Error "$InputFile not found."
    }
}

function Get-Password {
    Param(
        [Parameter(Mandatory)][int]$Count,
        [Parameter(Mandatory)][string]$Passwordlist
    )
    Get-Content $Passwordlist -ErrorAction Stop |  
    Where-Object { 
        $_.Length -ge 8 -and    # at least 8 char
        $_ -cmatch "[a-z]" -and # includes at least 1 lowercase char
        $_ -cmatch "[A-Z]" -and # includes at least 1 upper char
        $_ -cmatch "[0-9]"      # includes at least 1 number
    } | Select-Object -First $Count
}

function Get-RandomUser {
    Param(
        [Parameter(Mandatory)][int]$Count,
        [Parameter(Mandatory)][string]$FirstNameList,
        [Parameter(Mandatory)][string]$LastNameList,
        [Parameter(Mandatory)][string]$PasswordList
    )
    $FirstNames = Get-Content $FirstNameList | Get-Random -Count $Count
    $LastNames = Get-Content $LastNameList | Get-Random -Count $Count
    $Passwords = Get-Content $PasswordList | Get-Random -Count $Count
    for ($i = 0; $i -lt $Count; $i++) {
        $FirstName = $FirstNames[$i]
        $LastName = $LastNames[$i]
        $Password = $Passwords[$i]
        $Properties = [ordered]@{
            "GivenName" = $FirstName
            "Surname" = $LastName
            "Name" = "$LastName, $FirstName"
            "SamAccountName" = ($FirstName + "." + $LastName).ToLower()
            "Password" = $Password
        }
        New-Object -TypeName psobject -Property $Properties
    }
}