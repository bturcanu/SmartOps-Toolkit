#!/bin/bash

# Script: Batch User Account Creation in Linux
# Author: Bogdan Turcanu
# Description: Creates multiple user accounts with predefined configurations on a Linux system.
# Dependencies: Standard Linux utilities (useradd, chpasswd, usermod)

# Usage: 
# Create a file (user_list.txt) with one username per line for the accounts you want to create.
# Set the USER_LIST variable in the script to the path of this file.
# Modify DEFAULT_PASSWORD to your preferred default password.
# If you want to add users to a specific group, set the GROUP variable; otherwise, leave it empty.

# Running the Script:
# Make sure the script is executable: chmod +x BatchUserAccountCreation.sh
# Run the script as a superuser: sudo ./BatchUserAccountCreation.sh

# Notes: The script does not handle home directory creation or more advanced user configurations, but it can be extended to do so.

# Configuration
USER_LIST="/path/to/user_list.txt" # Path to the file containing new usernames.
DEFAULT_PASSWORD="defaultPassword123" # Default password for all new accounts.
GROUP="users" # Default group to assign new users, leave empty if not required.

# Function to create a new user account
create_user() {
    local username=$1
    local password=$2

    # Creating the user
    echo "Creating user: $username"
    useradd $username

    # Setting the user's password
    echo "$username:$password" | chpasswd

    # Adding user to group if specified
    if [ ! -z "$GROUP" ]; then
        usermod -aG $GROUP $username
    fi

    echo "$username account created successfully."
}

# Main execution
if [ -f "$USER_LIST" ]; then
    while IFS= read -r username; do
        create_user "$username" "$DEFAULT_PASSWORD"
    done < "$USER_LIST"
else
    echo "User list file not found: $USER_LIST"
    exit 1
fi

echo "Batch user account creation completed."
