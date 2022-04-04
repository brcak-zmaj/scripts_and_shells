#!/bin/bash

file=${1:-"/home/almir/nmapd_hosts"}
ncat_port=22
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'  # no color
bold=$(tput bold)
clear=$(tput sgr0)
sshkey=/home/almir/.ssh/pi
user=pi
REQUIRED_PKG="ncat"

## Checking if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

## check if netcat is installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
  echo Checking for $REQUIRED_PKG: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    sudo apt-get --yes install $REQUIRED_PKG
fi


while read -r line
do
    if [[ -n $line ]] && [[ "${line}" != \#* ]]
    then
        ip=$(echo $line | awk '{print $1}')
        hostname=$(echo $line | awk '{print $2}')

        ## if ipv4
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "--------------------------------------"

            ## check netcat connectivity
            if (nc -z -w 2 $ip $ncat_port 2>&1 >/dev/null)
            then
                ncat_status="nc OK"
            else
                echo "${hostname} (${ip}): ${bold}nc ERROR${clear}"
                continue
            fi


            ## attempt ssh connection
            ssh -o ConnectTimeout=3 \
            -o "StrictHostKeyChecking no" \
            -o BatchMode=yes \
            -i $sshkey \
            -q $user@"${ip}" exit </dev/null

            if [ $? -eq 0 ]
            then
                ssh_status="ssh OK"

            else
                ssh_status="${bold}ssh ERROR${clear}"
            fi

            echo "${hostname} (${ip}): ${ncat_status} | ${ssh_status}"
        fi
    fi

done < "${file}"
