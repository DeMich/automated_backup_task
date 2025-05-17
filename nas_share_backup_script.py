import subprocess
from datetime import datetime
from telegram_bot import send_message
import time
import json

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
  # run (in terminal): "chmod 600 ~/.env_backup_automated"


# Load backup configuration from environment variables
source = os.environ.get("BACKUP_SOURCE")
destination = os.environ.get("BACKUP_DESTINATION")
uuid = os.environ.get("BACKUP_UUID")
log_file = os.environ.get("BACKUP_LOG_FILE")


# Rsync command
rsync_command = ['rsync', '-a', '--stats', '--human-readable', source, destination]
process = subprocess.run(rsync_command, capture_output=True, text=True)

# Prepare log message
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
summary_content = process.stdout + process.stderr

if process.returncode:
    status = "FAILURE"
    message = (
        f"[{timestamp}] BACKUP STATUS: {status}\n"
        f"Source: {source}\n"
        f"Destination: {destination}\n"
        f"Error Code: {process.returncode}\n"
        f"Details:\n{summary_content}"
    )
else:
    status = "SUCCESS"
    message = (
        f"[{timestamp}] BACKUP STATUS: {status}\n"
        f"Source: {source}\n"
        f"Destination: {destination}\n"
        f"Details:\n{summary_content}"
    )

# Send message to Telegram and log the response
telegram_response = send_message(message)

# Write to log file
with open(log_file, 'a') as log:
    log.write(message + "\n")
    log.write(f"Telegram Response: {telegram_response}\n\n")

# Wait to ensure all writes are finished
time.sleep(10)

# Get /dev/sdX from UUID and put disk to sleep
device = subprocess.check_output(['blkid', '-U', uuid], text=True).strip()
subprocess.run(['sudo', 'hdparm', '-y', device])
