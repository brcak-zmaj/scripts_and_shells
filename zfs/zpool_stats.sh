#!/bin/bash

# Get the list of ZFS pools
ZPOOLS=$(zpool list -H -o name)

# Loop through each pool and get its status
for POOL in $ZPOOLS
do
    echo "------------------------------"
    echo "Pool Name: $POOL"
    echo "------------------------------"
    zpool status $POOL
    echo "------------------------------"
    echo "Disk Health: "
    zpool status -v $POOL | grep "state\|status\|errors\|frag\|capacity\|  scan\|scan: "
    echo "------------------------------"
done

# Send an email report
echo "ZFS Pool Status Report" | mail -s "ZFS Pool Status Report" your-email@example.com
