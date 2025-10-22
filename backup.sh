#!/bin/bash
# Cursor Settings Backup Script for Linux
# This script backs up Cursor settings to the current directory and pushes to GitHub

COMMIT_MESSAGE="${1:-Update Cursor settings - $(date '+%Y-%m-%d %H:%M:%S')}"

echo -e "\033[0;36m🔄 Starting Cursor Settings Backup...\033[0m"

# Define paths
CURSOR_USER_PATH="$HOME/.config/Cursor/User"
BACKUP_DIR="./settings"

# Check if Cursor settings exist
if [ ! -d "$CURSOR_USER_PATH" ]; then
    echo -e "\033[0;31m❌ Error: Cursor settings not found at $CURSOR_USER_PATH\033[0m"
    echo -e "\033[0;33m   Make sure Cursor is installed and has been run at least once.\033[0m"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo -e "\033[0;32m✅ Created backup directory: $BACKUP_DIR\033[0m"
fi

# Function to copy file if it exists
copy_if_exists() {
    local source="$1"
    local destination="$2"
    if [ -f "$source" ]; then
        cp "$source" "$destination"
        echo -e "  \033[0;32m✓ Copied $(basename "$source")\033[0m"
        return 0
    fi
    return 1
}

# Function to copy directory if it exists
copy_dir_if_exists() {
    local source="$1"
    local destination="$2"
    if [ -d "$source" ]; then
        rm -rf "$destination"
        cp -r "$source" "$destination"
        echo -e "  \033[0;32m✓ Copied $(basename "$source")/ directory\033[0m"
        return 0
    fi
    return 1
}

echo -e "\n\033[0;36m📦 Backing up Cursor settings...\033[0m"

# Backup main settings files
copy_if_exists "$CURSOR_USER_PATH/settings.json" "$BACKUP_DIR/settings.json"
copy_if_exists "$CURSOR_USER_PATH/keybindings.json" "$BACKUP_DIR/keybindings.json"

# Backup snippets
copy_dir_if_exists "$CURSOR_USER_PATH/snippets" "$BACKUP_DIR/snippets"

# Backup extensions list
if [ -f "$HOME/.config/Cursor/User/globalStorage/storage.json" ]; then
    copy_if_exists "$HOME/.config/Cursor/User/globalStorage/storage.json" "$BACKUP_DIR/storage.json"
fi

# Get list of installed extensions
echo -e "\n\033[0;36m📋 Backing up extensions list...\033[0m"
if command -v cursor &> /dev/null; then
    cursor --list-extensions > "$BACKUP_DIR/extensions.txt"
    echo -e "  \033[0;32m✓ Saved extensions list\033[0m"
else
    echo -e "  \033[0;33m⚠ Warning: Could not find Cursor executable to list extensions\033[0m"
fi

# Create metadata file
cat > "$BACKUP_DIR/metadata.json" << EOF
{
  "lastBackup": "$(date -Iseconds)",
  "platform": "Linux",
  "cursorVersion": "unknown"
}
EOF
echo -e "  \033[0;32m✓ Created metadata file\033[0m"

# Git operations
echo -e "\n\033[0;36m📤 Pushing to GitHub...\033[0m"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "\033[0;33m⚠ Git repository not initialized. Run setup.sh first!\033[0m"
    exit 1
fi

# Add all changes
git add settings/

# Check if there are changes to commit
if ! git diff --staged --quiet settings/; then
    git commit -m "$COMMIT_MESSAGE"
    git push
    echo -e "\n\033[0;32m✅ Backup completed and pushed to GitHub!\033[0m"
else
    echo -e "\n\033[0;32m✅ No changes detected. Settings are up to date!\033[0m"
fi

echo -e "\n\033[0;36m📊 Backup Summary:\033[0m"
echo -e "  \033[0;37mSource: $CURSOR_USER_PATH\033[0m"
echo -e "  \033[0;37mBackup: $BACKUP_DIR\033[0m"
echo -e "  \033[0;37mTime: $(date '+%Y-%m-%d %H:%M:%S')\033[0m"

