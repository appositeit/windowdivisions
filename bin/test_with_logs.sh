#!/bin/bash

# Test Window Divisions extension with live log monitoring
# Uses busctl to restart GNOME Shell in-place (safer than full logout)

echo "====================================================="
echo "Testing Window Divisions Extension"
echo "====================================================="
echo ""
echo "This will:"
echo "1. Start monitoring GNOME Shell logs"
echo "2. Enable the extension"
echo "3. Show any errors that occur"
echo ""
echo "⚠️  WARNING: This will restart your GNOME Shell!"
echo "Your session will stay active but the screen will flicker."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Ensure extension is installed
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/windowdivisions@apposite.com.au"
if [ ! -L "$EXTENSION_DIR" ]; then
    echo "Installing extension symlink..."
    ln -sf "$(dirname "$(dirname "$(readlink -f "$0")")")" "$EXTENSION_DIR"
fi

echo ""
echo "Starting log monitor..."
echo "Logs will appear below. Watch for ERRORS or EXCEPTIONS."
echo "====================================================="
echo ""

# Function to monitor logs
monitor_logs() {
    journalctl -f /usr/bin/gnome-shell 2>&1 | grep -i --line-buffered -E "windowdivisions|JS ERROR|exception|Extension.*error" &
    LOG_PID=$!
}

# Start monitoring
monitor_logs

sleep 2

# Enable the extension
echo ""
echo "Enabling extension..."
gnome-extensions enable windowdivisions@apposite.com.au 2>&1

sleep 1

# Restart GNOME Shell to load the extension
echo ""
echo "Restarting GNOME Shell (screen will flicker briefly)..."
busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Testing extension...")' 2>&1

sleep 3

# Check extension status
echo ""
echo "====================================================="
echo "Extension Status:"
gnome-extensions info windowdivisions@apposite.com.au 2>&1

echo ""
echo "====================================================="
echo "Monitoring logs (press Ctrl+C to stop)..."
echo "Try using the keyboard shortcuts:"
echo "  Super + C        - Center window"
echo "  Super + Shift + C - Rotate through divisions"
echo ""

# Continue monitoring
wait $LOG_PID
