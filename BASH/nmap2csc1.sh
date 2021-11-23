#!/usr/bin/bash

ADDRESSES=$(cat $1 | grep "Nmap scan report" | cut -d" " -f5)
for ADDRESS in $ADDRESSES
do
  sed "/Nmap scan report for $ADDRESS/,/^$/p" $1
done
