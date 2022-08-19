#!/usr/bin/env python3

# from getpass import getpass
from http.server import BaseHTTPRequestHandler, HTTPServer
# from netmiko import ConnectHandler
import ipaddress

ip = "127.0.0.1"
port = 666
server_address = (ip, port)
router = {
    "device_type": "cisco_ios",
    "host": "router",
    "username": "admin",
    "password": "password",
}

class RequestHandler(BaseHTTPRequestHandler):
    def block(self, adversary):
        """
        command = "" # block command goes here
            with ConnectHandler(**router) as net_connect:
        output = net_connect.send_command(command)
        print(output)
        """
        message = "Blocking " + adversary + "\n"
        self.wfile.write(message.encode("UTF-8"))
    def do_GET(self):
        self.send_error(405)
    def do_POST(self):
        if self.path.startswith("/block/"):
            adversary = self.path.split("/block/")[1]
            try:
                ipaddress.ip_address(adversary)
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.block(adversary)
            except ValueError:
                self.send_error(400)
        else:
            self.send_error(404)

def main():
    handler = RequestHandler
    server = HTTPServer(server_address, handler)
    server.serve_forever()

if __name__ == "__main__":
    main()
