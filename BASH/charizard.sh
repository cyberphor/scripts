#!/usr/bin/bash

while getopts u:h:p: option; do 
    case "${option}" in 
        u) USERNAME=${OPTARG};; 
        h) REMOTEHOST=${OPTARG};; 
        p) FILEPATH=${OPTARG};; 
     esac 
done 

function check_permissions {
    if [[ $(id -u) != 0 ]]; then
        echo "[x] This script requires administrative privileges."
        exit 1
    fi
}
 
function check_for_files {
    LIST=$(find ./ -name "*.json" -o -name "*.sh")
    if [[ $LIST ]]; then
        scp $LIST $USERNAME@$REMOTEHOST:$FILEPATH
    fi
}

check_permissions
check_for_files

# References
# https://stackoverflow.com/questions/18215973/how-to-check-if-running-as-root-in-a-bash-script
# https://unix.stackexchange.com/questions/15308/how-to-use-find-command-to-search-for-multiple-extensions
# https://www.codebyamir.com/blog/parse-command-line-arguments-using-getopt
# https://www.poftut.com/how-to-pass-and-parse-linux-bash-script-arguments-and-parameters/
