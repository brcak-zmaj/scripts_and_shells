################################################
# Create a variable to store troubleshooting steps
################################################
$troubleshooting = ""

################################################
# Check if the Windows Update service is running
################################################
$updateService = Get-Service -Name wuauserv -ComputerName $serverName
if ($updateService.Status -ne "Running") {
    $troubleshooting += "The Windows Update service is not running.`n"
}

################################################
# Check if there are pending reboot or pending updates
################################################
$pendingReboot = (Get-CimInstance Win32_OperatingSystem -ComputerName $serverName).RebootPending
$updateSession = New-Object -ComObject Microsoft.Update.Session -ArgumentList $serverName
$updateSearcher = $updateSession.CreateUpdateSearcher()
$updateCount = $updateSearcher.GetTotalHistoryCount()
if ($updateCount -eq 0) {
    $troubleshooting += "There are no available updates.`n"
} else {
    $updates = $updateSearcher.QueryHistory(0, $updateCount) | Where-Object { $_.ResultCode -eq "2" -and $_.Operation -eq 1 }
    if ($updates.Count -eq 0) {
        $troubleshooting += "There are no pending updates.`n"
    }
    if ($pendingReboot) {
        $troubleshooting += "There is a pending reboot.`n"
    }
}

# Output the troubleshooting steps to a file
$troubleshooting | Out-File -FilePath "C:\temp\patching_troubleshooting.txt"
