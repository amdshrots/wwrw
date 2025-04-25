#!/bin/bash

# Install TigerVNC (includes vncserver and vncpasswd)
brew install vnc  # [[8]]

# Set VNC password
echo "password" | vncpasswd -f > ~/.vnc/passwd  # [[8]]
chmod 600 ~/.vnc/passwd

# Start VNC server on display :1
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no  # [[8]]

# Setup Playit.gg tunnel
curl -sSL https://raw.githubusercontent.com/aBoredDev/playit-setup-script/main/install.sh | bash  # [[3]]
playit --secret $PLAYIT_SECRET tcp://localhost:5901  # [[3]]
