# automated
Automated rsync backup of HDD. With logs & telegram bot notifications.
#
# Setup of variables
auto_setup_Rsync&telegram_env.py should be used to securely store your Rsync variables & telegram bot details onto your OS environment.
Either by using script or by setting manual:
## Script:
Download "auto_setup_Rsync&telegram_e"
Make script executable by running, in terminal:

	chmod +x auto_import_telegram_env.sh
run script & give bot_token & chat_id of your telegram bot: 

	./auto_import_telegram_env.sh
 
  ## Manual:
  use the following to store you sensitive date securely onto the OS. 
  run in terminal:
		
	nano ~/.env_telegram
  place:
  
	export BOT_TOKEN='your_bot_token_here'
	export CHAT_ID='your_chat_id_here'
  ctrl+o (for save) & ctrl-x (for exit)  &  run (in terminal): 
	
 	source ~/.env_telegram
  run (in terminal): 
		
	chmod 600 ~/.env_telegram

# setup Rsync 
## backup_config_nas.json
source path, destination path, backup file location path & backup HHD UUID needs to be placed correctly inside this json file.
###
backup HDD UUID will be used to send spin down ( AKA power down) command.
###
install hdparm for command
### 
	need guide for instalment

##nas_share_backup_script.py
This script will need to be triggered to automate the task. Preferably by cron:

	crontab -e
 	## 1 1 * * ...
this script will use telegram_bot.py for notifications
