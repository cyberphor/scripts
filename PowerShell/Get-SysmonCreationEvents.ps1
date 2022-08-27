#Requires -Modules Soap

$FilterHashTable = @{
    LogName = "Microsoft-Windows-Sysmon/Operational"
    Id = 1;
}

$AllowList = (
    @{"-" = "C:\Program Files\Microsoft OneDrive\22.151.0717.0001\FileCoAuth.exe"},
    @{"C:\Windows\System32\svchost.exe" = "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe"},
    @{"C:\Windows\System32\svchost.exe" = "C:\Windows\System32\consent.exe" }
)

Get-WinEvent -Filterhashtable $FilterHashTable | 
Read-WinEvent | 
ForEach-Object {
    $ParentImage = $_.ParentImage
    $Image = $_.Image
    $NotAllowed = $AllowList.GetEnumerator() | Where-Object { $_[$ParentImage] -ne $Image }
    if ($NotAllowed) {
        $_
    }
} | 
Select -First 10 ParentImage,Image |
Format-List
