#!/bin/bash

# Test Window Divisions extension in nested GNOME Shell
# This is the safe way to test without affecting your main session

echo "====================================================="
echo "Testing Window Divisions in Nested GNOME Shell"
echo "====================================================="
echo ""
echo "This will launch a nested GNOME Shell window where"
echo "you can safely test the extension."
echo ""
echo "Press Enter to continue..."
read

# Make sure the extension is installed
if [ ! -L "$HOME/.local/share/gnome-shell/extensions/windowdivisions@apposite.com.au" ]; then
    echo "Installing extension..."
    ln -sf "$(pwd)" "$HOME/.local/share/gnome-shell/extensions/windowdivisions@apposite.com.au"
fi

# Start log monitoring in a separate terminal
echo "Starting log monitor..."
gnome-terminal -- bash -c 'echo "Monitoring GNOME Shell logs..."; echo "Watch for windowdivisions errors:"; echo ""; journalctl -f /usr/bin/gnome-shell | grep -i --color=always -E "windowdivisions|error.*extension|exception|JS ERROR"' &

sleep 2

# Launch nested GNOME Shell
echo ""
echo "Launching nested GNOME Shell..."
echo "The nested shell will appear in a new window."
echo ""
echo "Inside the nested shell:"
echo "1. Press Alt+F2"
echo "2. Type: lg"
echo "3. Go to the Extensions tab"
echo "4. Enable 'Windows by divisions'"
echo "5. Or run in terminal: gnome-extensions enable windowdivisions@apposite.com.au"
echo ""
echo "Starting nested shell..."
sleep 2

# Run nested shell with DevKit (GNOME 49+)
dbus-run-session -- gnome-shell --devkit

echo ""
echo "Nested shell closed."
echo "Check the log monitor terminal for any errors."
