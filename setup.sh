#!/bin/bash

# Disable spotlight indexing
sudo mdutil -i off -a

# Create new account
sudo dscl . -create /Users/vncuser
sudo dscl . -create /Users/vncuser UserShell /bin/bash
sudo dscl . -create /Users/vncuser RealName "VNC User"
sudo dscl . -create /Users/vncuser UniqueID 1001
sudo dscl . -create /Users/vncuser PrimaryGroupID 80
sudo dscl . -create /Users/vncuser NFSHomeDirectory /Users/vncuser
sudo dscl . -passwd /Users/vncuser $1
sudo dscl . -passwd /Users/vncuser $1
sudo createhomedir -c -u vncuser > /dev/null

# Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

# VNC password
echo $1 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# Enable Performance mode
sudo nvram boot-args="serverperfmode=1 $(nvram boot-args 2>/dev/null | cut -f 2-)"

# Reduce Motion and Transparency 
defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.universalaccess reduceMotion -int 1
defaults write com.apple.universalaccess reduceTransparency -int 1
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1

# Enable Multi-Session
sudo /usr/bin/defaults write .GlobalPreferences MultipleSessionsEnabled -bool TRUE

defaults write "Apple Global Domain" MultipleSessionsEnabled -bool true

# Disable Screen-Lock
defaults write com.apple.loginwindow DisableScreenLock -bool true

defaults write com.apple.loginwindow AllowList -string '*'

# Install zrok
brew install zrok

# Add zrok to PATH
export PATH="/usr/local/bin:$PATH"

# Configure zrok
zrok config set apiEndpoint https://api-v1.zrok.io

# Enable zrok with the provided token
zrok enable --headless --verbose $3

# Schedule shutdown after 6 hours
echo "Scheduling shutdown in 6 hours..."
sudo shutdown -h +360
