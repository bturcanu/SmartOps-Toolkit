#!/bin/bash

# Script: Automated Backup and Restore for MySQL
# Author: Bogdan Turcanu
# Description: This script automates the backup and restoration of MySQL databases.
# It compresses backups, maintains logs, and allows easy restoration.

# The script contains a backup function (backup_database) and a restore function (restore_database). 
# These are two separate functionalities encapsulated within the same script.

# The backup function takes care of creating a compressed backup of the specified MySQL database. 
# It generates a gzip-compressed file of the database dump and saves it to the specified backup path.
# This function also logs the outcome of the backup operation.

# The restore function, on the other hand, is used to restore a database from a previously created backup file.
# It takes a backup file as an input, decompresses it, and restores the database contents. 
# Like the backup function, it logs the results of the restore operation.

# The script uses a case statement at the end to determine which action to perform based on the user's input. 
# When you run the script, you specify either "backup" or "restore" as a command-line argument.
# If you choose restore, you also need to provide the path to the backup file you want to use.

# Notes: Replace placeholder paths and MySQL credentials with actual values. 
# Consider integrating the script with a cron job for scheduled backups.
# For security, consider using a .my.cnf file for MySQL credentials instead of embedding them in the script.

# Configuration
BACKUP_PATH="/path/to/backup/directory"
LOG_PATH="/path/to/log/directory"
MYSQL_USER="your_mysql_username"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_HOST="localhost"
DATABASE_NAME="your_database_name"  # Set to "--all-databases" to backup all databases

# Timestamp (used for backup file naming)
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Backup Function
backup_database() {
    echo "Starting backup of database ${DATABASE_NAME}..."
    mysqldump --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${DATABASE_NAME} | gzip > "${BACKUP_PATH}/backup_${DATABASE_NAME}_${TIMESTAMP}.sql.gz"

    if [ $? -eq 0 ]; then
        echo "Backup completed successfully at ${BACKUP_PATH}/backup_${DATABASE_NAME}_${TIMESTAMP}.sql.gz"
        echo "$(date): Backup successful for ${DATABASE_NAME}" >> "${LOG_PATH}/backup_log_${TIMESTAMP}.log"
    else
        echo "Error during backup process."
        echo "$(date): Backup failed for ${DATABASE_NAME}" >> "${LOG_PATH}/backup_log_${TIMESTAMP}.log"
    fi
}

# Restore Function
restore_database() {
    local backup_file=$1
    if [ -f "${backup_file}" ]; then
        echo "Starting restore from ${backup_file}..."
        gunzip < "${backup_file}" | mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${DATABASE_NAME}

        if [ $? -eq 0 ]; then
            echo "Restore completed successfully."
            echo "$(date): Restore successful from ${backup_file}" >> "${LOG_PATH}/restore_log_${TIMESTAMP}.log"
        else
            echo "Error during restore process."
            echo "$(date): Restore failed from ${backup_file}" >> "${LOG_PATH}/restore_log_${TIMESTAMP}.log"
        fi
    else
        echo "Backup file ${backup_file} does not exist."
    fi
}

# Main Execution
case "$1" in
    backup)
        backup_database
        ;;
    restore)
        if [ -z "$2" ]; then
            echo "Please provide the backup file to restore."
        else
            restore_database "$2"
        fi
        ;;
    *)
        echo "Usage: $0 {backup|restore} [backup_file_for_restore]"
        exit 1
        ;;
esac
