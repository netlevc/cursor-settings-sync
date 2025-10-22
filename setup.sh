#!/bin/bash
# Cursor Settings Sync - Initial Setup Script for Linux
# This script initializes the git repository and creates a GitHub repository

REPO_NAME="${1:-cursor-settings-sync}"
PRIVATE_FLAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --private)
            PRIVATE_FLAG="--private"
            shift
            ;;
        *)
            REPO_NAME="$1"
            shift
            ;;
    esac
done

echo -e "\033[0;36m🚀 Cursor Settings Sync - Setup\033[0m"
echo -e "\033[0;36m================================\033[0m\n"

# Check if GitHub CLI is installed
echo -e "\033[0;36m🔍 Checking prerequisites...\033[0m"
if ! command -v gh &> /dev/null; then
    echo -e "\033[0;31m❌ Error: GitHub CLI (gh) is not installed or not in PATH\033[0m"
    echo -e "\033[0;33m   Please install it from: https://cli.github.com/\033[0m"
    exit 1
fi
echo -e "  \033[0;32m✓ GitHub CLI found\033[0m"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "\033[0;31m❌ Error: Git is not installed or not in PATH\033[0m"
    echo -e "\033[0;33m   Please install git\033[0m"
    exit 1
fi
echo -e "  \033[0;32m✓ Git found\033[0m"

# Check GitHub CLI authentication
echo -e "\n\033[0;36m🔐 Checking GitHub authentication...\033[0m"
if ! gh auth status &> /dev/null; then
    echo -e "\033[0;31m❌ Not authenticated with GitHub CLI\033[0m"
    echo -e "\n\033[0;33m📝 Please authenticate with GitHub CLI:\033[0m"
    echo -e "   \033[0;37mRun: gh auth login\033[0m"
    exit 1
fi
echo -e "  \033[0;32m✓ Authenticated with GitHub\033[0m"

# Initialize git repository if not already initialized
echo -e "\n\033[0;36m📁 Initializing Git repository...\033[0m"
if [ -d ".git" ]; then
    echo -e "  \033[0;33mℹ Git repository already initialized\033[0m"
else
    git init
    echo -e "  \033[0;32m✓ Git repository initialized\033[0m"
fi

# Create initial .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo -e "\033[0;33m⚠ Warning: .gitignore not found. This should not happen!\033[0m"
fi

# Create GitHub repository
echo -e "\n\033[0;36m🌐 Creating GitHub repository...\033[0m"
if gh repo view "$REPO_NAME" &> /dev/null; then
    echo -e "  \033[0;33mℹ Repository '$REPO_NAME' already exists\033[0m"
    read -p "  Do you want to use the existing repository? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[0;31m❌ Setup cancelled\033[0m"
        exit 1
    fi
else
    if gh repo create "$REPO_NAME" $PRIVATE_FLAG --source=. --description "Cursor Editor Settings Backup" --push; then
        echo -e "  \033[0;32m✓ GitHub repository created: $REPO_NAME\033[0m"
    else
        echo -e "\033[0;31m❌ Failed to create GitHub repository\033[0m"
        exit 1
    fi
fi

# Configure git remote if not already set
if ! git remote get-url origin &> /dev/null; then
    echo -e "\n\033[0;36m🔗 Configuring git remote...\033[0m"
    username=$(gh api user --jq .login)
    git remote add origin "https://github.com/$username/$REPO_NAME.git"
    echo -e "  \033[0;32m✓ Git remote configured\033[0m"
else
    remoteUrl=$(git remote get-url origin)
    echo -e "\n  \033[0;33mℹ Git remote already configured: $remoteUrl\033[0m"
fi

# Create initial README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo -e "\033[0;33m⚠ Warning: README.md not found. This should not happen!\033[0m"
fi

# Create settings directory
if [ ! -d "settings" ]; then
    mkdir -p settings
    echo -e "  \033[0;32m✓ Created settings directory\033[0m"
fi

# Initial commit if needed
echo -e "\n\033[0;36m📝 Creating initial commit...\033[0m"
git add .
if ! git diff --staged --quiet; then
    git commit -m "Initial commit: Setup Cursor settings sync"
    echo -e "  \033[0;32m✓ Initial commit created\033[0m"
    
    # Push to GitHub
    git branch -M main
    git push -u origin main
    echo -e "  \033[0;32m✓ Pushed to GitHub\033[0m"
else
    echo -e "  \033[0;33mℹ No changes to commit\033[0m"
fi

echo -e "\n\033[0;32m✅ Setup completed successfully!\033[0m"
echo -e "\n\033[0;36m📋 Next steps:\033[0m"
echo -e "  \033[0;37m1. Run backup.sh to backup your current Cursor settings\033[0m"
echo -e "  \033[0;37m2. On a new machine, clone this repo and run restore.sh\033[0m"
echo -e "\n\033[0;36m🔗 Repository URL:\033[0m"
username=$(gh api user --jq .login)
echo -e "   \033[0;37mhttps://github.com/$username/$REPO_NAME\033[0m"

