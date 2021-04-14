#/usr/bin/bash

SHADOWFILE=$1
while read LINE; do
    NAME=$(echo $LINE | cut -d: -f1)
    HASH=$(echo $LINE | cut -d: -f2)
    echo "$NAME:$HASH::0:0:$NAME:/home/$NAME:/bin/bash"
done < $SHADOWFILE
