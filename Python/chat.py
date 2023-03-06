#!/usr/bin/env python3

import socket

class Bot (
    def __init__(self):
        self.channel = "#skynet"
        self.nickname = "T-800"
        self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.port = ("", 6667)
        self.connect(server)

    def joinchan(channel):
        ircsocket.send(bytes("JOIN "+ channel +"\n", "UTF-8"))
        ircmsg = ""
        
        while ircmsg.find("End of /NAMES list.") == -1:
            ircmsg = ircsocket.recv(2048).decode("UTF-8")
            ircmsg = ircmsg.strip('\n\r')
            print(ircmsg)

    def ping():
        ircsocket.send(bytes("PONG :pingis\n", "UTF-8"))

    def sendmsg(msg, target=channel):
        ircsocket.send(bytes("PRIVMSG "+ target +" :"+ msg +"\n", "UTF-8"))

    def main():
        joinchan(channel)

        while 1:		
            ircmsg = ircsocket.recv(2048).decode("UTF-8")
            ircmsg = ircmsg.strip('\n\r')
            print(ircmsg)

            if ircmsg.find('PRIVMSG') != -1:
                
                name = ircmsg.split('!',1)[0][1:]
                message = ircmsg.split('PRIVMSG', 1)[1].split(':',1)[1]
        
                if len(name) < 17:
                    
                    if message.find("Hi " + botnick) != -1:
                        sendmsg("Hello " + name + "!")
            
                    if name.lower() == botmaster.lower() and message.rstrip() == killswitch:
                        sendmsg(“Affirmative, powering down.”)
                        ircsocket.send(bytes("QUIT \n", "UTF-8"))
                        return

        else:
            if ircmsg.find("PING :") != -1:
                ping()
)
main()