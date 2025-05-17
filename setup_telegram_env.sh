#!/bin/bash

# Prompt user for BOT_TOKEN and CHAT_ID
read -p 'Enter your BOT_TOKEN: ' BOT_TOKEN
read -p 'Enter your CHAT_ID: ' CHAT_ID

# Create the ~/.env_telegram file and write the environment variables
echo "export BOT_TOKEN='$BOT_TOKEN'" > ~/.env_telegram
echo "export CHAT_ID='$CHAT_ID'" >> ~/.env_telegram

# Set secure permissions for the file
chmod 600 ~/.env_telegram

# Check if ~/.bashrc already sources ~/.env_telegram
if ! grep -q "source ~/.env_telegram" ~/.bashrc; then
    # Add sourcing command to ~/.bashrc
    echo "source ~/.env_telegram" >> ~/.bashrc
fi

# Apply the changes immediately
source ~/.bashrc

echo "Environment variables BOT_TOKEN and CHAT_ID have been set up and sourced from ~/.env_telegram."
