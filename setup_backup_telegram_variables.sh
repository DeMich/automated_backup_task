#!/bin/bash
set -euo pipefail

# === ANSI color codes for progress visualization ===
GRAY='\033[90m'
BOLD='\033[1m'
RESET='\033[0m'

# === Installation steps ===
steps=(
    "Intro"
    "Create folders & setting up log"
    "Install packages"
    "Cloning/updating Git repo"
    "Telegram notifications (optional)"
    "Source & target selection"
    "Write .env & secure .env"
    "Add cron job"
    "Test run backup task (optional)"
)

# === Progress display function ===
show_progress() {
    local current_step=$1
    echo ""
    echo "📋 Installation Progress:"
    for i in "${!steps[@]}"; do
        if (( i < current_step )); then
            echo -e "  ${GRAY}✔ ${steps[$i]}${RESET}"
        elif (( i == current_step )); then
            echo -e "  ${BOLD}➤ ${steps[$i]}${RESET}"
        else
            echo "    ${steps[$i]}"
        fi
    done
    echo ""
}

# === Step 0: Intro ===
show_progress 0
echo "🔧 Welcome to the Automated Backup Task Installer"
echo "--------------------------------------------------"
echo "This script will:"
echo "  - Create a folder in your home directory called 'automated_backup_task' for scripts, logs & settings"
echo "  - Install required packages (git, python3, pip, python-dotenv)"
echo "  - Check if Git repository is missing or out of date → Clone/update the backup script repo"
echo "  - Set up optional Telegram push notifications through a Telegram bot (must be preconfigured)"
echo "  - Set up source & target folders/drives"
echo "  - Write a secured .env file with your settings"
echo "  - Add a cron job to run backups monthly"
echo "  - Optionally run a test backup task"
echo ""
read -p "❓ Do you want to proceed with the installation? (y/n): " proceed
if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    echo "❌ Installation aborted."
    exit 0
fi
echo "✅ Proceeding with installation..."

# === Step 1: Create folders ===
show_progress 1
BACKUP_BASE="$HOME/automated_backup_task"
BACKUP_LOG_FILE="$BACKUP_BASE/backup.log"
ENV_FILE="$BACKUP_BASE/automated_backup_task.env"
REPO_URL="https://github.com/DeMich/automated"
REPO_DIR="$BACKUP_BASE/scripts"
mkdir -p "$REPO_DIR"
exec > >(tee -a "$BACKUP_LOG_FILE") 2>&1
touch "$BACKUP_LOG_FILE" "$ENV_FILE"
echo "📁 Backup folder and files prepared at $BACKUP_BASE."

# === Step 2: Install required packages ===
show_progress 2
if ! command -v python3 &>/dev/null; then
    echo "🔧 Installing Python3..."
    sudo apt update && sudo apt install -y python3
else
    echo "✅ Python3 is already installed."
fi

if ! command -v pip3 &>/dev/null; then
    echo "🔧 Installing pip3 so we can install python-dotenv..."
    sudo apt install -y python3-pip
else
    echo "✅ pip3 is already installed."
fi

if ! python3 -c "import dotenv" &>/dev/null; then
    echo "🔧 Installing python-dotenv so Python can read the .env file where we store the settings..."
    pip3 install --user python-dotenv
else
    echo "✅ python-dotenv is already installed."
fi

if ! command -v git &>/dev/null; then
    echo "🔧 Installing Git... So we can get the necessary files from the repository"
    sudo apt install -y git
else
    echo "✅ Git is already installed."
fi

# === Step 3: Clone or update repo ===
show_progress 3
if [ -d "$REPO_DIR/.git" ]; then
    echo "🔄 Updating existing repository..."
    git -C "$REPO_DIR" pull
else
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
fi
echo "✅ Repository ready at $REPO_DIR."

# === Step 4: Telegram setup ===
show_progress 4
echo "📨 Optional Telegram Bot setup"
read -p "Do you want Telegram notifications? (y/n): " CONFIGURE_TELEGRAM
BOT_TOKEN=""
CHAT_ID=""
if [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]]; then
    echo "🔧 Enter Telegram Bot credentials:"
    read -p "BOT_TOKEN: " BOT_TOKEN
    read -p "CHAT_ID : " CHAT_ID
fi

# === Step 5: Drive selection ===
show_progress 5
echo "🔍 Detecting drives..."
mapfile -t drives < <(lsblk -o UUID,MOUNTPOINT,SIZE,MODEL -P | grep 'MOUNTPOINT=')

if [ ${#drives[@]} -eq 0 ]; then
    echo "❌ No mounted drives found!"
    exit 1
fi

echo "📦 Available Drives:"
for i in "${!drives[@]}"; do
    eval "${drives[$i]}"
    echo "  [$i] UUID=$UUID MOUNTPOINT=$MOUNTPOINT SIZE=$SIZE MODEL=$MODEL"
done

read -p "📁 Select the number of the SOURCE drive: " source_index
eval "${drives[$source_index]}"
BACKUP_SOURCE="$MOUNTPOINT"
BACKUP_UUID="$UUID"

read -p "💾 Select the number of the DESTINATION drive: " dest_index
eval "${drives[$dest_index]}"
BACKUP_DESTINATION="$MOUNTPOINT"
DEST_UUID="$UUID"

if [[ "$BACKUP_SOURCE" == "$BACKUP_DESTINATION" ]]; then
    echo "❌ Source and destination cannot be the same!"
    exit 1
fi

echo "✅ SOURCE: $BACKUP_SOURCE (UUID: $BACKUP_UUID)"
echo "✅ DEST  : $BACKUP_DESTINATION (UUID: $DEST_UUID)"

# === Step 6: Write .env file ===
show_progress 6
{
    [[ -n "$BOT_TOKEN" ]] && echo "BOT_TOKEN=$BOT_TOKEN"
    [[ -n "$CHAT_ID" ]] && echo "CHAT_ID=$CHAT_ID"
    echo "BACKUP_SOURCE=$BACKUP_SOURCE"
    echo "BACKUP_DESTINATION=$BACKUP_DESTINATION"
    echo "BACKUP_UUID=$BACKUP_UUID"
    echo "BACKUP_LOG_FILE=$BACKUP_LOG_FILE"
} > "$ENV_FILE"
echo "📝 Environment settings saved to $ENV_FILE."

# === Step 7: Secure .env ===
show_progress 6
chmod 600 "$ENV_FILE"
echo "🔒 Protected environment file."

# === Step 8: Add cron job ===
show_progress 7
CRON_JOB="0 5 1 * * /usr/bin/python3 $REPO_DIR/backup_script.py"
CRONTAB_CONTENT=$(crontab -l 2>/dev/null || true)

if echo "$CRONTAB_CONTENT" | grep -Fq "$CRON_JOB"; then
    echo "ℹ️ Cron job already exists."
else
    (echo "$CRONTAB_CONTENT"; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added (@ monthly, 5:00 AM, 1st)."
fi
# === Step 9: Optional test backup ===
show_progress 8
read -p "🧪 Run a test backup now? (y/n): " test_backup
if [[ "$test_backup" =~ ^[Yy]$ ]]; then
    python3 "$REPO_DIR/backup_script.py"
    echo "✅ Test backup complete. Logs: $BACKUP_LOG_FILE"
else
    echo "ℹ️ Skipped test backup."
fi

echo "🎉 Installation finished successfully!"
echo "✅ Repository ready at $REPO_DIR."
echo "We will sync $BACKUP_SOURCE to $BACKUP_DESTINATION"
echo "✅ Cron job monthly, 5:00 AM, 1st."
