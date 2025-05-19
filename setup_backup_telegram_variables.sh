#!/bin/bash

# Get the current username
USERNAME=$(whoami)
# Make folder for all backup related stuff, make log file & env file where variables will be stored securely
mkdir -p "/home/$USERNAME/automated_backup_task"
BACKUP_LOG_FILE="/home/$USERNAME/automated_backup_task/backup.log"
ENV_FILE="/home/$USERNAME/automated_backup_task/.env_backup_telegram_variables"

# Step 1: Install git if not already installed
if ! command -v git &> /dev/null; then
    echo "🔧 Git not found. Installing git..."
    sudo apt update && sudo apt install -y git
else
    echo "✅ Git is already installed."
fi

# Step 1b: Install python-dotenv (and pip if needed)
if ! python3 -c "import dotenv" &> /dev/null; then
    echo "🔧 python-dotenv not found. Installing python3-pip and python-dotenv..."
    sudo apt update
    sudo apt install python3-dotenv
else
    echo "✅ python-dotenv is already installed."
fi

# Step 2: Clone or sync the GitHub repository
TARGET_DIR="/home/$USERNAME/automated_backup_task/scripts"
REPO_URL="https://github.com/DeMich/automated"

if [ -d "$TARGET_DIR/.git" ]; then
    echo "🔄 Repository already exists. Pulling latest changes..."
    git -C "$TARGET_DIR" pull
else
    echo "📥 Cloning repository into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi
echo "✅ GitHub repository synced to $TARGET_DIR."

# Step 3: Prompt user for Telegram and backup configuration
read -p "Do you want to configure Telegram notifications? (y/n): " CONFIGURE_TELEGRAM

if [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]]; then
    read -p 'Enter your BOT_TOKEN: ' BOT_TOKEN
    read -p 'Enter your CHAT_ID: ' CHAT_ID
fi
read -p 'Enter your backup SOURCE path (e.g., //share/): ' BACKUP_SOURCE
read -p 'Enter your backup DESTINATION path (e.g., //share_backup/): ' BACKUP_DESTINATION
read -p 'Enter your backup UUID (e.g., 3D44E146065881FD): ' BACKUP_UUID

# Step 5: Write environment variables to Python-compatible .env file (no export, no quotes)
{
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "BOT_TOKEN=$BOT_TOKEN"
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "CHAT_ID=$CHAT_ID"
    echo "BACKUP_SOURCE=$BACKUP_SOURCE"
    echo "BACKUP_DESTINATION=$BACKUP_DESTINATION"
    echo "BACKUP_UUID=$BACKUP_UUID"
    echo "BACKUP_LOG_FILE=$BACKUP_LOG_FILE"
} > "$ENV_FILE"

# Step 6: Secure the environment file
chmod 600 "$ENV_FILE"

echo "✅ Python-compatible environment variables saved to $ENV_FILE."

# Step 7: Add cron job if not already present
CRON_JOB="00 5 1 * * /usr/bin/python3 /home/$USERNAME/automated_backup_task/backup_script.py"
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
