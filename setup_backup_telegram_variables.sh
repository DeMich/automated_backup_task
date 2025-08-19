#!/bin/bash

# ANSI color codes for display visualization of install progress
GRAY='\033[90m'
BOLD='\033[1m'
RESET='\033[0m'

# Define installation steps
steps=("Intro" "Create folders" "Install packages" "Clone repo" "Telegram notifications" "Write .env" "Secure .env" "Add cron job" "Test backup")

# Function to display progress
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

# Step 0: Intro
show_progress 0
echo "🔧 Welcome to the Automated Backup Task Installer"
echo "--------------------------------------------------"
echo "This script will:"
echo "  - Create a folder in your home directory for necessary scripts, logs & a protected .env file with your own settings"
echo "  - Prompt you to choose which HDDs to use & optionally configure Telegram notifications"
echo "  - Install required packages (git, Python, pip, python-dotenv)"
echo "  - Clone or update the backup script repository"
echo "  - Set up a cron job to run the backup monthly"
echo "  - Optionally test the backup script after setup"
echo ""
read -p "❓ Do you want to proceed with the installation? (y/n): " proceed

if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    echo "❌ Installation aborted by user."
    exit 0
fi

echo "✅ Proceeding with installation..."

# Step 1: Create folders
show_progress 1
mkdir -p "$HOME/automated_backup_task"
echo "📁 Created folder 'automated_backup_task' in your home directory."

BACKUP_LOG_FILE="$HOME/automated_backup_task/backup.log"
ENV_FILE="$HOME/automated_backup_task/.env_backup_telegram_variables"
touch "$BACKUP_LOG_FILE" "$ENV_FILE"
echo "📝 Created log file and .env file."

# Step 2: Install required packages
show_progress 2
if ! command -v git &> /dev/null; then
    echo "🔧 Git not found. Installing git..."
    sudo apt update && sudo apt install -y git
else
    echo "✅ Git is already installed."
fi

if ! python3 -c "import dotenv" &> /dev/null; then
    echo "🔧 python-dotenv not found. Installing pip and python-dotenv..."
    sudo apt install -y python3-pip
    pip3 install python-dotenv
else
    echo "✅ python-dotenv is already installed."
fi

# Step 3: Clone or update repo
show_progress 3
TARGET_DIR="$HOME/automated_backup_task/scripts"
REPO_URL="https://github.com/DeMich/automated"

if [ -d "$TARGET_DIR/.git" ]; then
    echo "🔄 Repository already exists. Pulling latest changes..."
    git -C "$TARGET_DIR" pull
else
    echo "📥 Cloning repository into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi
echo "✅ GitHub repository synced to $TARGET_DIR."

# Step 4: Telegram setup
show_progress 4
echo "📨 Telegram Notification Setup"
echo "You can set up a Telegram Bot to receive automated notifications about your backup tasks."
echo "This is optional and can be skipped."

read -p "Do you want to configure Telegram notifications? (y/n): " CONFIGURE_TELEGRAM

if [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]]; then
    echo "🔧 Please set up a Telegram Bot and obtain your bot token and chat ID."
    read -p 'Enter your BOT_TOKEN: ' BOT_TOKEN
    read -p 'Enter your CHAT_ID: ' CHAT_ID
fi

# Step 5: Drive selection
show_progress 5
echo "🔍 Detecting available drives..."

mapfile -t drives < <(lsblk -o UUID,MOUNTPOINT,SIZE,MODEL | grep -v "^\s*$" | grep -v "UUID")

if [ ${#drives[@]} -eq 0 ]; then
    echo "❌ No mounted drives found. Please check your system."
    exit 1
fi

echo "📦 Available Drives:"
for i in "${!drives[@]}"; do
    echo "  [$i] ${drives[$i]}"
done

read -p "📁 Select the number of the SOURCE drive to back up: " source_index
SOURCE_INFO="${drives[$source_index]}"
BACKUP_SOURCE=$(echo "$SOURCE_INFO" | awk '{print $2}')
BACKUP_UUID=$(echo "$SOURCE_INFO" | awk '{print $1}')

read -p "💾 Select the number of the DESTINATION drive for backup: " dest_index
DEST_INFO="${drives[$dest_index]}"
BACKUP_DESTINATION=$(echo "$DEST_INFO" | awk '{print $2}')
DEST_UUID=$(echo "$DEST_INFO" | awk '{print $1}')

echo "✅ Selected SOURCE: $BACKUP_SOURCE (UUID: $BACKUP_UUID)"
echo "✅ Selected DESTINATION: $BACKUP_DESTINATION (UUID: $DEST_UUID)"

# Step 6: Write .env file
show_progress 6
{
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "BOT_TOKEN=$BOT_TOKEN"
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "CHAT_ID=$CHAT_ID"
    echo "BACKUP_SOURCE=$BACKUP_SOURCE"
    echo "BACKUP_DESTINATION=$BACKUP_DESTINATION"
    echo "BACKUP_UUID=$BACKUP_UUID"
    echo "BACKUP_LOG_FILE=$BACKUP_LOG_FILE"
} > "$ENV_FILE"

# Step 7: Secure .env file
show_progress 7
chmod 600 "$ENV_FILE"
echo "🔒 Environment file secured at $ENV_FILE."

# Step 8: Add cron job
show_progress 8
CRON_JOB="00 5 1 * * /usr/bin/python3 $HOME/automated_backup_task/scripts/backup_script.py"
CRONTAB_CONTENT=$(crontab -l 2>/dev/null)

if echo "$CRONTAB_CONTENT" | grep -Fq "$CRON_JOB"; then
    echo "ℹ️ Cron job already exists. No new entry was added."
    echo "📌 Copy the following line if you want to manually add or inspect it:"
    echo "    $CRON_JOB"
    echo "✏️ To manually edit your cron jobs, run:"
    echo "    crontab -e"
else
    (echo "$CRONTAB_CONTENT"; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added:"
    echo "$CRON_JOB"
    echo "🕔 This cron job runs at 5:00 AM on the 1st day of every month."
fi
