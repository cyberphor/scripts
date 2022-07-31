#!/usr/bin/env python3

import http.server as SimpleHTTPServer
import socketserver as SocketServer
import logging

class GetHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        logging.basicConfig(filename="users.txt",
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)
        logging.info(self.headers)
        SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

Handler = GetHandler
httpd = SocketServer.TCPServer(("", 443), Handler)
httpd.serve_forever()
