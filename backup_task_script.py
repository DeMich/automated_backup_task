import os
import sys
import subprocess
from datetime import datetime
# Add the script directory to the Python path
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)
from telegram_bot import send_message
import time
import json
from dotenv import load_dotenv

# Load backup configuration from environment variables
load_dotenv(os.path.expanduser('~/automated_backup_task/automated_backup_task.env'))
source = os.environ.get("BACKUP_SOURCE")
if source and not source.endswith('/'):
    source += '/'
destination = os.environ.get("BACKUP_DESTINATION")
uuid = os.environ.get("BACKUP_UUID")
log_file = os.environ.get("BACKUP_LOG_FILE")

# Rsync command
rsync_command = ['rsync', '-a', '--exclude=lost+found/', '--stats', '--human-readable', source, destination]
process = subprocess.run(rsync_command, capture_output=True, text=True)

# Prepare log message
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
summary_content = process.stdout + process.stderr

# Try to put the disk to sleep and capture the result
try:
    device = subprocess.check_output(['blkid', '-U', uuid], text=True).strip()
    subprocess.run(['sudo', 'hdparm', '-y', device], check=True)
    disk_sleep_status = f"✅ Disk {device} put to sleep successfully."
except subprocess.CalledProcessError as e:
    disk_sleep_status = f"⚠️ Failed to resolve UUID or put disk to sleep: {e}"
except Exception as e:
    disk_sleep_status = f"❌ Unexpected error while handling disk sleep: {e}"

if process.returncode:
    status = "FAILURE"
    message = (
        f"[{timestamp}] BACKUP STATUS: {status}\n"
        f"Source: {source}\n"
        f"Destination: {destination}\n"
        f"Error Code: {process.returncode}\n"
        f"Details:\n{summary_content}\n"
        f"Backup HDD send in sleep mode: {disk_sleep_status}\n\n"
    )
else:
    status = "SUCCESS"
    message = (
        f"[{timestamp}] BACKUP STATUS: {status}\n"
        f"Source: {source}\n"
        f"Destination: {destination}\n"
        f"Details:\n{summary_content}\n"
        f"Backup HDD send in sleep mode: {disk_sleep_status}\n\n"
    )

# Send message to Telegram if credentials are available
if os.environ.get("BOT_TOKEN") and os.environ.get("CHAT_ID"):
    telegram_response = send_message(message)
else:
    telegram_response = "Telegram not configured."

# Write to log file
with open(log_file, 'a') as log:
    log.write(message + "\n")
    log.write(f"Telegram Response: {telegram_response}\n\n")




