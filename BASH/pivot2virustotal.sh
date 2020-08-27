#!/usr/bin/env bash

KEY=''

for OBJECT in $(ls); do
    md5sum $OBJECT >> hashes.txt
done

while read LINE; do
    HASH=$(echo $LINE | awk '{print $1}')
    FILE=$(echo $LINE | awk '{print $2}')
    curl --request GET --url 'https://www.virustotal.com/vtapi/v2/file/search?apikey=$KEY&query=$HASH'
    # do something if hash has a negative reputation
done < hashes.txt
