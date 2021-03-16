$Computers = (Get-AdComputer -Filter *).DnsHostname

Invoke-Command -ComputerName $Computers -ErrorAction Ignore -ScriptBlock {
  Get-WmiObject Win32_NetworkAdapter | 
  Where-Object { $_.Name -like '*Wireless*' }
}
