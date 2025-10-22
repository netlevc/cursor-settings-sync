# 🔄 Cursor Settings Sync

Backup and restore your Cursor editor settings to GitHub. Since Cursor doesn't support VSCode Cloud Syncing, this solution provides an easy way to sync your settings across multiple machines.

## ✨ Features

- 🔐 **Secure**: Uses GitHub CLI for authentication
- 🖥️ **Cross-platform**: Works on Windows and Linux
- 📦 **Complete backup**: Settings, keybindings, snippets, and extensions
- ⚡ **Easy to use**: Simple scripts for backup and restore
- 🔄 **Git-based**: Full version control of your settings
- 🚀 **Quick setup**: Automated repository creation and configuration

## 📋 What Gets Backed Up

- ✅ User settings (`settings.json`)
- ✅ Keyboard shortcuts (`keybindings.json`)
- ✅ Code snippets
- ✅ Extensions list
- ✅ UI state preferences (`storage.json`)

## 🚫 What's Excluded

- ❌ Workspace-specific settings
- ❌ Cache and temporary files
- ❌ Log files
- ❌ Machine-specific data

## 📥 Prerequisites

Before you begin, make sure you have:

- **Git** installed ([download](https://git-scm.com/))
- **GitHub CLI (gh)** installed ([download](https://cli.github.com/))
- **Cursor Editor** installed ([download](https://cursor.sh/))

### Verify Installation

**Windows (PowerShell):**
```powershell
git --version
gh --version
```

**Linux (Bash):**
```bash
git --version
gh --version
```

## 🚀 Quick Start

### First Time Setup

#### Windows

1. **Clone or navigate to this repository:**
   ```powershell
   cd path\to\cursor-settings-sync
   ```

2. **Authenticate with GitHub CLI** (if not already done):
   ```powershell
   gh auth login
   ```

3. **Run the setup script:**
   ```powershell
   .\setup.ps1
   ```
   
   This will:
   - Initialize a git repository
   - Create a new GitHub repository
   - Configure git remotes
   - Push initial files

   **Options:**
   - Create a private repository: `.\setup.ps1 -Private`
   - Custom repository name: `.\setup.ps1 -RepoName "my-cursor-settings"`

4. **Backup your current settings:**
   ```powershell
   .\backup.ps1
   ```

#### Linux

1. **Clone or navigate to this repository:**
   ```bash
   cd path/to/cursor-settings-sync
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```

3. **Authenticate with GitHub CLI** (if not already done):
   ```bash
   gh auth login
   ```

4. **Run the setup script:**
   ```bash
   ./setup.sh
   ```
   
   **Options:**
   - Create a private repository: `./setup.sh --private`
   - Custom repository name: `./setup.sh my-cursor-settings`

5. **Backup your current settings:**
   ```bash
   ./backup.sh
   ```

---

### On a New Machine

#### Windows

1. **Install prerequisites** (Git, GitHub CLI, Cursor)

2. **Authenticate with GitHub:**
   ```powershell
   gh auth login
   ```

3. **Clone your settings repository:**
   ```powershell
   gh repo clone YOUR_USERNAME/cursor-settings-sync
   cd cursor-settings-sync
   ```

4. **Restore your settings:**
   ```powershell
   .\restore.ps1
   ```

5. **Restart Cursor** to apply all changes

#### Linux

1. **Install prerequisites** (Git, GitHub CLI, Cursor)

2. **Authenticate with GitHub:**
   ```bash
   gh auth login
   ```

3. **Clone your settings repository:**
   ```bash
   gh repo clone YOUR_USERNAME/cursor-settings-sync
   cd cursor-settings-sync
   ```

4. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```

5. **Restore your settings:**
   ```bash
   ./restore.sh
   ```

6. **Restart Cursor** to apply all changes

---

## 📖 Usage

### Backup Settings

Run whenever you want to save your current settings to GitHub:

**Windows:**
```powershell
.\backup.ps1
```

**Linux:**
```bash
./backup.sh
```

**Custom commit message:**
```powershell
# Windows
.\backup.ps1 -CommitMessage "Added new keybindings"

# Linux
./backup.sh "Added new keybindings"
```

### Restore Settings

Run to restore settings from the repository:

**Windows:**
```powershell
# Regular restore (with confirmation if Cursor is running)
.\restore.ps1

# Force restore without confirmation
.\restore.ps1 -Force
```

**Linux:**
```bash
# Regular restore (with confirmation if Cursor is running)
./restore.sh

# Force restore without confirmation
./restore.sh --force
```

### Update Settings on Another Machine

If you've already set up on another machine and just want to pull the latest settings:

```bash
git pull
```

Then run the restore script.

---

## 📁 Directory Structure

```
cursor-settings-sync/
├── .gitignore              # Excludes sensitive data
├── README.md               # This file
├── setup.ps1               # Windows setup script
├── setup.sh                # Linux setup script
├── backup.ps1              # Windows backup script
├── backup.sh               # Linux backup script
├── restore.ps1             # Windows restore script
├── restore.sh              # Linux restore script
└── settings/               # Backed up settings (created after first backup)
    ├── settings.json       # User settings
    ├── keybindings.json    # Keyboard shortcuts
    ├── snippets/           # Code snippets
    ├── extensions.txt      # List of installed extensions
    ├── storage.json        # UI state
    └── metadata.json       # Backup metadata
```

---

## 🔧 Cursor Settings Locations

### Windows
```
%APPDATA%\Cursor\User\
```
Typical path: `C:\Users\YourUsername\AppData\Roaming\Cursor\User\`

### Linux
```
~/.config/Cursor/User/
```

---

## 🤔 Troubleshooting

### "GitHub CLI not authenticated"
Run `gh auth login` and follow the prompts.

### "Cursor settings not found"
Make sure Cursor is installed and you've run it at least once. This creates the settings directory.

### "Git repository not initialized"
Run the setup script first (`setup.ps1` or `setup.sh`).

### Extensions not installing
- Make sure Cursor is closed when running restore
- Check that the Cursor executable is in your PATH
- Try installing extensions manually from `settings/extensions.txt`

### Permission denied on Linux
Make scripts executable:
```bash
chmod +x *.sh
```

### Settings not applying after restore
- Restart Cursor completely (close all windows)
- If still not working, check if Cursor was running during restore

---

## 🔄 Regular Workflow

1. **Make changes** to your Cursor settings, keybindings, or extensions
2. **Run backup** script to save to GitHub
3. **On another machine**, pull the latest changes and run restore

**Recommended**: Run backup after making significant changes to your editor configuration.

---

## 🛡️ Security & Privacy

- ✅ Sensitive files are excluded via `.gitignore`
- ✅ GitHub CLI handles authentication securely
- ✅ No hardcoded credentials
- ⚠️ Consider using a **private repository** if your settings contain sensitive information
- ⚠️ Review `settings.json` before first backup to ensure no sensitive data

---

## 🤝 Contributing

Feel free to submit issues or pull requests if you find bugs or have suggestions for improvements!

---

## 📝 License

This is a personal tool. Use and modify as you see fit.

---

## 💡 Tips

- **Automate backups**: Set up a scheduled task (Windows) or cron job (Linux) to run backup regularly
- **Multiple machines**: Keep settings in sync by running backup on one machine and restore on others
- **Version control**: Use git history to revert to previous settings configurations
- **Extensions**: The backup includes a list of extensions, but you'll need internet to install them during restore

---

## 🙏 Acknowledgments

Created out of necessity since Cursor doesn't support VSCode Cloud Syncing. Inspired by similar solutions in the developer community.

---

**Happy Coding! 🚀**

