#!/usr/bin/env python3

import argparse
import os
import requests

parser = argparse.ArgumentParser()
parser.add_argument('--virus-total', action='store_true')
parser.add_argument('--team-cymru', action='store_true')
args = parser.parse_args()

def collect():
    directory = os.scandir('.')
    files = []
    for entry in directory:
        if entry.is_file():
            files.append(entry.name)
    fingerprint(files)

def fingerprint(files):
    evidence = {}
    for filepath in files:
        cmd = "md5sum '" + filepath + "' | awk '{print $1}'"
        bash_pipeline = os.popen(cmd)
        md5 = bash_pipeline.read().rstrip()
        evidence[md5] = filepath
    total = str(len(evidence))
    print("[+] Pivoting to " + data_source + " with " + total + " values of interest.")
    for md5 in evidence:
        pivot(md5)

def pivot_2_virus_total(md5):
    url = 'https://www.virustotal.com/vtapi/v2/file/search'
    key = ''
    query = ''
    try:
        params = { 'apikey': key, 'query': md5 }
        response = requests.get(url, params=params).json()
        print(response)
    except:
        print("[x] Failed to pivot to VirusTotal.")
        exit()

def pivot_2_team_cymru(md5):
    print("[x] Failed to pivot to Team Cymru's Malware Hash Registry.")
    exit()

if __name__ == "__main__":
    if args.virus_total:
        data_source = 'VirusTotal'
        pivot = pivot_2_virus_total
    elif args.team_cymru:
        data_source = 'Team Cymru'
        pivot = pivot_2_team_cymru
    else:
        data_source = 'VirusTotal'
        pivot = pivot_2_virus_total
    collect()

# REFERENCES
# https://developers.virustotal.com/reference#file-search
# https://stackoverflow.com/questions/22058048/hashing-a-file-in-python
# https://docs.python.org/3/library/os.html#os.scandir
# https://developers.google.com/edu/python/dict-files
