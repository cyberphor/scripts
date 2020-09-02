# Python Scripts

## Table of Contents
* [scoreboard.py](#scoreboardpy)
* [One-Liners](#one-liners)
* [Regex Examples](#regex-examples)

### scoreboard.py
Installation
```bash
git clone https://github.com/cyberphor/scripts.git 
chmod 755 ./scripts/Python/scoreboard.py
sudo cp ./scripts/Python/scoreboard.py /usr/local/bin/scoreboard.py
```
Examples
```bash
scoreboard.py --create # create a scoreboard
[+] Created scoreboard. # output

scoreboard.py --add-player # add a player
[>] Username: victor
[>] Password: please
[>] Score: 0
[+] Added player: 
('victor', 0) # output

scoreboard.py --get-scores # check the scores
('victor', 0) # output
```

### One-Liners
Convert an IPv4 address to hex and use it with a Wireshark Display Filter.
```python
python3 -c "import socket; print(socket.inet_aton('192.168.56.23').hex())"
c0a83817 # output
tshark -nr traffic.pcap "frame contains c0.a8.38.17"
```

Web Server
```python
cd /into/directory/with/files/you/want/to/serve/
sudo python -m SimpleHTTPServer 443
```

### Regex Examples 
```python
fc = open(​"path/to/dns/log"​).read()
import​ re
re.findall(​"client"​, fc) ​# find all instances of 'client' in fc var 
re.findall(​"client [0-9][0-9]"​, fc) ​# find 'client' followed by 2 digits 
re.findall(​"client \d\d\d"​, fc) ​# find 'client' followed by 3 digits 
re.findall(​"client \d{3}"​, fc) #​ find 'client' followed by 3 digits 
re.findall(​"client \d{1,3}"​, fc) ​# find 'client' followed by 1-3 digits 
re.findall(​"cl.ent \d{1,3}"​, fc) ​# period = any char, once 
re.findall(​"client \d{1,3}\."​, fc) #​ \. = find actual period 
re.findall(​"client \d{1,3}\.\d{1,3}\.\d{1,3}"​, fc)
re.findall(​"client 1\d{1,2}\.\d{1,3}\.\d{1,3}"​, fc) ​# first octet is 1.. 
re.findall(​"client 1.5"​, fc) ​# 1st octet must be 3chars, start w/1, end w/5 
re.findall(​"client .?"​, fc) ​# .? = makes period optional 
re.findall(​"client .?"​, fc)[:​10]​ ​# first 10
re.findall(​"query: ([a-z.]{1,100}) IN "​, fc)[:​10​]
re.findall(​"client \d{1,3}\.\d{1,3}\.\d{1,3}.*? query: ([a-z.]{1,100})"​) 
re.findall(​b"byte_string"​, fc)
re.findall(​"\D"​, fc) ​# find all non-digit chars
re.findall(​"\w"​, fc) ​# find all word chars
re.findall(​"\W"​, fc) ​# find all non-word chars
re.findall(​"\s"​, fc) ​# find all space chars
re.findall(​"\S"​, fc) ​# find all non-space chars
re.findall(​"\b"​, fc) ​# find border of a word char; words of certain length 
re.findall(​r"\w"​, fc) ​# ignore/don't interpret backslashes
re.findall(r​b"\x00"​, fc) ​# raw bytes
re.findall(​r"\w"​, fc)
re.findall(​r"(?:[1-9])"​) ​# (?:) = look for raw string, ignore parenthesis
re.findall(​"\d+"​, fc) ​# look for 1 or more digits
re.findall(​"\d*"​, fc) ​# look for 0 or more digits
re.findall(​"\d?"​, fc) ​# match 0 or 1 instances of a digit 
re.findall(​"\d{100}"​, fc) ​# look for exactly 100 digits 
re.findall(​"\d{1,100}"​, fc) ​# look for between 1 and 100 digits 
re.findall(​"Sentence."​, fc) ​# finds longest match
re.findall(​"Sentence."​, fc) ​# find shortest match 
re.findall(​"[^S]entence."​, fc) #​ ^ in bracket = NOT operator; ex: NOT S 
re.findall(​r"(?P<area_code>\d\d\d)"​,​"706-791-5555"​)
​return​ findings.group(​"area_code"​)
# chars found matching what is in parenthesis is printed 
# anything outside of parenthesis is not printed
# left to right, will not use a char found again
# ex: if "s!" is found "! " will not be considered a find
```
