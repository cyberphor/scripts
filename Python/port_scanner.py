#!/usr/bin/env python3

import argparse
import socket

def scan():
    parser = argparse.ArgumentParser()
    parser.add_argument('--subnet',type=str,help='The network to scan.')
    parser.add_argument('--ip',type=str,help='The IP address to scan.')
    args = parser.parse_args()
    ports = range(0,256)
    if args.subnet:
        subnet = []
        subnet.append(args.subnet)
        scan_network(subnet,ports)
    elif args.ip:
        ip = args.ip
        print("[+] Scanning %s" % ip)
        scan_ports(ip,ports)
    else:
        print("[x] No input provided.")
        print(" ---> Run 'sudo ./port_scanner.py -h' for more info.")

def scan_network(subnet,ports): 
    for ip in subnet:
        try:
            socket.inet_aton(ip)
            print("[+] Scanning %s" % ip)
            scan_ports(ip,ports)
        except OSError:
            print("[x] Invalid IP address: %s" % ip)

def scan_ports(ip,ports):
    scanner = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    for port in ports:
        try:
            target = ip, port
            scanner.connect(target)
            banner = scanner.recv(1024).decode('latin-1').rstrip()
            scanner.close()
            success = (" ---> Port %s is open: " + banner) % port
            print(success)
        except:
            continue

if __name__ == "__main__":
    scan()

# References
# https://stackoverflow.com/questions/11264005/using-a-regex-to-match-ip-addresses-in-python/11264056
