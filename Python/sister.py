#!/usr/bin/python2

from scapy.all import *
import glob
import json
import os
import argparse
import codecs

parser = argparse.ArgumentParser()
parser.add_argument('--test-bro', action='store_true')
args = parser.parse_args()

def update_bro():
    if not 'SUDO_UID' in os.environ.keys():
        print('[x] This script requires super-user privileges (sudo).')
        exit()
    current_intel, restart_bro = check_so_version()
    get_intel(current_intel,restart_bro)

def check_so_version():
    searchme = open("/etc/lsb-release").readlines()
    pattern = "RELEASE"
    matches = []
    for line in searchme:
        if re.findall(pattern,line):
            matches.append(line.split("="))
    so_version = matches[0][1]
    if "14" in so_version:
        current_intel = "/opt/bro/share/bro/intel/intel.dat"
        restart_bro = "sudo so-bro-restart"
    elif "16" in so_version:
        current_intel = "/opt/zeek/share/bro/intel/intel.dat"
        restart_bro = "sudo so-zeek-restart"
    else:
        print('[x] Failed to detect which version of Security Onion you are running.')
        exit()
    return current_intel, restart_bro

def get_intel(current_intel,restart_bro):
    directory = glob.glob('*_indicators_*.json')
    updates = 0
    for new_intel in directory:
        print('[+] Ingesting ' + new_intel)
        if get_iocs(current_intel,new_intel) > 0:
            updates = updates + 1
    if updates > 0:   
        os.system(restart_bro)

def get_iocs(current_intel,new_intel):
    json_filepath = './' + new_intel
    json_file = open(json_filepath,)
    json_data = json.load(json_file)
    json_file.close()

    label = {
        'ip_address':'Intel::ADDR',
        'ip_address_block':'Intel::SUBNET',
        'email_address':'Intel::EMAIL',
        'url':'Intel::URL',
        'domain':'Intel::DOMAIN',
        'hash_md5':'Intel::FILE_HASH',
        'hash_sha1':'Intel::FILE_HASH',
        'hash_sha256':'Intel::FILE_HASH',
        'file_name':'Intel::FILE_NAME'
     }
 
    dict_of_iocs = {}
    for line in json_data:
        ioc = line['value']
        ioc_type = label.get(line['type_name'], 'Intel::SOFTWARE')
        for actor in line['actors']:
            if 'slug' in actor:
                ioc_source = 'crowdstrike_' + actor['slug']
        attributes = ioc, ioc_type, ioc_source, "T"
        dict_of_iocs[ioc] = '\t'.join(attributes)
    return tell_bro(current_intel,dict_of_iocs)

def tell_bro(current_intel,dict_of_iocs):
    intel_path = codecs.open(current_intel,'a',encoding='utf-8')
    intel = codecs.open(current_intel,encoding='utf-8').read()
    updates = 0
    for ioc in dict_of_iocs:
        if ioc not in intel:
            intel_path.write(dict_of_iocs[ioc] + '\n')
            updates = updates + 1
    print(" ---> Updated Bro with %d IOCs." % updates)
    intel_path.close()
    return updates

def test_bro():
    current_intel, restart_bro = check_so_version()
    searchme = open(current_intel).readlines()
    pattern = "Intel::DOMAIN"
    matches = []
    for line in searchme:
        if re.findall(pattern,line):
            matches.append(line.split("\t"))
    ioc = matches[-1][0]
    build_packets(ioc)

def get_nic():
    searchme = open('/etc/network/interfaces').read()
    pattern = "((.*\n){1}).*promisc.*"
    nic = re.findall(pattern,searchme)[0][0].split(' ')[1]
    # nic = raw_input("[+] What NIC are you sniffing with?")
    return nic

def build_packets(ioc):
    ether = Ether()
    ether.src = '00:0a:0b:0c:0d:11'
    ether.dst = '00:0a:0b:0c:0d:22'
    ip = IP()
    ip.src = "127.0.0.1"
    ip.dst = "10.10.10.10"
    udp = UDP()
    udp.sport = 4321
    udp.dport = 53
    dns = DNS()
    dns.rd = 1
    dns.qd = DNSQR()
    dns.qd.qname = ioc
    packet = ether/ip/udp/dns
    if (os.path.exists("./brotest.pcap")):
        os.system("sudo rm ./brotest.pcap")
    for i in range(0,10):
        wrpcap("brotest.pcap", packet, append=True)
    nic = get_nic()
    replay_traffic(ioc,nic)

def replay_traffic(ioc,nic):
    print('[+] Testing Bro with the "%s" domain.' % ioc)
    replay = "sudo tcpreplay -i %s ./brotest.pcap" % nic
    cleanup = "sudo rm ./brotest.pcap"
    os.system(replay)
    os.system(cleanup)

if __name__ == "__main__":
    update_bro()
    if args.test_bro:
        test_bro()
