## Table of Contents
* [Web server](#web-server)
* [IRC botnet](#irc-botnet)
  * [IRC server](#irc-server)
  * [IRC bots](#irc-bots)
  
## Web server
```python
cd /into/directory/with/files/you/want/to/serve/
sudo python -m SimpleHTTPServer 443
```

## IRC botnet
Creating an IRC Botnet has two main parts: (1) establishing an IRC server and (2) generating the bots.

### IRC server
```bash
sudo apt install ircd-hybrid libltd17 whois
```
```bash
/usr/bin/mkpasswd <password>
```
```bash
sudo vim /etc/ircd-hybrid/ircd.conf
```
```bash
Server Info {
name = "irc.server01.sky.net";
description = "Cool-guy IRC Server";
network_name = "sky.net";
network_desc = "A network to control the Terminators."; 
max_clients = 13;
}

Auth {
# flags = need_ident;
}

Operator Info { 
name = "tank"; 
user = "*@*"; 
password = "<encrypted version of password>;"
}
```
```bash
sudo vim /etc/ircd-hybrid/irc.motd
```
```
ACCESSING: irc.server01.sky.net
----------------------------------------------
           o    .   _     .
             .     (_)         o
      o      ____            _       o
     _   ,-/   /)))  .   o  (_)   .
    (_)  \_\  ( e(     O             _
    o       \/' _/   ,_ ,  o   o    (_)
     . O    _/ (_   / _/      .  ,        o
        o8o/    \\_/ / ,-.  ,oO8/( -TT
       o8o8O | } }  / /   \Oo8OOo8Oo||     O
      Oo(""o8"""""""""""""""8oo""""""")    
     _   `\`'                  `'   /'   o
    (_)    \                       /    _   .
         O  \           _         /    (_)
   o   .     `-. .----<(o)_--. .-'
      --------(_/------(_<_/--\_)--------
   Can't you see I'm trying to take a bath?
----------------------------------------------
```
```bash
sudo /etc/init.d/ircd-hybrid restart
```
```bash
nmap localhost
```

### IRC bots
```bash
vim ./bot.py
```
```python
#!/usr/bin/python3
import socket

ircsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server = "<your IRC servers IP address>"
channel = "#terminators"
botnick = "bot01"
botmaster = "cyberdyne"
killswitch = "die " + botnick

ircsocket.connect((server, 6667))
ircsocket.send(bytes("USER "+ botnick +" "+ botnick +" "+ botnick +" "+ botnick +"\n", "UTF-8"))
ircsocket.send(bytes("NICK "+ botnick +"\n", "UTF-8"))

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
main()
```
