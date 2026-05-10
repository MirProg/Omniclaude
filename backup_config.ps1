$source = "$env:APPDATA\OmniRoute"
$dest = "$PSScriptRoot\omniroute_backup"

Write-Host "Backing up OmniRoute configuration..."

if (-not (Test-Path $dest)) { 
    New-Item -ItemType Directory -Path $dest | Out-Null 
}

# Copy database files (contains your combos, keys, and rules)
if (Test-Path "$source\*.sqlite*") {
    Copy-Item "$source\*.sqlite*" -Destination $dest -Force
}

# Copy environment file
if (Test-Path "$source\server.env") {
    Copy-Item "$source\server.env" -Destination $dest -Force
}

# Copy config folder if it exists
if (Test-Path "$source\config") {
    Copy-Item "$source\config" -Destination $dest -Recurse -Force
}

Write-Host "Backup complete! Files saved to: $dest"
Write-Host "Don't forget to push to GitHub!"
