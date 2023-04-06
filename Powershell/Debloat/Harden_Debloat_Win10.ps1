# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "Please run this script as an administrator."
  Exit
}

#########################################################
# Vars
#########################################################

# Set log file path
$logFilePath = "C:\Temp\cleanup_log.txt"

# Define list of directories to clean up
$directories = @(
    "$env:TEMP",
    "$env:LOCALAPPDATA\Temp",
    "$env:USERPROFILE\Downloads",
    #"$env:USERPROFILE\Documents",
    "C:\Windows\Temp",
    "C:\Windows\Prefetch",
    "C:\Windows\SoftwareDistribution\Download",
    "C:\Windows\Logs",
    "C:\ProgramData\Microsoft\Windows\WER\ReportArchive",
    "C:\ProgramData\Microsoft\Windows\WER\ReportQueue",
    "C:\ProgramData\Microsoft\Windows Defender\Scans\History",
    "C:\ProgramData\Microsoft\Windows Defender\LocalCopy",
    "C:\ProgramData\Package Cache",
    "C:\Program Files (x86)\Google\Update\Download",
    "C:\Windows\Installer\$PatchCache$"
)

# Define list of file extensions to delete
$fileExtensions = @(
    "*.log",
    "*.tmp",
    "*.dmp",
    "*.bak",
    "*.old"
)

# Define list of applications to uninstall
$applications = @(
    "Microsoft OneDrive",
    "Microsoft Teams",
    "Skype",
    "Zoom",
    "Adobe Acrobat Reader DC",
    "*3dbuilder*",
    "*bingfinance*",
    "*bingnews*",
    "*bingsports*",
    "*bingweather*",
    "*getstarted*",
    "*officehub*",
    "*onenote*",
    "*people*",
    "*skypeapp*",
    "*solitairecollection*",
    "*windowsmaps*",
    "*xbox*",
    "XboxGameOverlay",
)

# Set variables for additional system cleanup operations
$additionalCleanup = @(
    "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft.Windows.Client.Shell.MiracastReceiver",
    "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft.Windows.Cortana",
    "Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Type DWord -Value 1"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisablePCA" -Type DWord -Value 1"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableSR" -Type DWord -Value 1"
    "Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableOTJLogging" -Type DWord -Value 1"
    "Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 0"
)

# Set variables for disabling unnecessary scheduled tasks
$scheduledTasks = @(
    "Get-ScheduledTask "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Disable-ScheduledTask -Verbose"
    "Get-ScheduledTask "\Microsoft\Windows\Application Experience\ProgramDataUpdater" | Disable-ScheduledTask -Verbose"
    "Get-ScheduledTask "\Microsoft\Windows\Application Experience\StartupAppTask" | Disable-ScheduledTask -Verbose"
    "Get-ScheduledTask "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" | Disable-ScheduledTask -Verbose"
    "Get-ScheduledTask "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Disable-ScheduledTask -Verbose"
)
    
# Set variables for Services to disable
$Services = @(
"Get-Service -Name "Xbox*Service*" | Set-Service -StartupType Disabled"
    "Get-Service -Name "wercplsupport" | Set-Service -StartupType Disabled"
    "Get-Service -Name "WerSvc" | Set-Service -StartupType Disabled"
    "Get-Service -Name "WMPNetworkSvc" | Set-Service -StartupType Disabled"
    "Get-Service -Name "WSearch" | Set-Service -StartupType Disabled"
    "Get-Service -Name "DoSvc" | Set-Service -StartupType Disabled"
    "Get-Service -Name "DiagTrack" | Set-Service -StartupType Disabled"
    "Get-Service -Name "dmwappushservice" | Set-Service -StartupType Disabled"

)

#########################################################
# Tasks
#########################################################

# Remove unneeded files
Write-Host "Remove unneeded files..." -ForegroundColor Yellow
foreach ($directory in $directories) {
    if (Test-Path -Path $directory) {
        $files = Get-ChildItem -Path $directory -Recurse -Include $fileExtensions -ErrorAction SilentlyContinue
        if ($files) {
            foreach ($file in $files) {
                Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
                Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Removed file: $($file.FullName)"
            }
        }
    }
}

# Uninstall unneeded applications
Write-Host "Debloating..." -ForegroundColor Yellow
foreach ($application in $applications) {
    if (Get-AppxPackage -Name $application -ErrorAction SilentlyContinue) {
        Get-AppxPackage -Name $application -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Uninstalled application: $application"
    }
}

# Perform additional cleanup operations
foreach ($operation in $additionalCleanup) {
    Write-Host "Performing additional cleanup operation: $operation" -ForegroundColor Yellow
    Invoke-Expression -Command $operation
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Performed additional cleanup operation: $operation."
}

# Disabling unnecessary scheduled tasks
foreach ($operation in $scheduledTasks) {
    Write-Host "Disabling unnecessary scheduled tasks: $operation" -ForegroundColor Yellow
    Invoke-Expression -Command $operation
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disabling unnecessary scheduled tasks: $operation."
}

# Disable Services
foreach ($operation in $Services
    Write-Host "Disable Services: $operation. " -ForegroundColor Yellow
    Invoke-Expression -Command $operation
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable Services: $operation."
}

# Clean recycle bin
Write-Host "Cleaning up recycle bin..." -ForegroundColor Yellow
Clear-RecycleBin -Force

################################################################
Write-Host "Performing Hardening Tasks..." -ForegroundColor Blue
################################################################

# Disable weak ciphers
Write-Host "Disable weak ciphers " -ForegroundColor Blue

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -Force
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable weak ciphers DES"
}

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -Force
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable weak ciphers RC2"
}

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -Force
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable weak ciphers RC2"
}

# Disable SSLv3 and TLS 1.0
Write-Host "Disable SSLv3 and TLS 1.0 " -ForegroundColor Blue

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -Force
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable SSL 3"
}

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -Force
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disable TLS 1"
}

# Set stronger password policies
Write-Host "Set stronger password policies " -ForegroundColor Blue
$policy = Get-WmiObject -Class Win32_AccountPolicy -Namespace "root\rsop\computer"
$policy.SetPasswordComplexity(1)
$policy.MinimumPasswordLength = 12
$policy.MaxPasswordAge = (New-TimeSpan -Days 90).Ticks
$policy.MaxBadPasswordsAllowed = 5
$policy.PasswordHistorySize = 10
$policy.Put()


#########################################################
# Done
#########################################################

Write-Host "Hardening and debloating complete." -ForegroundColor Green
Write-Host "Logs are stored in $logFilePath..." -ForegroundColor Green

