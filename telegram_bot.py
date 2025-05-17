## Telegram_bot.py
import os
import requests

# Telegram settings
bot_token = os.environ.get("BOT_TOKEN")
chat_id = os.environ.get("CHAT_ID")
#bot_token&chat_id has been stored on linux mint as sensitive data by using the environment variables

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
