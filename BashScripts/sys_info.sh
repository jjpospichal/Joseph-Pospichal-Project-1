#!/bin/bash

#Check if script was run as root. Exit if false.
if [ $UID -ne 0 ]
#another way to check if roor: if [ $UID -eq 0 ]
then
  echo "Please run this script as sudo."
  exit
fi

# Define Variables
output=$HOME/research/sys_info.txt
ip=$(ip addr | grep inet | tail -2 | head -1)
suids=$(find / -type f -perm /4000 2> /dev/null)

# Check for research directory. Create it if needed.
if [ ! -d $HOME/research ]
then
 mkdir $HOME/research
 echo "Directory research created" >> $output
fi

# Check for output file. Clear it if needed.
if [ -f $output ]
then
  rm $output
# another way to remove is:  > $output
fi

echo "A Quick System Audit Script" >> $output
echo "" >> $output
date >> $output
echo "" >> $output

#Display Machine Type Info
echo "Machine Type Info:" >> $output
echo -e "$MACHTYPE \n" >> $output

#Display User Name info
echo -e "Uname info: $(uname -a) \n" >> $output

#Display IP Info
echo -e "IP Info: $(ip add | head -9 | tail -1)\n" >> $output

#Display Hostname
echo -e "Hostname: $(hostname -s) \n" >> $output

#Display DNS Servers
echo "DNS Servers: " >> $output
cat /etc/resolv.conf >> $output

#Display Memory Info
echo -e "\nMemory Info:" >> $output
free >> $output

#Display CPU usage
echo -e "\nCPU Info:" >> $output
lscpu | grep CPU >> $output

#Display Disk usage
echo -e "\nDisk Usage:" >> $output
df -H | head -2 >> $output

#Display the current user
echo -e "\nWho is logged in: \n $(who -a) \n" >> $output

#Display SUID files
echo -e "\nSUID Files:" >> $output
echo $suids >> $output

#Display Top 10 Processes
echo -e "\nTop 10 Processes" >> $output
ps aux --sort -%mem | awk {'print $1, $2, $3, $4, $11'} | head >> $output

# Sensive paths
files=(
'/etc/passwd'
'/etc/shadow'
'/etc/hosts'
)

#Display permissions for sensitive files in /etc
echo -e "\nThe permissions for sensitive /etc files: \n" >> $output
for file in ${files[@]}
do
   ls -l $file >> $output
done

# For loop that checks the sudo abilities of all users
for user in $(ls /home)
do 
  sudo -lY $user
done

#Create a list that contains date, uname -a & hostname -s
#This the same as  cmd line:
#for user in $(ls .home); do sudo  -lU $user
 commands=(
  'date'
  'uname -a'
  'hostname -s'
)

for x in {0..2}
do 
  results=$(${commands[$x]})
  echo "Results of \"${commands[$x]}\" command:" >> $output
  echo $results >> $output
  echo "" >> $output
done
x in {0..2}
do 
  results=$(${commands[$x]})
  echo 'Results of \"${commands[$x]}\" command:' >> $output
  echo $results >> $output
  echo "" >> $output
done
fi
