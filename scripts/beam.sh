#!/bin/bash

# Load the environment variables
set -a
source .env
set +a

# Get the current path
current_path=$(pwd)

# Change to the git repo directory
cd $REPO_PATH

# Double check if we are in the correct directory
if [ "$current_path" != "$REPO_PATH" ]; then
  echo "This script must be run from $REPO_PATH"
  exit 1
fi

# Create a tarball of the git repository
tar -czvf repo.tar.gz .

# Copy the tarball to the remote server
scp repo.tar.gz $SERVER_USERNAME@$SERVER_ADDRESS:/tmp

# SSH into the remote server, untar the file, replace the content of /var/www/html, and restart the service
ssh $SERVER_USERNAME@$SERVER_ADDRESS << 'ENDSSH'
  # Untar the files into a temporary directory
  mkdir -p /tmp/repo
  tar -xzvf /tmp/repo.tar.gz -C /tmp/repo
  
  # Backup the current html dir (optional but recommended)
  mv /var/www/html /var/www/html.bak
  
  # Move the new files into /var/www/html
  mv /tmp/repo /var/www/html
  
  # Restart the blog service
  systemctl restart blog.service
ENDSSH

# Remove the local tarball
rm repo.tar.gz
