#!/bin/bash

# Quick setup script for new server.

# Variables
scripts=/home/sysadmin/scripts
bashrc=/home/sysadmin/.bashrc
# Make sure the script is run as root.
if [ ! $UID -ne 0 ]
then
echo "Please run this script with sudo."
  exit
fi

# Check for an output file
if [! $1 ]
then 
    echo "Please specify an output file."
    exit
fi

# Create a log file that our script will use to track its progress
log_file=/var/log/setup_script.log

# Log file header
echo "Log file for general server setup script." >> $1
echo "############################" >> $1
echo "Log generated on: $(date)" >> $1
echo "###########################" >> $1
echo "" >> $1

# List of necessary packages
packages=(
  'nano'
  'wget'
  'net-tools'
  'python'
  'tripwire'
  'tree'
  'curl'
)

#Ensure all packages are installed
for package in ${packages[@]}
do
  if ] ! $(which $package) ]
  then
    apt install -y $packag
  fi
done

#Print it out and log it
echo "$(date) Installed needed packages: ${packages[@]}" | tee -a $1

#Create the user sysadmin with no passwork (password to be created upon login)
useradd sysadmin
chage -d 0 sysadmin

# Add the sysadmin user to the 'sudo' group
usermod -aG sudo sysadmin

# Print and log
echo "$(date) Created sys_admin user. Password to be created upon login:" | tee -a $1

# Remove roots login shell and lock the root account.
usermod -s /sbin/nologin root
usermod -L root

# Print and log
echo "$(date) Disabled root shell.  Root user cannot login." | tee -a $1

# Change permissions on sensitive files
chmod 600 /etc/shadow
chmod 600  /etc/gshadow
chmod 644 /etc/group
chmod 644 /etc/passwd

# Print and log
echo "$(date) Changed permissions on sensitive /etc files." | tee -a $1

# Setup scripts folder
if [ ! -d $scripts ]
then
mkdir $scripts
chown sysadmin:sysadmin $scripts
fi
# Add scripts folder to /bashrc for ryan
echo "" >> $bashrc
echo "PATH=$PATH:/home/sysadmin/scripts" >> $bashrc
echo "" >> $bashrc

# Print and log
echo "$(date) Added ~/scripts directory to sysadmin's PATH." | tee -a $1

# Add custom aliases to /home/sysadmin/.bashrc
echo "#Custom Aliases" >> $bashrc
echo "alias reload='source ~/.bashrc && echo Bash config reloaded'" $bashrc
echo "alias lsa='ls -a'" >> $bashrc
echo "alias docs='cd ~/Documents'" >> $bashrc
echo "alias dwn='cd ~/Downloads'" >> $bashrc
echo "alias etc='cd  /etc'" >> $bashrc
echo "alias rc='nano ~/.bashrc'" >> $bashrc

# Print and log
echo "$(date) Added custom alias collection so sysadmin's bashrc." | tee -a $1

exit
