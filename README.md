## Description


GenerateGroupLists.ps1

 is a PowerShell script designed to generate a directory of lists of groups for each title in a given office. The script reads an input file containing titles and offices, processes the data, and organizes it into a structured directory format.

## Prerequisites
- PowerShell
- Active Directory module

## Parameters
- `-inputFile` (string): Path to the input file containing titles and offices. Each line in the file should be in the format `Title, Office`.
- `-PercentageThreshold` (int, optional): A threshold value used in the naming of the master folder. Default is 100.

## Usage
1. Ensure you have the Active Directory module installed.
2. Prepare an input file with the required format (`Title, Office`).
3. Run the script with the necessary parameters.

### Example
```powershell
.\GenerateGroupLists.ps1 -inputFile "path\to\inputfile.txt" -PercentageThreshold 80
```

## Script Details
- The script imports the Active Directory module.
- It sets the path to the getgroups.ps1 script.
- It creates a master folder named based on the percentage threshold and the current date and time.
- It reads the input file line by line, processes each line to extract and sanitize the title and office values.
- It creates directories for each office and title as needed.

## Notes
- Ensure the getgroups.ps1 script is located in the same directory as generategrouplists.ps1
- The script sanitizes directory names by replacing `/` with `_`.

## License
This project is licensed under the MIT License.
