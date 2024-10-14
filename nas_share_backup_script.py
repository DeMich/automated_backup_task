## nas_share_backup_script.py

import subprocess
from datetime import datetime
from telegram_bot import send_message

#settings
source = '//share/'
destination = '//share_backup/'
log_file = '/home/demich/backup/share_backup.log'
summary_file = '/tmp/rsync-summary'

#rsync command
rsync_command = ['rsync', '-a', '--stats', '--human-readable', source, destination]
process = subprocess.run(rsync_command, capture_output=True, text=True)

#summary_content preparation
summary_content = process.stdout + process.stderr

#Error check and send message with telegram bot
if process.returncode:
#if statement boolean, everything true then...
  telegram_response = send_message(f"FAILED auto-backup NAS '/share/'-->'/share_backup/': \n errorcode: {process.returncode} \n{summary_content}")
else:
  telegram_response = send_message(f"SUCCESFUL auto-backup NAS '/share/'-->'/share_backup/': \n {summary_content}")

#log summary
with open(log_file, 'a') as log:
  log.write(f"Backup on: {datetime.now()}\n")
  log.write(f"telegram_response: {telegram_response}\n")
  log.write(summary_content + "\n")

