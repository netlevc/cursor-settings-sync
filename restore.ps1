# Cursor Settings Restore Script for Windows
# This script restores Cursor settings from the backup

param(
    [switch]$Force = $false
)

Write-Host "🔄 Starting Cursor Settings Restore..." -ForegroundColor Cyan

# Define paths
$CursorUserPath = "$env:APPDATA\Cursor\User"
$BackupDir = ".\settings"

# Check if backup directory exists
if (-not (Test-Path $BackupDir)) {
    Write-Host "❌ Error: Backup directory not found at $BackupDir" -ForegroundColor Red
    Write-Host "   Make sure you've run 'git pull' or 'git clone' to get the latest settings." -ForegroundColor Yellow
    exit 1
}

# Check if Cursor is installed
if (-not (Test-Path "$env:APPDATA\Cursor")) {
    Write-Host "❌ Error: Cursor does not appear to be installed" -ForegroundColor Red
    Write-Host "   Please install Cursor first: https://cursor.sh/" -ForegroundColor Yellow
    exit 1
}

# Create User directory if it doesn't exist
if (-not (Test-Path $CursorUserPath)) {
    New-Item -ItemType Directory -Path $CursorUserPath -Force | Out-Null
    Write-Host "✅ Created Cursor User directory" -ForegroundColor Green
}

# Warn if Cursor is running
$cursorProcess = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
if ($cursorProcess) {
    Write-Host "⚠ WARNING: Cursor appears to be running!" -ForegroundColor Yellow
    Write-Host "   It's recommended to close Cursor before restoring settings." -ForegroundColor Yellow
    if (-not $Force) {
        $response = Read-Host "   Continue anyway? (y/n)"
        if ($response -ne 'y') {
            Write-Host "❌ Restore cancelled" -ForegroundColor Red
            exit 1
        }
    }
}

# Function to restore file if it exists in backup
function Restore-IfExists {
    param($Source, $Destination)
    if (Test-Path $Source) {
        $destDir = Split-Path $Destination -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Host "  ✓ Restored $(Split-Path $Source -Leaf)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ⊘ Skipped $(Split-Path $Source -Leaf) (not in backup)" -ForegroundColor Gray
        return $false
    }
}

# Function to restore directory if it exists in backup
function Restore-DirIfExists {
    param($Source, $Destination)
    if (Test-Path $Source) {
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Recurse -Force
        }
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Host "  ✓ Restored $(Split-Path $Source -Leaf)/ directory" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ⊘ Skipped $(Split-Path $Source -Leaf)/ (not in backup)" -ForegroundColor Gray
        return $false
    }
}

Write-Host "`n📦 Restoring Cursor settings..." -ForegroundColor Cyan

# Restore main settings files
Restore-IfExists "$BackupDir\settings.json" "$CursorUserPath\settings.json"
Restore-IfExists "$BackupDir\keybindings.json" "$CursorUserPath\keybindings.json"

# Restore snippets
Restore-DirIfExists "$BackupDir\snippets" "$CursorUserPath\snippets"

# Restore storage.json if it exists
if (Test-Path "$BackupDir\storage.json") {
    $globalStoragePath = "$env:APPDATA\Cursor\User\globalStorage"
    if (-not (Test-Path $globalStoragePath)) {
        New-Item -ItemType Directory -Path $globalStoragePath -Force | Out-Null
    }
    Restore-IfExists "$BackupDir\storage.json" "$globalStoragePath\storage.json"
}

# Restore extensions
Write-Host "`n📋 Restoring extensions..." -ForegroundColor Cyan
if (Test-Path "$BackupDir\extensions.txt") {
    # Try multiple possible locations for Cursor executable
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Cursor\resources\app\bin\cursor.cmd",
        "C:\Program Files\cursor\resources\app\bin\cursor.cmd",
        "${env:ProgramFiles}\cursor\resources\app\bin\cursor.cmd"
    )

    $CursorExe = $null
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $CursorExe = $path
            break
        }
    }

    # If not found in standard locations, try PATH
    if (-not $CursorExe -and (Get-Command cursor -ErrorAction SilentlyContinue)) {
        $CursorExe = "cursor"
    }

    if ($CursorExe) {
        $extensions = Get-Content "$BackupDir\extensions.txt"
        $extensionCount = $extensions.Count
        Write-Host "  Found $extensionCount extensions to install" -ForegroundColor White
        
        $installed = 0
        $skipped = 0
        foreach ($extension in $extensions) {
            if ($extension.Trim()) {
                Write-Host "  Installing: $extension" -ForegroundColor Gray
                & $CursorExe --install-extension $extension --force 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $installed++
                } else {
                    $skipped++
                    Write-Host "    ⚠ Failed to install: $extension" -ForegroundColor Yellow
                }
            }
        }
        Write-Host "  ✓ Installed $installed extensions ($skipped skipped/failed)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Warning: Could not find Cursor executable to install extensions" -ForegroundColor Yellow
        Write-Host "    You can install extensions manually from: $BackupDir\extensions.txt" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⊘ No extensions list found in backup" -ForegroundColor Gray
}

# Show restore information
Write-Host "`n📊 Restore Summary:" -ForegroundColor Cyan
Write-Host "  Source: $BackupDir" -ForegroundColor White
Write-Host "  Destination: $CursorUserPath" -ForegroundColor White
Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White

if (Test-Path "$BackupDir\metadata.json") {
    $metadata = Get-Content "$BackupDir\metadata.json" | ConvertFrom-Json
    Write-Host "`n  Backup info:" -ForegroundColor Cyan
    Write-Host "    Last backup: $($metadata.lastBackup)" -ForegroundColor White
    Write-Host "    Platform: $($metadata.platform)" -ForegroundColor White
}

Write-Host "`n✅ Restore completed successfully!" -ForegroundColor Green
Write-Host "   Please restart Cursor to apply all changes." -ForegroundColor Yellow

