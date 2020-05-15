while ($true) {
    (New-Object -ComObject Wscript.Shell).Sendkeys('+{F15}')
    Start-Sleep -Seconds 10
}
