# Automated Backup Task with optional Telegram Notifications

## Project Overview
This project sets up an automated backup task using bash and Python scripts. It includes optional Telegram notifications to keep you informed about the backup status.

## Features
- Automated backup using rsync
- Telegram notifications for backup status
- Secure storage of environment variables
- Cron job setup for periodic backups

## Before You Begin

Make sure you have the following information ready:

- **HDD mount point** – the source directory you want to back up (e.g., `/mnt/data`)
- **HDD backup mount point** – the destination directory where backups will be stored (e.g., `/mnt/backup`)
- **HDD backup UUID** – the UUID of the backup drive (you can find it using `blkid`)

If you want Telegram automated messages. Also have the following information ready:
- **Telegram bot token**
- **telegram chat id**

## Installation
 Run the setup script:
 - with terminal, go to the folder, where "setup_backup_telegram_variables.sh" is located
 - make it executable: `chmod +x setup_backup_telegram_variables.sh`
 - run the script: `./bash setup_backup_telegram_variables.sh`

  The installer will create a new folder called `automated_backup_task` in your home directory to store all related scripts, logs, and configuration files.

## Configuration
During the setup, you will be prompted to enter the following information:
- Telegram BOT_TOKEN (optional)
- Telegram CHAT_ID (optional)
- Backup SOURCE path
- Backup DESTINATION path
- Backup UUID

These values will be stored securely in an `.env_backup_telegram_variables` file.

## Usage
Once configured, the backup script will run automatically according to the cron job setup.  
You can also run the backup script manually:

```bash
python3 /home/$USERNAME/automated_backup_task/backup_script.py
```

## Cron Job Setup
The setup script adds a cron job to run the backup script at 5:00 AM on the 1st day of every month.  
To verify the cron job, run:

```bash
crontab -l
```

## Security Notes
The environment file containing sensitive information is secured with `chmod 600`.  
Make sure to keep this file safe and do not share it.

## License
This project is licensed under the MIT License.
