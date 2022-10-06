## How to Create a Minecraft Server

**Step 1.** 
```bash
sudo mkdir /minecraft
sudo yum install java
sudo wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
sudo vim /minecraft/start-server.sh
```

**Step 2.**
```bash
#!/bin/bash

java -Xmx1024M -Xms1024M -jar minecraft-server.jar nogui
```

**Step 3.**
```bash
sudo mkdir /etc/systemd/system/minecraft.target.wants/
sudo mkdir /etc/systemd/system/minecraft.target.wants/minecraft-server.service
```

**Step 4.**
```bash
[Unit]
Description = Minecraft Server
After = network.target

[Service]
ExecStart = /minecraft/start-server.sh
```

**Step 5.**
```
sudo systemctl enable /etc/systemd/system/minecraft.target.wants/minecraft-server.service
```

**Step 6.**
```
sudo systemctl start /etc/systemd/system/minecraft.target.wants/minecraft-server.service
```
