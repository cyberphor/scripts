#!/usr/bin/env python3

import argparse
import os
import socket
import threading

class online():
    def __init__(self,args):
        if args.connect and args.port:
            host = (args.connect,args.port)
            scoreboard = 'scoreboard.sqlite'
            challenges = 'challenges.sqlite'
            game = (scoreboard,challenges)
            self.client_mode(host,game)
        elif args.listen and args.port:
            host = (args.listen,args.port)
            scoreboard = 'scoreboard.sqlite'
            challenges = 'challenges.sqlite'
            game = (scoreboard,challenges)
            self.server_mode(host,game)

    def server_mode(self,host,game):
        if not 'SUDO_UID' in os.environ.keys():
            print('[x] This option requires super-user privileges (sudo).')
            exit()
        try:
            socket.inet_aton(host[0])
            self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)
            self.server.bind(host)
            self.listen()
        except OSError as e:
            error = ('[x] Error: %s' % (e))
            print(error)

    def listen(self):
        self.server.listen(20)
        while True:
            client, address = self.server.accept()
            client.settimeout(600) # 10 minutes
            players = (client,address)
            threading.Thread(self.serve,client).start()

    def serve(self,client):
        buffer_size = 2048
        while True:
            try:
                ping = client.recv(buffer_size)
                if ping:
                    pong = ping
                    client.send(pong)
            except:
               client.close()
               return False
         
    def client_mode(self,host,game):
        try:
            socket.inet_aton(host[0])
        except OSError as e:
            error = ('[x] Error: %s' % (e))
            print(error)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--listen')
    parser.add_argument('-c', '--connect')
    parser.add_argument('-p', '--port', type = int)
    args = parser.parse_args()
    network = online(args)

if __name__ == '__main__':
    main()

# REFERENCES
# https://stackoverflow.com/questions/23828264/how-to-make-a-simple-multithreaded-socket-server-in-python-that-remembers-client
# https://docs.python.org/3/library/argparse.html#type
