# Prompt the user for the domain name and administrator credentials
$domain = Read-Host "Enter the domain name"
$username = Read-Host "Enter the administrator username"
$password = Read-Host "Enter the administrator password" -AsSecureString

# Test the domain trust
Test-ComputerSecureChannel -Credential (New-Object System.Management.Automation.PSCredential ($username, $password)) -Repair -Verbose

# If the domain trust test fails, reset the computer account and rejoin the domain
if ($LASTEXITCODE -ne 0) {
  Reset-ComputerMachinePassword -Credential (New-Object System.Management.Automation.PSCredential ($username, $password)) -Server $domain -Verbose
  Remove-Computer -UnjoinDomainCredential (New-Object System.Management.Automation.PSCredential ($username, $password)) -Verbose
  Add-Computer -DomainName $domain -Credential (New-Object System.Management.Automation.PSCredential ($username, $password)) -Verbose
}
