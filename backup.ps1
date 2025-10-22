# Cursor Settings Backup Script for Windows
# This script backs up Cursor settings to the current directory and pushes to GitHub

param(
    [string]$CommitMessage = "Update Cursor settings - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

Write-Host "🔄 Starting Cursor Settings Backup..." -ForegroundColor Cyan

# Define paths
$CursorUserPath = "$env:APPDATA\Cursor\User"
$BackupDir = ".\settings"

# Check if Cursor settings exist
if (-not (Test-Path $CursorUserPath)) {
    Write-Host "❌ Error: Cursor settings not found at $CursorUserPath" -ForegroundColor Red
    Write-Host "   Make sure Cursor is installed and has been run at least once." -ForegroundColor Yellow
    exit 1
}

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Write-Host "✅ Created backup directory: $BackupDir" -ForegroundColor Green
}

# Function to copy file if it exists
function Copy-IfExists {
    param($Source, $Destination)
    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Host "  ✓ Copied $(Split-Path $Source -Leaf)" -ForegroundColor Green
        return $true
    }
    return $false
}

# Function to copy directory if it exists
function Copy-DirIfExists {
    param($Source, $Destination)
    if (Test-Path $Source) {
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Recurse -Force
        }
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Host "  ✓ Copied $(Split-Path $Source -Leaf)/ directory" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "`n📦 Backing up Cursor settings..." -ForegroundColor Cyan

# Backup main settings files
Copy-IfExists "$CursorUserPath\settings.json" "$BackupDir\settings.json"
Copy-IfExists "$CursorUserPath\keybindings.json" "$BackupDir\keybindings.json"

# Backup snippets
Copy-DirIfExists "$CursorUserPath\snippets" "$BackupDir\snippets"

# Backup extensions list
if (Test-Path "$env:APPDATA\Cursor\User\globalStorage\storage.json") {
    Copy-IfExists "$env:APPDATA\Cursor\User\globalStorage\storage.json" "$BackupDir\storage.json"
}

# Get list of installed extensions
Write-Host "`n📋 Backing up extensions list..." -ForegroundColor Cyan
$CursorExe = "$env:LOCALAPPDATA\Programs\Cursor\resources\app\bin\cursor.cmd"
if (Test-Path $CursorExe) {
    & $CursorExe --list-extensions > "$BackupDir\extensions.txt"
    Write-Host "  ✓ Saved extensions list" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Warning: Could not find Cursor executable to list extensions" -ForegroundColor Yellow
}

# Create metadata file
$Metadata = @{
    lastBackup = Get-Date -Format "o"
    platform = "Windows"
    cursorVersion = "unknown"
} | ConvertTo-Json

$Metadata | Out-File -FilePath "$BackupDir\metadata.json" -Encoding UTF8
Write-Host "  ✓ Created metadata file" -ForegroundColor Green

# Git operations
Write-Host "`n📤 Pushing to GitHub..." -ForegroundColor Cyan

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "⚠ Git repository not initialized. Run setup.ps1 first!" -ForegroundColor Yellow
    exit 1
}

# Add all changes
git add settings/

# Check if there are changes to commit
$status = git status --porcelain settings/
if ($status) {
    git commit -m $CommitMessage
    git push
    Write-Host "`n✅ Backup completed and pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "`n✅ No changes detected. Settings are up to date!" -ForegroundColor Green
}

Write-Host "`n📊 Backup Summary:" -ForegroundColor Cyan
Write-Host "  Source: $CursorUserPath" -ForegroundColor White
Write-Host "  Backup: $BackupDir" -ForegroundColor White
Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White

