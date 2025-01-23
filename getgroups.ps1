# Description: This script gets the groups of users based on their title and office

# so, get a list of users based on some condition, maybe two (title, site?)
# that means i need to get a list of titles, maybe first get a list of all users for a site
# group the users by title, then run the prinicipalgroupmembership thing to get all their group names
# so, site > title > user > groups would be the structure

# idea for this iteration of this script by Aubs from this stackoverflow post:
# https://stackoverflow.com/questions/64606936/powershell-throws-error-with-get-adprinciplegroup

param (
    [string]$Title,
    [string]$Office,
    [int]$PercentageThreshold = 100 # Default value is 100
)

# Import the Active Directory module
Import-Module ActiveDirectory

# Construct the filter based on the provided parameters
$filter = @()
$filter += "Enabled -eq 'True'"
if ($Title) {
    $filter += "Title -like '$Title'"
}
if ($Office) {
    $filter += "Office -like '$Office'"
}
$filterString = $filter -join " -and "

# Get the AD users based on the filter
[array] $users = @()
$users = Get-ADUser -Filter $filterString -Properties MemberOf

# Filter out any entries that aren't user objects
$users = $users | Where-Object { $_ -is [Microsoft.ActiveDirectory.Management.ADUser] }

# Get the count of users
$userCount = $users.Count

# Initialize a hashtable to store the group names and their counts
$groupCounts = @{}

# Loop through each user and get their group memberships
foreach ($user in $users) {
    $user.MemberOf | ForEach-Object {
        $group = Get-ADGroup -Identity $_ -Properties CanonicalName
        $groupName = ($group.CanonicalName -split '/')[ -1 ]
        if ($groupCounts.ContainsKey($groupName)) {
            $groupCounts[$groupName]++
        } else {
            $groupCounts[$groupName] = 1
        }
    }
}

# Calculate the threshold count
if ($userCount -eq 0) {
    Write-Output "No users found based on the provided filter."
    exit
}
else {
    $thresholdCount = [math]::Ceiling($userCount * ($PercentageThreshold / 100))
}

# Filter the groups based on the threshold and ensure uniqueness using a HashSet
$hashSet = New-Object System.Collections.Generic.HashSet[string]
$groupCounts.GetEnumerator() | Where-Object { $_.Value -ge $thresholdCount } | ForEach-Object {
    $hashSet.Add($_.Key) | Out-Null
}

$filteredGroups = $hashSet

Write-Output $filteredGroups

# # Sanitize the Title and Office parameters for the file name, _ replaces invalid characters
# $titlePart = if ($Title) { $Title -replace '[^a-zA-Z0-9]', '_' } else { "default" }
# $officePart = if ($Office) { $Office -replace '[^a-zA-Z0-9]', '_' } else { "default" }
# $outputFileName = "${titlePart}_${officePart}_groups.txt"
# $outputFilePath = Join-Path -Path $PSScriptRoot -ChildPath $outputFileName

# # Output the unique canonical names to the terminal
# $filteredGroups | ForEach-Object { Write-Output $_ }

# # Output the unique canonical names to the file
# $filteredGroups | Out-File -FilePath $outputFilePath

# Write-Output "Filtered groups have been written to $outputFilePath"