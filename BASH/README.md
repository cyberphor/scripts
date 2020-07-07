```bash
# modified ping
ping 8.8.8.8 | awk '{print $5,$7}'


# Find new files
while ($true); do sleep 60 && clear && date && find /home/Victor/ -cmin +10 -cmin -10 

# watch network connections
vim /scripts/watchNetConnections.sh

#!/bin/bash
while ($true); do sleep 7 && clear && date && netstat -a | \
grep 'ESTABLISHED' | \
grep -v 'localhost'| \
awk '{print $4,$5}' | \
sort -u; done

chmod +x /scripts/watchNetConnections.sh
chown vic:sudo /scripts/watchNetConnections.sh
/scripts/watchNetConnections.sh


# Watch running processes

vim /scripts/watchRunningProcs.sh

while ($true); do sleep 5 && clear && date && ps -u root | \
head | \
awk '{print $2,$4,$5}'; done

chmod +x /scripts/watchRunningProcs.sh
chown vic:sudo /scripts/watchRunningProcs.sh
/scripts/watchRunningProcs.sh

# disk free
while ($true); do sleep 30 && clear && date && df -H; done

# list new files
while ($true); do sleep 30 && clear && date && ls -alTUG /home/Victor/; done

# arious aliases and functions in my `/etc/bash.bashrc` file. 
vim /etc/bash.bashrc
alias ll="ls -al"
alias cls="clear"
alias llc="ls ./*.c"

function clc() {
	# move C source files in current directory to a backup lab folder
	for cFile in $(ls ./*.c); do
		echo Moving: $cFile
		mv $cFile /root/lab/c/src/
	done
} 

# Ping and display results into a web app
vim /scripts/PingWebApp.sh

#!/bin/bash
# create database NetworkStats
# create table PingResults
# create user
# show table Network.Stats.PingResults was successfully made
# show user created was successfully made

ping -c 4 8.8.8.8 | \
awk '{print $4, $7}' | \
grep 'time' > \
/scripts/PingResults.txt

echo "LOAD DATA LOCAL INFILE '/scripts/PingResults.txt' \
INTO TABLE PingResults FIELDS TERMINATED BY ' '" | \
mysql NetworkStats -u root -p

chmod +x /scripts/PingWebApp.sh
chown vic:sudo /scripts/PingWebApp.sh
/scripts/PingWebApp.sh

# Scan the network
vim /scripts/scanNetwork.sh

#!/bin/bash
nmap 192.168.0.0/24 -sn > \

chmod +x /scripts/scanNetwork.sh
chown vic:sudo /scripts/scanNetwork.sh
/scripts/scanNetwork.sh
```
