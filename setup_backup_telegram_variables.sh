
#!/bin/bash

# Get the current username
USERNAME=$(whoami)

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
ENV_FILE="/home/$USERNAME/automated_backup_task/.env_backup_telegram_variables"

read -p 'Enter your BOT_TOKEN: ' BOT_TOKEN
read -p 'Enter your CHAT_ID: ' CHAT_ID
read -p 'Enter your backup SOURCE path (e.g., //share/): ' BACKUP_SOURCE
read -p 'Enter your backup DESTINATION path (e.g., //share_backup/): ' BACKUP_DESTINATION
read -p 'Enter your backup UUID (e.g., 3D44E146065881FD): ' BACKUP_UUID
read -p 'Enter your LOG FILE path (e.g., /home/youruser/backup/share_backup.log): ' BACKUP_LOG_FILE
# Step 4: Write environment variables to file
mkdir -p "/home/$USERNAME/automated_backup_task"
cat <<EOF > "$ENV_FILE"
export BOT_TOKEN='$BOT_TOKEN'
export CHAT_ID='$CHAT_ID'
export BACKUP_SOURCE='$BACKUP_SOURCE'
export BACKUP_DESTINATION='$BACKUP_DESTINATION'
export BACKUP_UUID='$BACKUP_UUID'
export BACKUP_LOG_FILE='$BACKUP_LOG_FILE'
EOF

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
