#!/usr/bin/env bash
# setup.sh <VNC_USER_PASSWORD> <VNC_PASSWORD>

set -euo pipefail

# Always cd back into the workspace in case PWD was invalidated
cd "${GITHUB_WORKSPACE:-$(pwd)}"

VNC_USER="akhil"
VNC_PASS="$2"

# disable Spotlight indexing
sudo mdutil -i off -a

# create new user
sudo dscl . -create /Users/"$VNC_USER"
sudo dscl . -create /Users/"$VNC_USER" UserShell /bin/bash
sudo dscl . -create /Users/"$VNC_USER" RealName "Akhil"
sudo dscl . -create /Users/"$VNC_USER" UniqueID 1001
sudo dscl . -create /Users/"$VNC_USER" PrimaryGroupID 80
sudo dscl . -create /Users/"$VNC_USER" NFSHomeDirectory /Users/"$VNC_USER"
sudo dscl . -passwd /Users/"$VNC_USER" "$1"
sudo createhomedir -c -u "$VNC_USER" > /dev/null

# enable VNC (Screen Sharing)
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes

# set VNC password
echo "$VNC_PASS" | perl -we 'BEGIN { @k=unpack "C*", pack "H*","1734516E8BA8C5E2FF1C39567390ADCA" }
  $_=<>;chomp;s/^(.{8}).*/$1/;@p=unpack"C*";foreach(@k){printf"%02X",$_^(shift@p||0)};print"\n"' \
  | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# restart the agent
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate
