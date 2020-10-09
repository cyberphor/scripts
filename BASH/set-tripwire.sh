#!/bin/bash

MISSING_FILES='/etc/tripwire/missing.txt'
TW_POLICY='/etc/tripwire/twpol.txt'

tripwire --check | \
grep Filename | \
awk '{print $2}' >> $MISSING_FILES

for file in $(cat $MISSING_FILES); do
    if egrep -q $file $TW_POLICY; then
        if egrep -q \#$file $TW_POLICY; then
            sed -i "s|$file|#$file|g" $TW_POLICY
        fi
    fi
done
