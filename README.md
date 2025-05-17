# automated
Automated rsync backup of HDD. With logs & telegram bot notifications.
#
# Telegram bot setup
Bot_token & chat_id needs to be securely stored in the OS. 
Either by using script or by setting manual
## Script:
Download "auto_import_telegram_env.sh"
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

#
