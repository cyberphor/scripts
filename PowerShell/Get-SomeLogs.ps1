Get-WinEvent -LogName System | 
Select-Object -First 20 |
Sort-Object TimeCreated |
ForEach-Object {
    $timestamp = $_.TimeCreated
    $record = $_.Id
    $sid = $_.UserId
    
    try{
        $sid_object = New-Object System.Security.Principal.SecurityIdentifier($sid)
        $user = $sid_object.Translate([System.Security.Principal.NTAccount])
        $username = $user.Value
    } catch { 
        $username = $sid
    }
    
    Write-Host "Time: $timestamp, EventID: $record, User: $username"
}
