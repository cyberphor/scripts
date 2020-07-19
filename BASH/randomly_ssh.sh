#!/usr/bin/env bash
# SYNTAX: ./randomly_ssh.sh victor password 192.168.56.3

echo "[+] Username: $1, Password: $2, Target: $3"
for i in {1..10}; do
    hydra -l $1 -p $2 -t 4 ssh://$3 > /dev/null
    number=$((($RANDOM % 10) * $i))
    echo "[+] Trying again in $number second(s)."
    sleep $number
done
