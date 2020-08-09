#!/usr/bin/env bash

OS=$(python -m platform)

ALL=(
'/var/log/kern.log' 
'/var/log/cron'
)

DEBIAN=(
'/var/log/syslog'
'/var/log/auth.log'
)

RHEL=(
'/var/log/messages'
'/var/log/secure'
)

if [[ $OS =~ 'debian' || 'ubuntu' ]]; then
    echo '[+] This is machine is Debian-based.'
    for LOG in "${DEBIAN[@]}"; do
        if [[ -f $LOG ]]; then
            echo " ---> Parsing $LOG"
        fi
    done
fi

# References
# https://www.loggly.com/ultimate-guide/linux-logging-basics/
# https://stackoverflow.com/questions/46136611/how-to-define-array-in-multiple-lines-in-shell
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri/459406#459406
