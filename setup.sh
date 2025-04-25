# setup.sh
# Install VNC server
brew install --cask vnc-server  # For macOS

# Set VNC password (replace 'yourpassword' with a secure value)
echo "yourpassword" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start VNC server on default port 5900
vncserver :0 -geometry 1920x1080 -depth 24
