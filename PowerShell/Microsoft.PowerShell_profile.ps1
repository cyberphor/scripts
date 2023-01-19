function Get-TwoWindows {
  1..2| % { Start-Process -WindowStyle Normal powershell }
}
