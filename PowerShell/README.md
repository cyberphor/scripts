## Examples

Get-IpAddressRange
```powershell
.\Get-IpAddressRange.ps1 -Network 192.168.1.0/30, 192.168.2.0/30, 192.168.3.1/32
192.168.1.1
192.168.2.2
192.168.2.1
192.168.2.2
192.168.3.1
```

Get-AssetInventory
```powershell
.\Get-AssetInventory.ps1 -Network 192.168.2.0/24
IpAddress    MacAddress        HostName SerialNumber   UserName       DateTimeAdded    DateTimeModified
---------    ----------        -------- ------------   --------       -------------    ----------------
192.168.2.1  -                 -        -              -              2020-12-31 17:44 -               
192.168.2.3  -                 -        -              -              2021-01-01 09:14 -                                     
192.168.2.57 -                 -        -              -              2020-12-31 17:44 -               
192.168.2.60 -                 -        -              -              2021-01-01 09:33 -                             
192.168.2.75 aa:aa:bb:bb:cc:cc DC1      T6UsW9N8       WINDOWS\Victor 2020-12-31 17:44 2021-01-01 09:30
```
