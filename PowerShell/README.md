## Navigating the File System
```powershell
pwd # print working directory
ls # list contents of current working directory
cd Desktop # change directories to 'Desktop'
cd C:\
cls # clear screen
pwd
cd ~ # change directories and go 'home'
New-Item -Type file -Name goals.txt
Add-Content goals.txt "Learn PowerShell"
Get-Content goals.txt
Add-Content goals.txt "Learn Python"
Rename-Items goals.txt -NewName accomplished.txt
Get-Content goals.txt
Get-ChildItem # list contents of current working directory
Remove-Item accomplished.txt
```

## Concepts
```powershell
Get-Host
Get-PSDrive
cd HKCU:\
pwd
ls
cd C:\
Get-Command *process
Get-Commmand rename*
Get-Process | Get-Member
Get-Process | gm
Get-Alias gm
Get-Alias -Definition Get-Process
```

## Essentials
```powershell
# learn about an object's members
ps | gm

# Select specific strings to filter output
ps | Select processname
ps | Select processname | gm

# Selecting objects of a specified criteria
ps | Where-Object { $_.processname -eq 'powershell' }
ps | Where-Object { $_.processname -eq 'powershell' } | gm
$weird = ps | Where-Object { $_.processname -eq 'powershell' }
$weird.kill()

# Interating through a group of objects
New-Item -Type file -Name computers.txt
Add-Content notes.txt "localhost"
Add-Content notes.txt "t800.sky.net"
Add-Content notes.txt "127.0.0.1"
Get-Content nodes.txt
Get-Alias -Definition Get-Content
gc nodes.txt | ForEach-Object { if (Test-Connnection $_ -Quiet) { echo "$_ is up!" } }

# Getting help
Get-Help Get-Process
Get-Help Get-Process -Examples

```
