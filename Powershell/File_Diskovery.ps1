# Output file
$outputFile = "C:\temp\LargeFiles_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Set the minimum file size (1GB) and user folder size (4GB)
$minFileSize = 1GB
$minUserFolderSize = 4GB

# Function to search for large files in a folder
function Search-LargeFiles {
    param(
        [string]$folderPath,
        [long]$minSize
    )

    # Check if the folder exists
    if (Test-Path $folderPath) {
        # Get all files in the folder and its subfolders
        $files = Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction SilentlyContinue

        # Filter files larger than the minimum size
        $largeFiles = $files | Where-Object { $_.Length -gt $minSize }

        # Output folder path, size, and large files
        if ($largeFiles) {
            $totalSize = ($largeFiles | Measure-Object -Property Length -Sum).Sum / 1GB
            $output = "Folder: $($folderPath)`nTotal Size: $($totalSize.ToString('N2')) GB`nFiles larger than 1GB:`n"

            foreach ($file in $largeFiles) {
                $fileSize = $file.Length / 1GB
                $output += "  - $($file.FullName) - $($fileSize.ToString('N2')) GB`n"
            }

            Add-Content -Path $outputFile -Value $output
        }
    }
}

# Search user folders
$usersFolder = "C:\Users"
$users = Get-ChildItem -Path $usersFolder -Directory -ErrorAction SilentlyContinue

foreach ($user in $users) {
    $userFolderPath = Join-Path $usersFolder $user.Name
    $userFolderSize = (Get-ChildItem -Path $userFolderPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

    # Check if the user folder size exceeds the minimum user folder size
    if ($userFolderSize -gt $minUserFolderSize) {
        $userFolderSizeGB = $userFolderSize / 1GB
        $output = "User folder: $($userFolderPath)`nTotal Size: $($userFolderSizeGB.ToString('N2')) GB (exceeds 4GB)`n"
        Add-Content -Path $outputFile -Value $output
    }

    Search-LargeFiles -folderPath $userFolderPath -minSize $minFileSize
}

# Search temp folders
$tempFolders = @(
    "C:\Windows\Temp",
    "C:\Temp"
)

foreach ($tempFolder in $tempFolders) {
    Search-LargeFiles -folderPath $tempFolder -minSize $minFileSize
}
