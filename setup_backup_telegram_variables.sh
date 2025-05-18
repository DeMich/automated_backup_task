
#!/bin/bash

# Get the current username
USERNAME=$(whoami)
# make folder for all backup related stuff, make log file & env file where variables will be stored securely
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


# Step 5: Write environment variables to file
{
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "export BOT_TOKEN='$BOT_TOKEN'"
    [[ "$CONFIGURE_TELEGRAM" =~ ^[Yy]$ ]] && echo "export CHAT_ID='$CHAT_ID'"
    echo "export BACKUP_SOURCE='$BACKUP_SOURCE'"
    echo "export BACKUP_DESTINATION='$BACKUP_DESTINATION'"
    echo "export BACKUP_UUID='$BACKUP_UUID'"
    echo "export BACKUP_LOG_FILE='$BACKUP_LOG_FILE'"
} > "$ENV_FILE"


# Step 5: Secure the environment file
chmod 600 "$ENV_FILE"
source "$ENV_FILE"

echo "✅ Environment variables saved to $ENV_FILE and sourced."

# Step 6: Add cron job
CRON_JOB="00 5 1 * * /usr/bin/python3 /home/$USERNAME/automated_backup_task/backup_script.py"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ Cron job added:"
echo "$CRON_JOB"
echo "🕔 This cron job runs at 5:00 AM on the 1st day of every month."
