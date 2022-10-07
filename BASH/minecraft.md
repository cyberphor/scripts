## How to Create a Minecraft Server

**Step 1.** 
```bash
sudo yum install java
sudo mkdir /minecraft
```
```
cd /minecraft
sudo wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
```

**Step 2.**
```
sudo vim start-server.sh
```
```bash
#!/bin/bash

java -Xmx1024M -Xms1024M -jar /minecraft/minecraft-server.jar nogui
```

**Step 3.**
```bash
sudo mkdir /etc/systemd/system/minecraft.target.wants/
```

**Step 4.**
```bash
sudo vim /etc/systemd/system/minecraft.target.wants/minecraft-server.service
```

```bash
[Unit]
Description = Minecraft Server
After = network.target

[Service]
WorkingDirectory = /minecraft/
ExecStart = /minecraft/start-server.sh

[Install]
WantedBy = multi-user.target
```

**Step 5.**
```
sudo systemctl enable /etc/systemd/system/minecraft.target.wants/minecraft-server.service
```

**Step 6.**
```
sudo systemctl start minecraft-server.service
sudo systemctl status minecraft-server.service
sudo journalctl -u minecraft-server
```
