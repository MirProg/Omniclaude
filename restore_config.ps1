$source = "$PSScriptRoot\omniroute_backup"
$dest = "$env:APPDATA\OmniRoute"

Write-Host "Restoring OmniRoute configuration..."

if (-not (Test-Path $source)) {
    Write-Host "Error: Backup folder not found at $source" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dest)) { 
    New-Item -ItemType Directory -Path $dest | Out-Null 
}

# Stop OmniRoute if it's running so we don't lock the database
$omni = Get-Process -Name "OmniRoute*" -ErrorAction SilentlyContinue
if ($omni) {
    Write-Host "Stopping OmniRoute to restore database safely..."
    Stop-Process -Name "OmniRoute*" -Force
    Start-Sleep -Seconds 2
}

# Copy all backed up files back into AppData
Copy-Item "$source\*" -Destination $dest -Recurse -Force

Write-Host "Restore complete! Your combos, API keys, and filters have been restored." -ForegroundColor Green
