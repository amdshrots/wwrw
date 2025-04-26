# setup.sh VNC_USER_PASSWORD VNC_PASSWORD ZROK_TOKEN

# Disable spotlight indexing
sudo mdutil -i off -a

# Create new account
sudo dscl . -create /Users/akhil
sudo dscl . -create /Users/akhil UserShell /bin/bash
sudo dscl . -create /Users/akhil RealName "Akhil"
sudo dscl . -create /Users/akhil UniqueID 1001
sudo dscl . -create /Users/akhil PrimaryGroupID 80
sudo dscl . -create /Users/akhil NFSHomeDirectory /Users/vncuser
sudo dscl . -passwd /Users/akhil $1
sudo createhomedir -c -u akhil > /dev/null

# Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

# Set VNC password
echo $2 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Restart VNC service
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# Performance optimizations
sudo nvram boot-args="serverperfmode=1 $(nvram boot-args 2>/dev/null | cut -f 2-)"
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.universalaccess reduceMotion -int 1
defaults write com.apple.universalaccess reduceTransparency -int 1

# Enable multi-session
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionsEnabled -bool YES

# Disable screen lock
defaults write com.apple.loginwindow DisableScreenLock -bool YES

brew install zrok
brew install --cask brave-browser
brew install --cask chrome-remote-desktop-host

zrok --help
zrok enable $3
zrok start vnc localhost:5900 --name my-vnc-tunnel
SHARE_TOKEN=$(zrok ls | grep my-vnc-tunnel | awk '{print $3}')
echo "SHARE_TOKEN=$SHARE_TOKEN" >> $GITHUB_ENV
zrok access private $SHARE_TOKEN
VNC_ENDPOINT=$(zrok access private $SHARE_TOKEN | grep -oP 'https://\K[^ ]+')
echo "VNC endpoint: $VNC_ENDPOINT"
echo "VNC_ENDPOINT=$VNC_ENDPOINT" >> $GITHUB_ENV
