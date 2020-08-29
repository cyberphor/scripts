#!/usr/bin/env python3

import argparse
import json
import os
import requests
import select
import socket
import time

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
    for filename in files:
        cmd = "md5sum '" + filename + "' | awk '{print $1}'"
        bash_pipeline = os.popen(cmd)
        digest = bash_pipeline.read().rstrip()
        evidence[digest] = filename
    total = str(len(evidence))
    print("[+] Pivoting to " + data_source + " with " + total + " values of interest.")
    pivot(evidence)

def pivot_2_virus_total(evidence):
    vt = 'https://www.virustotal.com/api/v3/files/'
    key = ''
    for digest in evidence:
        filename = evidence[digest]
        with requests.session() as browser:
            url = vt + digest
            custom_headers = { 'x-apikey': key }
            response = requests.get(url, headers = custom_headers)
            if response.status_code == 200:
                results = json.loads(response.content)['data']
                attributes = results.get('attributes')
                detected = attributes['last_analysis_stats']['malicious']
                undetected = attributes['last_analysis_stats']['undetected']
                scanner_count = detected + undetected
                percent = str(detected) + '/' + str(scanner_count)
                print(" --> " + percent, digest, filename)
        time.sleep(15)

def pivot_2_team_cymru(evidence):
    try:
        mhr = ('hash.cymru.com', 43)
        hashes = ['begin']
        for digest in evidence:
            hashes.append(digest)
        hashes.append('end')
        hashes = '\n'.join(hashes)
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect(mhr)
        client.sendall(bytes(hashes,'UTF-8'))
        data = client.recv(1)
        on,off,out = select.select([client],[client],[client])
        while on:
            data += client.recv(2048)
            time.sleep(.15)
            on,off,out = select.select([client],[client],[client])
        client.close()
        results = data.decode().split('\n')[:-1]
        del results[0:2]
        for result in results:
            percent = result.split(' ')[-1]
            if percent != 'NO_DATA':
                digest = result.split(' ')[0]
                filename = evidence[digest] 
                print(" --> " + percent, digest, filename)
    except:
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
# https://developers.virustotal.com/v3.0/reference#overview
# https://developers.virustotal.com/reference#file-search
# https://stackoverflow.com/questions/22058048/hashing-a-file-in-python
# https://docs.python.org/3/library/os.html#os.scandir
# https://developers.google.com/edu/python/dict-files
# https://stackoverflow.com/questions/930397/getting-the-last-element-of-a-list
