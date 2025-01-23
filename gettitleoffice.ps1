# Description: This script retrieves unique combinations of title and office from Active Directory users and writes them to a file.

param (
    [string]$Office = '*' # Default value is wildcard
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to check if a string is valid (not blank, not just numbers, and does not begin with a number)
function IsValidString {
    param (
        [string]$str
    )
    return -not [string]::IsNullOrWhiteSpace($str) -and $str -notmatch '^\d'
}

# Query Active Directory for all users and select the title and office properties
$users = Get-ADUser -Filter {Enabled -eq $true -and Office -like $Office} -Property Title, Office | Select-Object Title, Office

# Filter out invalid titles and offices
$filteredUsers = $users | Where-Object { 
    IsValidString $_.Title -and IsValidString $_.Office 
}

# Get unique combinations of title and office
$uniqueCombinations = $filteredUsers | Sort-Object Title, Office -Unique

# Output the unique combinations to a file
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "unique_title_office_combinations-$(Get-Date -Format 'yyyyMMddHHmmss').txt"
$uniqueCombinations | ForEach-Object { "$($_.Title), $($_.Office)" } | Out-File -FilePath $outputFile

Write-Output "Unique title and office combinations have been written to $outputFile"