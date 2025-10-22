# Cursor Settings Sync - Initial Setup Script for Windows
# This script initializes the git repository and creates a GitHub repository

param(
    [string]$RepoName = "cursor-settings-sync",
    [switch]$Private = $false
)

Write-Host "🚀 Cursor Settings Sync - Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if GitHub CLI is installed
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: GitHub CLI (gh) is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install it from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ GitHub CLI found" -ForegroundColor Green

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install it from: https://git-scm.com/" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ Git found" -ForegroundColor Green

# Check GitHub CLI authentication
Write-Host "`n🔐 Checking GitHub authentication..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not authenticated with GitHub CLI" -ForegroundColor Red
    Write-Host "`n📝 Please authenticate with GitHub CLI:" -ForegroundColor Yellow
    Write-Host "   Run: gh auth login" -ForegroundColor White
    exit 1
}
Write-Host "  ✓ Authenticated with GitHub" -ForegroundColor Green

# Initialize git repository if not already initialized
Write-Host "`n📁 Initializing Git repository..." -ForegroundColor Cyan
if (Test-Path ".git") {
    Write-Host "  ℹ Git repository already initialized" -ForegroundColor Yellow
} else {
    git init
    Write-Host "  ✓ Git repository initialized" -ForegroundColor Green
}

# Create initial .gitignore if it doesn't exist
if (-not (Test-Path ".gitignore")) {
    Write-Host "⚠ Warning: .gitignore not found. This should not happen!" -ForegroundColor Yellow
}

# Create GitHub repository
Write-Host "`n🌐 Creating GitHub repository..." -ForegroundColor Cyan
$visibility = if ($Private) { "--private" } else { "--public" }

$repoExists = gh repo view $RepoName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ℹ Repository '$RepoName' already exists" -ForegroundColor Yellow
    $response = Read-Host "  Do you want to use the existing repository? (y/n)"
    if ($response -ne 'y') {
        Write-Host "❌ Setup cancelled" -ForegroundColor Red
        exit 1
    }
} else {
    gh repo create $RepoName $visibility --source=. --description "Cursor Editor Settings Backup" --push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ GitHub repository created: $RepoName" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create GitHub repository" -ForegroundColor Red
        exit 1
    }
}

# Configure git remote if not already set
$remoteUrl = git remote get-url origin 2>$null
if (-not $remoteUrl) {
    Write-Host "`n🔗 Configuring git remote..." -ForegroundColor Cyan
    $username = gh api user --jq .login
    git remote add origin "https://github.com/$username/$RepoName.git"
    Write-Host "  ✓ Git remote configured" -ForegroundColor Green
} else {
    Write-Host "`n  ℹ Git remote already configured: $remoteUrl" -ForegroundColor Yellow
}

# Create initial README if it doesn't exist
if (-not (Test-Path "README.md")) {
    Write-Host "⚠ Warning: README.md not found. This should not happen!" -ForegroundColor Yellow
}

# Create settings directory
if (-not (Test-Path "settings")) {
    New-Item -ItemType Directory -Path "settings" | Out-Null
    Write-Host "  ✓ Created settings directory" -ForegroundColor Green
}

# Initial commit if needed
Write-Host "`n📝 Creating initial commit..." -ForegroundColor Cyan
git add .
$status = git status --porcelain
if ($status) {
    git commit -m "Initial commit: Setup Cursor settings sync"
    Write-Host "  ✓ Initial commit created" -ForegroundColor Green
    
    # Push to GitHub
    git branch -M main
    git push -u origin main
    Write-Host "  ✓ Pushed to GitHub" -ForegroundColor Green
} else {
    Write-Host "  ℹ No changes to commit" -ForegroundColor Yellow
}

Write-Host "`n✅ Setup completed successfully!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run backup.ps1 to backup your current Cursor settings" -ForegroundColor White
Write-Host "  2. On a new machine, clone this repo and run restore.ps1" -ForegroundColor White
Write-Host "`n🔗 Repository URL:" -ForegroundColor Cyan
$username = gh api user --jq .login
Write-Host "   https://github.com/$username/$RepoName" -ForegroundColor White

