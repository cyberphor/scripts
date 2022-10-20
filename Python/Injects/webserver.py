#!/usr/bin/env python3
import http.server as SimpleHTTPServer
import socketserver as SocketServer
import logging

class CustomHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        logging.basicConfig(
            filename = "log.txt",
            filemode = "a",
            level = logging.INFO,
            datefmt = "%Y-%m-%d, %H:%M:%S",
            format = "%(asctime)s, %(message)s"
        )
        src_address = self.client_address[0]
        src_port = str(self.client_address[1])
        user_name = "-" 
        user_agent = self.headers.get_all("User-Agent")[0]
        fields = (src_address, src_port, user_name, user_agent)
        message = ", ".join(fields)
        logging.info(message)
        SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

ip = "192.168.1.133"
port = 80
server = (ip, port)
handler = CustomHandler
httpd = SocketServer.TCPServer(server, handler)
httpd.serve_forever()
