#!/usr/bin/env python3

import argparse
import http.server
import ipaddress
import json
import netmiko
import os
import shutil
import ssl
import subprocess

class BoundaryDevice():
    def __init__(self):
        self.settings = {
            "device_type": "",
            "host": "",
            "username": "",
            "password": "",
        }
        self.acl = ""
        self.configure_acl_command_prefix = ""
        self.block_command_prefix = ""
        self.unblock_command_prefix = ""
    def block_host(self, host):
        commands = [
            " ".join(self.configure_acl_command_prefix, self.acl), 
            " ".join(self.block_command_prefix, host)
        ]
        with netmiko.ConnectHandler(**self.settings) as connection:
            connection.send_config_set(commands)
            message = "Blocking " + host + "\n"
        return message
    def unblock_host(self, host):
        commands = [
            " ".join(self.configure_acl_command_prefix, self.acl),
            " ".join(self.unblock_command_prefix, host)
        ]
        with netmiko.ConnectHandler(**self.settings) as connection:
            connection.send_config_set(commands)
            message = "Unblocking " + host + "\n"
        return message

class RequestHandler(http.server.BaseHTTPRequestHandler, BoundaryDevice):
    def do_GET(self):
        self.send_error(405)
    def do_POST(self):
        if self.path.startswith("/block/"):
            host = self.path.split("/block/")[1]
            try:
                ipaddress.ip_address(host)
                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                message = BoundaryDevice.block_host(host)
                self.wfile.write(message.encode("UTF-8"))
            except ValueError:
                self.send_error(400)
        elif self.path.startswith("/unblock/"):
            host = self.path.split("/unblock/")[1]
            try:
                ipaddress.ip_address(host)
                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                message = BoundaryDevice.unblock_host(host)
                self.wfile.write(message.encode("UTF-8"))
            except ValueError:
                self.send_error(400)
        else:
            self.send_error(404)

def generate_self_signed_certificate(so2ban_certificate_name):
    print("Generating a self-signed certificate...")
    country = "US" 
    state = "New York"
    locale = "New York City"
    company = "Allsafe" 
    section = "Cybersecurity"
    common_name = os.uname()[1]
    fields = country, state, locale, company, section, common_name
    openssl = [
        "openssl",
        "req",
        "-new",
        "-x509",
        "-days",
        "365",
        "-nodes",
        "-subj",
        ("/C=%s/ST=%s/L=%s/O=%s/OU=%s/CN=%s" % fields),
        "-keyout",
        so2ban_certificate_name,
        "-out",
        so2ban_certificate_name
    ]
    subprocess.run(openssl, stdout = subprocess.PIPE, check = True)
    print("Done!")
    return

def start_listening_api(so2ban_ip, so2ban_port, so2ban_certificate_name):
    address = (so2ban_ip, so2ban_port)
    device = BoundaryDevice()
    device.settings["device_type"] = "cisco_ios"
    device.settings["host"] = "192.168.1.1"
    device.settings["username"] = "admin"
    device.settings["password"] = "password"
    device.acl_name = "BLOCK_ADVERSARY"
    device.acl_command_prefix = "ip access-list standard"
    device.ace_command_prefix = "1 deny"
    handler = RequestHandler
    api = http.server.HTTPServer(address, handler)
    api.socket = ssl.wrap_socket(
        api.socket,
        server_side = True,
        certfile = so2ban_certificate_name,
        ssl_version = ssl.PROTOCOL_TLS
    )
    api.serve_forever()
    return

def update_action_menu(so2ban_ip, so2ban_port):
    default_action_menu = "/opt/so/saltstack/default/salt/soc/files/soc/menu.actions.json"
    local_action_menu = "/opt/so/saltstack/local/salt/soc/files/soc/menu.actions.json"
    link = "https://%s:%s/block/{value}" % (so2ban_ip, so2ban_port)
    action = {
        "name": "Block",
        "description": "Block at network perimeter",
        "icon": "fas fa-shield-alt",
        "target": "_blank",
        "links": [ link ],
        "background": True,
        "method": "POST"
    }
    so2ban = " ," + json.dumps(action) + "\n"
    if os.path.exists(local_action_menu):
        action_menu = local_action_menu
    else:
        action_menu = default_action_menu
    with open(action_menu) as old_action_menu:
        update = old_action_menu.readlines()
        second_to_last_line = len(update) - 1
        update.insert(second_to_last_line, so2ban)
        with open(local_action_menu, 'w') as new_action_menu:
            for entry in update:
                new_action_menu.write(entry)
    print("Done!")
    return

def restart_security_onion_console():
    print("Restarting the Security Onion Console...")
    subprocess.run("so-soc-restart", stdout = subprocess.PIPE, check = True)
    print("Done!")
    return

def main():
    so2ban_ip = "127.0.0.1"
    so2ban_port = 8666
    so2ban_certificate_name = "so2ban.pem"
    parser = argparse.ArgumentParser()
    parser.add_argument("--update-soc", action = "store_true", help = "Add so2ban to the Security Onion Console (SOC)")
    parser.add_argument("--start", action = "store_true", help = "Start so2ban")
    args = parser.parse_args()
    if args.update_soc:
        update_action_menu(so2ban_ip, so2ban_port)
        restart_security_onion_console()
    elif args.start:
        generate_self_signed_certificate(so2ban_certificate_name)
        start_listening_api(so2ban_ip, so2ban_port, so2ban_certificate_name)
    else:
        parser.print_help()
    return
  
if __name__ == "__main__":
    main()
