#!/bin/bash

# Quick update script for Window Divisions extension
# Restarts GNOME Shell to apply changes

echo "====================================================="
echo "Updating Window Divisions Extension"
echo "====================================================="
echo ""
echo "This will restart GNOME Shell to apply the changes."
echo "Your session will stay active but the screen will flicker."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Compile schemas
echo ""
echo "Compiling schemas..."
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"
glib-compile-schemas schemas/

# Restart GNOME Shell
echo ""
echo "Restarting GNOME Shell..."
busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Updating extension...")' 2>&1

echo ""
echo "Extension updated!"
echo ""
echo "New keyboard shortcuts available:"
echo "  Super + C             - Center window"
echo "  Super + Shift + C     - Rotate through divisions"
echo "  Alt + Super + 1-9     - Jump to slot 1-9"
echo ""
echo "Note: Alt + Super + 8 is disabled by default (conflicts with magnifier)"