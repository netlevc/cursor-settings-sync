#!/bin/bash
# Cursor Settings Restore Script for Linux
# This script restores Cursor settings from the backup

FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "\033[0;36m🔄 Starting Cursor Settings Restore...\033[0m"

# Define paths
CURSOR_USER_PATH="$HOME/.config/Cursor/User"
BACKUP_DIR="./settings"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "\033[0;31m❌ Error: Backup directory not found at $BACKUP_DIR\033[0m"
    echo -e "\033[0;33m   Make sure you've run 'git pull' or 'git clone' to get the latest settings.\033[0m"
    exit 1
fi

# Check if Cursor is installed
if [ ! -d "$HOME/.config/Cursor" ]; then
    echo -e "\033[0;31m❌ Error: Cursor does not appear to be installed\033[0m"
    echo -e "\033[0;33m   Please install Cursor first: https://cursor.sh/\033[0m"
    exit 1
fi

# Create User directory if it doesn't exist
if [ ! -d "$CURSOR_USER_PATH" ]; then
    mkdir -p "$CURSOR_USER_PATH"
    echo -e "\033[0;32m✅ Created Cursor User directory\033[0m"
fi

# Warn if Cursor is running
if pgrep -x "cursor" > /dev/null || pgrep -x "Cursor" > /dev/null; then
    echo -e "\033[0;33m⚠ WARNING: Cursor appears to be running!\033[0m"
    echo -e "\033[0;33m   It's recommended to close Cursor before restoring settings.\033[0m"
    if [ "$FORCE" = false ]; then
        read -p "   Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "\033[0;31m❌ Restore cancelled\033[0m"
            exit 1
        fi
    fi
fi

# Function to restore file if it exists in backup
restore_if_exists() {
    local source="$1"
    local destination="$2"
    if [ -f "$source" ]; then
        local dest_dir=$(dirname "$destination")
        if [ ! -d "$dest_dir" ]; then
            mkdir -p "$dest_dir"
        fi
        cp "$source" "$destination"
        echo -e "  \033[0;32m✓ Restored $(basename "$source")\033[0m"
        return 0
    else
        echo -e "  \033[0;90m⊘ Skipped $(basename "$source") (not in backup)\033[0m"
        return 1
    fi
}

# Function to restore directory if it exists in backup
restore_dir_if_exists() {
    local source="$1"
    local destination="$2"
    if [ -d "$source" ]; then
        rm -rf "$destination"
        cp -r "$source" "$destination"
        echo -e "  \033[0;32m✓ Restored $(basename "$source")/ directory\033[0m"
        return 0
    else
        echo -e "  \033[0;90m⊘ Skipped $(basename "$source")/ (not in backup)\033[0m"
        return 1
    fi
}

echo -e "\n\033[0;36m📦 Restoring Cursor settings...\033[0m"

# Restore main settings files
restore_if_exists "$BACKUP_DIR/settings.json" "$CURSOR_USER_PATH/settings.json"
restore_if_exists "$BACKUP_DIR/keybindings.json" "$CURSOR_USER_PATH/keybindings.json"

# Restore snippets
restore_dir_if_exists "$BACKUP_DIR/snippets" "$CURSOR_USER_PATH/snippets"

# Restore storage.json if it exists
if [ -f "$BACKUP_DIR/storage.json" ]; then
    global_storage_path="$HOME/.config/Cursor/User/globalStorage"
    if [ ! -d "$global_storage_path" ]; then
        mkdir -p "$global_storage_path"
    fi
    restore_if_exists "$BACKUP_DIR/storage.json" "$global_storage_path/storage.json"
fi

# Restore extensions
echo -e "\n\033[0;36m📋 Restoring extensions...\033[0m"
if [ -f "$BACKUP_DIR/extensions.txt" ]; then
    if command -v cursor &> /dev/null; then
        extension_count=$(wc -l < "$BACKUP_DIR/extensions.txt")
        echo -e "  \033[0;37mFound $extension_count extensions to install\033[0m"
        
        installed=0
        skipped=0
        while IFS= read -r extension; do
            if [ -n "$extension" ]; then
                echo -e "  \033[0;90mInstalling: $extension\033[0m"
                if cursor --install-extension "$extension" --force &> /dev/null; then
                    ((installed++))
                else
                    ((skipped++))
                    echo -e "    \033[0;33m⚠ Failed to install: $extension\033[0m"
                fi
            fi
        done < "$BACKUP_DIR/extensions.txt"
        echo -e "  \033[0;32m✓ Installed $installed extensions ($skipped skipped/failed)\033[0m"
    else
        echo -e "  \033[0;33m⚠ Warning: Could not find Cursor executable to install extensions\033[0m"
        echo -e "    \033[0;33mYou can install extensions manually from: $BACKUP_DIR/extensions.txt\033[0m"
    fi
else
    echo -e "  \033[0;90m⊘ No extensions list found in backup\033[0m"
fi

# Show restore information
echo -e "\n\033[0;36m📊 Restore Summary:\033[0m"
echo -e "  \033[0;37mSource: $BACKUP_DIR\033[0m"
echo -e "  \033[0;37mDestination: $CURSOR_USER_PATH\033[0m"
echo -e "  \033[0;37mTime: $(date '+%Y-%m-%d %H:%M:%S')\033[0m"

if [ -f "$BACKUP_DIR/metadata.json" ]; then
    echo -e "\n  \033[0;36mBackup info:\033[0m"
    last_backup=$(grep -o '"lastBackup":"[^"]*"' "$BACKUP_DIR/metadata.json" | cut -d'"' -f4)
    platform=$(grep -o '"platform":"[^"]*"' "$BACKUP_DIR/metadata.json" | cut -d'"' -f4)
    echo -e "    \033[0;37mLast backup: $last_backup\033[0m"
    echo -e "    \033[0;37mPlatform: $platform\033[0m"
fi

echo -e "\n\033[0;32m✅ Restore completed successfully!\033[0m"
echo -e "   \033[0;33mPlease restart Cursor to apply all changes.\033[0m"

