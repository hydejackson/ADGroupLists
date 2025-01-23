# Description: Generates directory of lists of groups for each title in a given office

param (
    [string]$inputFile,
    [int]$PercentageThreshold = 100
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the getgroups.ps1 script (relative path)
$getGroupsScript = Join-Path -Path $PSScriptRoot -ChildPath "getgroups.ps1"

# Path to the master folder (relative path)
$masterFolder = "main-$PercentageThreshold-$(Get-Date -Format 'yyyyMMddHHmmss')"

# Create the master folder if it doesn't exist
if (-Not (Test-Path -Path $masterFolder)) {
    New-Item -ItemType Directory -Path $masterFolder
}

# Read the input file line by line
Get-Content -Path $inputFile | ForEach-Object {
    $line = $_
    $parts = $line -split ", "
    $title = $parts[0].Trim()
    $office = $parts[1].Trim()

    # Sanitize the Title and Office values for valid directory names
    $sanitizedTitle = $title -replace '/', '_'
    $sanitizedOffice = $office -replace '/', '_'

    # Create the office folder if it doesn't exist
    $officeFolder = Join-Path -Path $masterFolder -ChildPath $sanitizedOffice
    if (-Not (Test-Path -Path $officeFolder)) {
        New-Item -ItemType Directory -Path $officeFolder
    }

    # Define the output file path
    $outputFile = Join-Path -Path $officeFolder -ChildPath "$sanitizedTitle.txt"

    # Execute the getgroups.ps1 script and redirect output to the appropriate file
    powershell.exe -File $getGroupsScript -Title $title -Office $office -PercentageThreshold $PercentageThreshold > $outputFile
}