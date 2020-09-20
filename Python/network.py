#!/usr/bin/env python3

import argparse
import datetime
import os
import socket
import threading

class online():
    def __init__(self,args):
        self.buffer = 2048
        if args.connect and args.port:
            host = (args.connect,args.port)
            scoreboard = 'scoreboard.sqlite'
            challenges = 'challenges.sqlite'
            game = (scoreboard,challenges)
            self.client_mode(host)
        elif args.listen and args.port:
            host = (args.listen,args.port)
            scoreboard = 'scoreboard.sqlite'
            challenges = 'challenges.sqlite'
            self.game = (scoreboard,challenges)
            self.server_mode(host)

    def server_mode(self,host):
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
            dtg = datetime.datetime.now().strftime('%I:%M:%S %p')
            print('[%s] New player: %s (port %s)' % (dtg,address[0],address[1]))
            threading.Thread(target=self.serve, args=(client,address)).start()

    def serve(self,client,address):
        while True:
            try:
                ping = client.recv(self.buffer)
                if ping:
                    dtg = datetime.datetime.now().strftime('%I:%M:%S %p')
                    pong = ping
                    client.send(pong)
                    print('[%s] %s, %s: %s' % (dtg,address[0],address[1],ping.decode()))
            except:
               client.close()
               return False
         
    def client_mode(self,host):
        try:
            socket.inet_aton(host[0])
            client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            client.connect(host)
            connected = True
            while connected:
                cmd = self.play(host)
                if len(cmd) != 0:
                    client.sendall(cmd)
                    msg = client.recv(self.buffer).decode()
                    if msg == 'DISCONNECT':
                        connected = False
                    dtg = datetime.datetime.now().strftime('%I:%M:%S %p')
                    print('[%s] CTF Server: %s' % (dtg,msg))
            client.close()
        except OSError as e:
            error = ('[x] Error: %s' % (e))
            print(error)

    def play(self,host):
        self.username = 'cyberphor'
        dtg = datetime.datetime.now().strftime('%I:%M:%S %p')
        prompt = '[%s] %s: ' % (dtg,self.username)
        cmd = input(prompt)
        return bytes(cmd,'UTF-8')

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
# https://docs.python.org/3/howto/sockets.html
# https://docs.python.org/3/library/datetime.html
