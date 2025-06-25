# Input files
$dependenciesFile = "formatted_dependencies.txt"
$licensesFile = "licenses.txt"
$outputFile = "sbom-result.txt"

# Column widths
$dependencyWidth = 50
$currentVersionWidth = 15
$latestVersionWidth = 15
$licenseWidth = 25
$licenseUrlWidth = 60

# Output header with proper spacing
$header = "{0}{1}{2}{3}{4}" -f `
    "Dependency".PadRight($dependencyWidth), `
    "Current Version".PadRight($currentVersionWidth), `
    "Latest Version".PadRight($latestVersionWidth), `
    "License".PadRight($licenseWidth), `
    "License URL"

$header | Out-File -FilePath $outputFile

# Initialize the hash table for licenses
$licenseInfo = @{}

# Read licenses file into a hash table
try {
    Get-Content -Path $licensesFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq "") { return } # Skip empty lines

        # Skip the header line and any lines starting with a separator or non-license info
        if ($line -like "*Reference*" -or $line -like "*----*") {
            return
        }

        # Remove leading and trailing pipes and extra spaces
        $line = $line.TrimStart('|').TrimEnd('|').Trim()

        # Adjust the parsing based on the '|' delimiter
        $parts = $line -split '\s*\|\s*'
        if ($parts.Length -eq 4) {
            $dependency = $parts[0].Trim()
            $version = $parts[1].Trim()
            $license = $parts[2].Trim()
            $licenseUrl = $parts[3].Trim()

            if (-not $licenseInfo.ContainsKey($dependency)) {
                $licenseInfo[$dependency] = @{
                    Version = $version
                    License = $license
                    LicenseUrl = $licenseUrl
                }
            } else {
                Write-Output "Duplicate entry found for ${dependency} in ${licensesFile}."
            }
        } else {
            Write-Output "Skipping invalid line in ${licensesFile}: ${line}"
        }
    }
} catch {
    Write-Error "Error reading ${licensesFile}: $_"
}

# Read dependencies file and merge with license info
$headerSkipped = $false
try {
    Get-Content -Path $dependenciesFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq "") { return } # Skip empty lines

        # Skip the first line (header) from the dependencies file
        if (-not $headerSkipped) {
            $headerSkipped = $true
            return
        }

        # Adjust the parsing logic based on expected format
        $fields = $line -split '\s+', 3
        if ($fields.Length -ge 3) {
            $depTrimmed = $fields[0].Trim()
            $currentVersion = $fields[1].Trim()
            $latestVersion = $fields[2].Trim()

            if ($licenseInfo.ContainsKey($depTrimmed)) {
                $licenseData = $licenseInfo[$depTrimmed]
                $license = $licenseData.License
                $licenseUrl = $licenseData.LicenseUrl
                
                # Check for version differences and append ** if they are different
                if ($currentVersion -ne $latestVersion) {
                    $currentVersion += "**"
                    $latestVersion += "**"
                }
                
                $outputLine = "{0}{1}{2}{3}{4}" -f `
                    $depTrimmed.PadRight($dependencyWidth), `
                    $currentVersion.PadRight($currentVersionWidth), `
                    $latestVersion.PadRight($latestVersionWidth), `
                    $license.PadRight($licenseWidth), `
                    $licenseUrl
                $outputLine | Out-File -FilePath $outputFile -Append
                $licenseInfo.Remove($depTrimmed) # Remove matched entry
            } else {
                $outputLine = "{0}{1}{2}{3}{4}" -f `
                    $depTrimmed.PadRight($dependencyWidth), `
                    $currentVersion.PadRight($currentVersionWidth), `
                    $latestVersion.PadRight($latestVersionWidth), `
                    "N/A".PadRight($licenseWidth), `
                    "N/A"
                $outputLine | Out-File -FilePath $outputFile -Append
            }
        } else {
            Write-Output "Skipping invalid line in ${dependenciesFile}: ${line}"
        }
    }
} catch {
    Write-Error "Error reading ${dependenciesFile}: $_"
}

# Add remaining entries from licenses file that were not matched
foreach ($depTrimmed in $licenseInfo.Keys) {
    $licenseData = $licenseInfo[$depTrimmed]
    $licenseVersion = $licenseData.Version
    $license = $licenseData.License
    $licenseUrl = $licenseData.LicenseUrl
    $outputLine = "{0}{1}{2}{3}{4}" -f `
        $depTrimmed.PadRight($dependencyWidth), `
        $licenseVersion.PadRight($currentVersionWidth), `
        $licenseVersion.PadRight($latestVersionWidth), `
        $license.PadRight($licenseWidth), `
        $licenseUrl
    $outputLine | Out-File -FilePath $outputFile -Append
}
