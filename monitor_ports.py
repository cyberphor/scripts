#!/usr/bin/env python3

import argparse
import os

def get_sector():
    netstat = "sudo netstat -ant | tail -n +3 | "
    inbound = "awk '{print $4}' | cut -d':' -f2"
    outbound = "grep ESTABLISHED | awk '{print $5}' | cut -d':' -f2"
    if args.inbound:
        cmd = netstat + inbound
    elif args.outbound:
        cmd = netstat + outbound
    else:
        cmd = netstat + inbound
    if args.ports:
        whitelist = args.ports
    else:
        whitelist = ["22","53"]
    return whitelist, cmd

def monitor():
    whitelist, cmd = get_sector()
    bash_pipeline = os.popen(cmd)
    raw = bash_pipeline.readlines()
    open_ports = list(map(lambda port:port.rstrip(),raw))
    alert = []
    for port in open_ports:
        if (port not in whitelist) and (port not in alert):
            alert.append(port)
    if alert:
        print("[!] Unauthorized network usage:")
        for port in alert:
            print(port)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--inbound', action='store_true')
    parser.add_argument('--outbound', action='store_true')
    parser.add_argument('--ports',nargs='+')
    args = parser.parse_args()
    monitor()

# references
# https://janakiev.com/blog/python-shell-commands/
# https://stackoverflow.com/questions/3849509/how-to-remove-n-from-a-list-element
