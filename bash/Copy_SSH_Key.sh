#!/bin/bash

# Set the path to the public key to be copied
PUBLIC_KEY=~/.ssh/id_rsa.pub

# Set the path to the host file containing the list of servers
HOST_FILE=/path/to/host/file

# Set the username for logging in to the servers
USERNAME=username

# Loop through the servers listed in the host file
while read server; do
    # Copy the public key to the server's authorized_keys file
    ssh-copy-id -i $PUBLIC_KEY $USERNAME@$server

    # Output a message indicating that the key has been copied
    echo "Public key copied to $server"
done < $HOST_FILE
