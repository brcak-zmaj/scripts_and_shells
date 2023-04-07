# List of servers to remote into
$serverList = @("Server1", "Server2", "Server3")

# Log file
$logFile = "C:\temp\perf_counter_$(Get-Date -Format 'yyyyMMddHHmmss').log"

# Function to detect and rebuild failed performance counters
function Rebuild-FailedPerfCounters {
    param(
        [string]$serverName
    )

    try {
        # Test if the server is online
        if (Test-Connection -ComputerName $serverName -Count 1 -Quiet) {
            # Create a new PSSession with the server using the current session credentials
            $session = New-PSSession -ComputerName $serverName

            # Execute the following script block in the remote session
            Invoke-Command -Session $session -ScriptBlock {
                $failedCounters = @()

                # Get all available performance counter categories
                $categories = Get-Counter -ListSet *

                # Iterate through categories to find failed counters
                foreach ($category in $categories) {
                    try {
                        Get-Counter -ListSet $category.CounterSetName | Out-Null
                    } catch {
                        $failedCounters += $category.CounterSetName
                    }
                }

                # Check if there are any failed counters
                if ($failedCounters.Count -gt 0) {
                    $message = "Failed performance counters on $($serverName):`n"
                    $failedCounters | ForEach-Object { $message += "- $_`n" }
                    Add-Content -Path $using:logFile -Value $message

                    # Rebuild performance counters
                    $rebuildMessage = "Rebuilding performance counters on $($serverName)..."
                    Add-Content -Path $using:logFile -Value $rebuildMessage
                    lodctr /R | Out-Null
                    $rebuildMessage = "Performance counters rebuilt on $($serverName)."
                    Add-Content -Path $using:logFile -Value $rebuildMessage
                } else {
                    $message = "No failed performance counters found on $($serverName)."
                    Add-Content -Path $using:logFile -Value $message
                }
            }

            # Close the remote session
            Remove-PSSession -Session $session
        } else {
            $message = "Unable to connect to $($serverName). Please check the server status."
            Add-Content -Path $logFile -Value $message
        }
    } catch {
        $errorMessage = "Error occurred on $($serverName): $_"
        Add-Content -Path $logFile -Value $errorMessage
    }
}

# Iterate through servers and rebuild failed performance counters
foreach ($server in $serverList) {
    Rebuild-FailedPerfCounters -serverName $server
}

# Write log file content to Windows Event Log with Event ID 315
if (Test-Path $logFile) {
    $logContent = Get-Content $logFile -Raw
    Write-EventLog -LogName Application -Source 'PowerShell' -EntryType Information -EventId 315 -Message $logContent
}
