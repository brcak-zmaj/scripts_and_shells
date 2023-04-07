# List of servers to check connectivity
$serverList = @("Server1", "Server2", "Server3")

# Port range to check for open ports
$portRange = 1..1024

# Output file
$outputFile = "C:\temp\OpenPorts_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Function to check connectivity and open ports
function Check-ConnectivityAndOpenPorts {
    param(
        [string]$serverName,
        [array]$ports
    )

    # Test if the server is online with a ping test
    $pingResult = Test-Connection -ComputerName $serverName -Count 1 -Quiet

    if ($pingResult) {
        $output = "Ping test succeeded for $($serverName)."
        Add-Content -Path $outputFile -Value $output

        # Check for open ports
        $openPorts = @()
        foreach ($port in $ports) {
            $connection = Test-NetConnection -ComputerName $serverName -Port $port
            if ($connection.TcpTestSucceeded) {
                $openPorts += $port
            }
        }

        # Output open ports
        if ($openPorts.Count -gt 0) {
            $output = "Open ports on $($serverName):`n" + ($openPorts -join ', ')
            Add-Content -Path $outputFile -Value $output
        } else {
            $output = "No open ports found on $($serverName)."
            Add-Content -Path $outputFile -Value $output
        }
    } else {
        $output = "Unable to ping $($serverName). Please check the server status."
        Add-Content -Path $outputFile -Value $output
    }
}

# Iterate through servers and check connectivity and open ports
foreach ($server in $serverList) {
    Check-ConnectivityAndOpenPorts -serverName $server -ports $portRange
}
