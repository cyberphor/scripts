#!/usr/bin/env bash

UPDATES=("1.1.1.1 # foo" "2.2.2.2 # bar" "3.3.3.3 # bug")
WHITELIST='/etc/elastalert/rules/_authorized_ips.txt'

function check_permissions {
    if [[ $(id -u) != 0 ]]; then
        echo "[x] This script requires administrative privileges."
        exit 1
    fi
}

function add_updates {
    COUNT=0
    LIST=$(cat $WHITELIST)
    for UPDATE in "${UPDATES[@]}"; do
        if [[ ! $LIST =~ $UPDATE ]]; then
            echo $UPDATE >> $WHITELIST && let "COUNT=COUNT+1"
        fi
    done
    echo " ---> Added $COUNT updates."
}

function check_whitelist {
    if [ -f $WHITELIST ]; then
        echo '[+] Whitelist exists.'
        add_updates
    else
        touch $WHITELIST && echo '[+] Created whitelist.'
        add_updates
    fi
}

check_permissions
check_whitelist

# References
# https://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-6.html
# https://stackoverflow.com/questions/59838/how-can-i-check-if-a-directory-exists-in-a-bash-shell-script
# https://stackoverflow.com/questions/30992072/how-do-i-check-whether-a-file-or-file-directory-exist-in-bash
# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# https://stackoverflow.com/questions/12316167/does-linux-shell-support-list-data-structure
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
# https://linuxize.com/post/bash-increment-decrement-variable/
