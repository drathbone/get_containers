#!/bin/bash

# This script will loop through all nodes within the stack and list all docker containers that are running

# Get input: environment, stack name and sudo password
read -p "Environment? " whcenv
read -p "Stack name? " stack
read -s -p "Sudo password: " sudopassword
echo

# Check stack exists
echo "Generating list of nodes..."
host_array=( $( cx stack status -c $whcenv -t $stack | grep ${whcenv}x${stack} | grep running | awk -F" " '{print $2}') )

# Check that host_array is not empty here
if [ -d ./${whcenv}x${stack} ]; then
	echo "Archiving ${whcenv}x${stack} to ${whcenv}x${stack}.`date +%d%m%y%H%M`"
	mv ./${whcenv}x${stack} ./${whcenv}x${stack}.`date +%d%m%y%H%M`
fi
echo "Creating ./${whcenv}x${stack} for output files"
mkdir ./${whcenv}x${stack}

# Loop through the array, connecting to the server, and outputting the docker containers running
for i in "${host_array[@]}"; do
    ssh -t -q -o "StrictHostKeyChecking no" $i "echo $sudopassword | sudo -S docker ps | awk -F\" \" '{print \$2}'" >./${whcenv}x${stack}/$i.`date +%m%y%d`.out 
done

echo "Finished. List of all running containers:"
for i in "${host_array[@]}"; do
    cat ./${whcenv}x${stack}/$i.`date +%m%y%d`.out | grep nexus
done 



