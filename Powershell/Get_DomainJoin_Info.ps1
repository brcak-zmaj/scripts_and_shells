#######################################
# Define output file path
#######################################
$outputFilePath = "C:\Temp\accounts.txt"

#######################################
# Get all local service accounts
#######################################
$serviceAccounts = Get-WmiObject -Class Win32_Service -Filter "StartName LIKE '%\%' and StartName NOT LIKE '%SYSTEM%' and StartName NOT LIKE '%LOCAL SERVICE%' and StartName NOT LIKE '%NETWORK SERVICE%'" |
                   Select-Object -ExpandProperty StartName -Unique

#######################################
# Get all local AD accounts
#######################################
$adAccounts = Get-WmiObject -Class Win32_UserAccount -Filter "Domain='$env:COMPUTERNAME' and LocalAccount='True' and SID NOT LIKE 'S-1-5-21*' and Name NOT LIKE 'Guest'" |
              Select-Object -ExpandProperty Name -Unique

#######################################
# Get all domain groups and OUs
#######################################
$domainGroups = Get-ADGroup -Filter * -Properties * | Select-Object Name, Description, GroupCategory, GroupScope, DistinguishedName
$ous = Get-ADOrganizationalUnit -Filter * | Select-Object Name, Description, DistinguishedName

#######################################
# Combine all results into a single array
#######################################
$allAccounts = $serviceAccounts + $adAccounts

#######################################
# Output results to file
#######################################
Write-Output "Service Accounts:`r`n$($serviceAccounts -join "`r`n")`r`n`r`nAD Accounts:`r`n$($adAccounts -join "`r`n")`r`n`r`nDomain Groups:`r`n$($domainGroups | Format-Table -AutoSize | Out-String)`r`n`r`nOUs:`r`n$($ous | Format-Table -AutoSize | Out-String)" | Out-File $outputFilePath
