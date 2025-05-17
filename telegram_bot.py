### Telegram_bot.py
import os
import requests

## Telegram settings

bot_token = os.environ.get("BOT_TOKEN")
chat_id = os.environ.get("CHAT_ID")
# bot_token&chat_id has been stored on linux mint as sensitive data by using the environment variables
# If auto setup for configuration of variables wasn't used. Manually is also possible:
# use the following to store you sensitive date securely onto the OS. 
  # run in terminal: "nano ~/.env_backup_automated"
  # place:
    # export BOT_TOKEN='your_bot_token_here'
    # export CHAT_ID='your_chat_id_here'
    # export BACKUP_SOURCE='$BACKUP_SOURCE'
    # export BACKUP_DESTINATION='$BACKUP_DESTINATION'
    # export BACKUP_UUID='$BACKUP_UUID'
    # export BACKUP_LOG_FILE='$BACKUP_LOG_FILE'
  # ctrl+o (for save) & ctrl-x (for exit)
  # run (in terminal): "source ~/.env_backup_automated"
  # run (in terminal): "chmod 600 ~/.env_backup_automated


def send_message(msg):
    url = f'https://api.telegram.org/bot{bot_token}/sendMessage'
    params = {'chat_id': chat_id, 'text': msg}

    # Make the GET request and capture the response
    response = requests.get(url, params=params)
    
    # Check if the request was successful
    if response.status_code != 200:
        return f"Failed to send message, API response code: {response.text}"
    else:
        return f"Succesful sending message, API response code: {response.text}" 
