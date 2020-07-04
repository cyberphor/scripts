#!/usr/bin/env python3

import socket

scanner = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
ip = '127.0.0.1'
ports = range(0,256)
target = ip, port

def scan_ports():
    for port in ports:
        try:
            scanner.connect(target)
            banner = scanner.recv(1024).decode('latin-1').rstrip()
            scanner.close()
            success = ("[+] Port %s is open: " + banner) % port
            print(success)
        except:
            continue

scan_ports()
