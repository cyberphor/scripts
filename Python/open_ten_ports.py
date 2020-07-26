#!/usr/bin/env python3

import os

def open_ten_ports():
    for i in range(10):
        cmd = "python3 -m http.server 666%d > /dev/null &" % i
        os.system(cmd)

open_ten_ports()
