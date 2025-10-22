# 🔄 Cursor Settings Sync

Backup and restore Cursor editor settings via GitHub (since Cursor doesn't support VSCode Cloud Sync).

## What Gets Backed Up

- User settings (`settings.json`)
- Keyboard shortcuts (`keybindings.json`)
- Code snippets
- Extensions list
- UI state (`storage.json`)

## Usage

### Backup Settings (Current Machine)

**Windows:**
```powershell
.\backup.ps1
```

**Linux:**
```bash
chmod +x *.sh  # First time only
./backup.sh
```

### Restore Settings (New Machine)

**Windows:**
```powershell
git clone https://github.com/YOUR_USERNAME/cursor-settings-sync
cd cursor-settings-sync
.\restore.ps1
```

**Linux:**
```bash
git clone https://github.com/YOUR_USERNAME/cursor-settings-sync
cd cursor-settings-sync
chmod +x *.sh
./restore.sh
```

Restart Cursor after restore.

## Options

**Custom commit message:**
```powershell
# Windows
.\backup.ps1 -CommitMessage "Added new keybindings"

# Linux
./backup.sh "Added new keybindings"
```

**Force restore (skip Cursor running check):**
```powershell
# Windows
.\restore.ps1 -Force

# Linux
./restore.sh --force
```

## Settings Locations

- **Windows:** `%APPDATA%\Cursor\User\`
- **Linux:** `~/.config/Cursor/User/`

## Troubleshooting

**Extensions not installing?**  
Check that `cursor` command is in your PATH, or install manually from `settings/extensions.txt`

**Settings not applying?**  
Close all Cursor windows and restart.
