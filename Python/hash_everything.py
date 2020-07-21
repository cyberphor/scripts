#!/usr/bin/env python3

import argparse
import hashlib

def hash_everything():
    dashes = "-------------------------------------------"
    banner = "\n| NOTE: Use single-spaces as a delimiter. |\n"
    print(dashes + banner + dashes)
    stuff = input('[>] Stuff to hash: ').encode()
    stuff_hashed = hashlib.md5(stuff).hexdigest()
    print(" --> " + stuff_hashed)

def hash_explicit():
    parser = argparse.ArgumentParser()
    parser.add_argument('--count')
    parser.add_argument('--ip')
    parser.add_argument('--md5-hash')
    args = parser.parse_args()
    count = args.count
    ip = args.ip
    md5_hash = args.md5_hash
    if count and ip:
        print(count)
        this = count + ip
        foo = hashlib.md5(this.encode()).hexdigest()
        print(foo)

hash_everything()
#hash_explicit()
