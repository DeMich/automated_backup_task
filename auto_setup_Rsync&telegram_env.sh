#!/bin/bash

# Prompt user for Telegram credentials
read -p 'Enter your BOT_TOKEN: ' BOT_TOKEN
read -p 'Enter your CHAT_ID: ' CHAT_ID

# Prompt user for backup configuration
read -p 'Enter your backup SOURCE path (e.g., //share/): ' BACKUP_SOURCE
read -p 'Enter your backup DESTINATION path (e.g., //share_backup/): ' BACKUP_DESTINATION
read -p 'Enter your backup UUID (e.g., 3D44E146065881FD): ' BACKUP_UUID
read -p 'Enter your LOG FILE path (e.g., /home/youruser/backup/share_backup.log): ' BACKUP_LOG_FILE

# Create the ~/.env_telegram file and write all environment variables
cat <<EOF > ~/.env_backup_telegram
export BOT_TOKEN='$BOT_TOKEN'
export CHAT_ID='$CHAT_ID'
export BACKUP_SOURCE='$BACKUP_SOURCE'
export BACKUP_DESTINATION='$BACKUP_DESTINATION'
export BACKUP_UUID='$BACKUP_UUID'
export BACKUP_LOG_FILE='$BACKUP_LOG_FILE'
EOF

# Set secure permissions for the file
chmod 600 ~/.env_backup_telegram

# Ensure ~/.bashrc sources the env file
if ! grep -q "source ~/.env_backup_telegram" ~/.bashrc; then
    echo "source ~/.env_backup_telegram" >> ~/.bashrc
fi

# Apply the changes immediately
source ~/.env_backup_telegram

echo "✅ Environment variables for Telegram and backup configuration have been set up and sourced from ~/.env_backup_telegram."
