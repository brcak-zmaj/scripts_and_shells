# Output file
$outputFile = "C:\temp\PerfCounterRebuild_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Function to rebuild performance counters
function Rebuild-PerformanceCounters {
    $lodctrOutput = lodctr /R
    Add-Content -Path $outputFile -Value "Rebuilding performance counters: `n$lodctrOutput`n"
    return ($LASTEXITCODE -eq 0)
}

# Rebuild performance counters and check if successful
$rebuildSuccess = Rebuild-PerformanceCounters

if (-not $rebuildSuccess) {
    Add-Content -Path $outputFile -Value "Initial rebuild failed. Retrying...`n"
    $rebuildSuccess = Rebuild-PerformanceCounters
}

if ($rebuildSuccess) {
    Add-Content -Path $outputFile -Value "Performance counters successfully rebuilt.`n"
} else {
    Add-Content -Path $outputFile -Value "Failed to rebuild performance counters after retrying.`n"
}
