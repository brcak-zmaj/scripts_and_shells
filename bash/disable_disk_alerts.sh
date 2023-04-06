#!/bin/bash

# List of disks for which alerts should be disabled
DISKS=(sdg sdh sdi sdj)

for disk in "${DISKS[@]}"
do
    # Check if alerts are already disabled for this disk
    if grep -q "^\s*disk\(\s*=\|{\)$disk\>" /etc/smartd.conf; then
        echo "Alerts already disabled for disk $disk"
    else
        # Disable alerts for this disk by adding a line to smartd.conf
        echo "DEVICESCAN -d removable -m ignore -M $disk" | tee -a /etc/smartd.conf >/dev/null
        echo "Alerts disabled for disk $disk"
    fi
done

# Restart the smartd service to apply the changes
systemctl restart smartd
