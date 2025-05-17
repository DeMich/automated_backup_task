# automated
Automated rsync backup of HDD. With logs & telegram bot notifications.
#
# Setup of variables
"setup_backup_telegram_variables.sh" should be used to securely store your Rsync variables & telegram bot details onto your OS environment. first do some installations on your OS through terminal:

  	install through terminal:
  	sudo apt update (first look if your OS is fully updated)
   	sudo apt upgrade ( implement these updates)
  	hdparm (this will be used to send the power down command to the backup HDD, after sync)
	sudo apt install python3 (scripts are in python language)
  Later on when running the setup script, you will need to give the following variabels when during the script:

 	source path (HDD you want to backup)
 	destination path (HDD that will be your backup)
	log file path
	backup HDD UUID (use blkid to look this up, when drive is mounted)
	telegram bot_token
 	telegram chat_id
Either by using script or by setting manual:
## Script:
Download "setup_backup_telegram_variables.sh"
Make script executable by running, in terminal:

	chmod +x setup_backup_telegram_variables.sh
run the script: 

	./setup_backup_telegram_variables.sh
 
  ## Manual:
  use the following to store you sensitive date securely onto the OS. 
  run in terminal:
		
	nano ~/.env_backup_telegram
  place:
  	
   	export BOT_TOKEN='your_bot_token_here'
	export CHAT_ID='your_chat_id_here'
    	export BACKUP_SOURCE='$BACKUP_SOURCE'
    	export BACKUP_DESTINATION='$BACKUP_DESTINATION'
    	export BACKUP_UUID='$BACKUP_UUID'
    	export BACKUP_LOG_FILE='$BACKUP_LOG_FILE'
  ctrl+o (for save) & ctrl-x (for exit)  &  run (in terminal): 
	
 	source ~/.env_backup_telegram
  make file only accesable to you by command (in terminal): 
		
	chmod 600 ~/.env_backup_telegram

#automate monthly backup
##nas_share_backup_script.py
download this script. Place it in /home/"your username"/scripts/ & don't change the name
This script will need to be triggered to automate the task. Preferably by cron:

	crontab -e
 this will open cron
 
 	00 5 1 * * /usr/bin/python3 /home/username/scripts/nas_share_backup_script.py

at the bottom, paste this rule. 00=minutes, 5=5AM, 1=first day of the month, *=every month, *=every day of the week
