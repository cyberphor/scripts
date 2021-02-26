## Examples

Get-AssetInventory
```powershell
.\Get-AssetInventory.ps1 -Network 192.168.2.0/24

IpAddress    MacAddress        HostName SerialNumber   UserName       FirstSeen        LastSeen
---------    ----------        -------- ------------   --------       ---------        --------
192.168.2.1  -                 -        -              -              2020-12-31 17:44 2021-01-01 09:30
192.168.2.3  -                 -        -              -              2021-01-01 09:14 2021-01-01 09:14                                       
192.168.2.57 -                 -        -              -              2020-12-31 17:44 2021-01-01 09:30
192.168.2.60 -                 -        -              -              2021-01-01 09:33 2021-01-01 09:30                             
192.168.2.75 aa:aa:bb:bb:cc:cc DC1      T6UsW9N8       WINDOWS\Victor 2020-12-31 17:44 2021-01-01 09:30
```

Get-DnsLogs
```powershell
.\Get-DnsLogs.ps1

[x] DNS logging is not enabled.

wevtutil sl Microsoft-Windows-DNS-Client/Operational /e:true

.\Get-DnsLogs.ps1

TimeCreated           ProcessId DnsQuery                           Sid                                           
-----------           --------- --------                           ---
2/26/2021 9:40:51 AM  1464      technet.microsoft.com              S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:38:53 AM  1464      tempest.services.disqus.com        S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 10:05:30 AM 516       tile-service.weather.microsoft.com S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 10:05:30 AM 516       tile-service.weather.microsoft.com S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:45:59 AM  1464      tpc.googlesyndication.com          S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:38:54 AM  1464      trc.taboola.com                    S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:38:55 AM  1464      u.ipw.metadsp.co.uk                S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:45:29 AM  1464      uib.ff.avast.com                   S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:40:52 AM  1464      uib.ff.avast.com                   S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:38:54 AM  1464      ups.analytics.yahoo.com            S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:45:31 AM  1464      user-images.githubusercontent.com  S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:50:38 AM  3460      v10.events.data.microsoft.com      S-1-5-18                                                                            
2/26/2021 9:38:55 AM  1464      vidstat.taboola.com                S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:40:53 AM  1464      w.usabilla.com                     S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:40:52 AM  1464      wcpstatic.microsoft.com            S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:40:53 AM  1464      web.vortex.data.microsoft.com      S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 10:03:09 AM 1464      web.vortex.data.microsoft.com      S-1-5-21-3603040224-2895699255-2127603579-1001                                                                 
2/26/2021 9:39:01 AM  2616      wpad                               S-1-5-19                                      
2/26/2021 9:49:58 AM  12564     wpad                               S-1-5-21-3603040224-2895699255-2127603579-1001                                 
2/26/2021 9:38:54 AM  1464      www.facebook.com                   S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:45:59 AM  1464      www.google.com                     S-1-5-21-3603040224-2895699255-2127603579-1001
2/26/2021 9:40:53 AM  1464      www.google-analytics.com           S-1-5-21-3603040224-2895699255-2127603579-1001
```

Get-IpAddressRange
```powershell
.\Get-IpAddressRange.ps1 -Network 192.168.1.0/30, 192.168.2.0/30, 192.168.3.1/32

192.168.1.1
192.168.2.2
192.168.2.1
192.168.2.2
192.168.3.1
```

Format-Color
```powershell
Get-ChildItem | Format-Color -Value passwords.txt -BackgroundColor Red -ForegroundColor White
```
