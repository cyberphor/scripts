#!/usr/bin/env python3

import argparse
import ipaddress
import socket
import re

def scan():
    parser = argparse.ArgumentParser()
    parser.add_argument('--network',type=str,help='The network to scan.')
    parser.add_argument('--ip',type=str,help='The IP address to scan.')
    parser.add_argument('--ports',type=int,help='The ports to scan.')
    args = parser.parse_args()
    if args.network:
        try:
            subnet = list(ipaddress.ip_network(args.network).hosts())
            scan_network(subnet)
        except ValueError as err:
            print("[x] Invalid subnet mask: %s" % args.network)
            print(" ---> %s" % err)
            exit()
    elif args.ip:
        scan_host(args.ip)
    else:
        print("[x] No input provided.")
        print(" ---> Run 'sudo ./port_scanner.py -h' for more info.")

def scan_network(subnet): 
    for ip in subnet:
        ip = str(ip)
        scan_host(ip)

def scan_host(ip):
    try:
        socket.inet_aton(ip)
        scan_ports(ip)
    except OSError:
        print("[x] Invalid IP address: %s" % ip)
        print(" ---> Run 'sudo ./port_scanner.py -h' for more info.")
        exit()

def scan_ports(ip):
    scanner = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    ports = 22,23,25,53,80,443
    for port in ports:
        try:
            target = ip, port
            scanner.connect(target)
            banner = scanner.recv(1024).decode('latin-1').rstrip()
            scanner.close()
            success = ("[+] %s:%s | " + banner) % (ip, port)
            print(success)
        except:
            continue

if __name__ == "__main__":
    scan()

# References
# https://stackoverflow.com/questions/11264005/using-a-regex-to-match-ip-addresses-in-python/11264056
# https://stackoverflow.com/questions/39751563/python-ipaddress-get-first-usable-host-only
