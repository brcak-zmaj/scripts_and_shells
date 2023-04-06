$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$outputFile = "C:\Temp\network_diagnostics_$timestamp.txt"

Write-Output "Running network diagnostics..."

Get-NetAdapter
Get-NetIPAddress
Get-DnsClientServerAddress
ping google.com -n 10
tracert google.com
Test-NetConnection google.com -TraceRoute -Port 80
Test-NetConnection google.com -Port 80
Test-NetConnection google.com -Port 443
Test-NetConnection google.com -Port 53
Get-NetTCPConnection | Where-Object {$_.State -eq "Established" -and $_.LocalAddress -notlike "127.*" -and $_.RemoteAddress -notlike "127.*"} | Sort-Object -Unique LocalAddress,LocalPort,RemoteAddress,RemotePort,State | Format-Table -AutoSize
Get-NetUDPEndpoint | Where-Object {$_.State -eq "Established" -and $_.LocalAddress -notlike "127.*" -and $_.RemoteAddress -notlike "127.*"} | Sort-Object -Unique LocalAddress,LocalPort,RemoteAddress,RemotePort,State | Format-Table -AutoSize

Write-Output "Network diagnostics complete. Saving results to $outputFile..."

Out-File -FilePath $outputFile -InputObject (
    "Net Adapter:",
    (Get-NetAdapter | Out-String),
    "Net IP Address:",
    (Get-NetIPAddress | Out-String),
    "DNS Server Address:",
    (Get-DnsClientServerAddress | Out-String),
    "Ping Results:",
    (ping google.com -n 10 | Out-String),
    "Tracert Results:",
    (tracert google.com | Out-String),
    "TCP Connections:",
    (Get-NetTCPConnection | Where-Object {$_.State -eq "Established" -and $_.LocalAddress -notlike "127.*" -and $_.RemoteAddress -notlike "127.*"} | Sort-Object -Unique LocalAddress,LocalPort,RemoteAddress,RemotePort,State | Format-Table -AutoSize | Out-String),
    "UDP Endpoints:",
    (Get-NetUDPEndpoint | Where-Object {$_.State -eq "Established" -and $_.LocalAddress -notlike "127.*" -and $_.RemoteAddress -notlike "127.*"} | Sort-Object -Unique LocalAddress,LocalPort,RemoteAddress,RemotePort,State | Format-Table -AutoSize | Out-String)
)

Write-Output "Results saved to $outputFile"
