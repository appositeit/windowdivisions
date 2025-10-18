#!/bin/bash

# Safe installation script for Window Divisions extension
# This script provides backup and recovery options

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Extension details
EXTENSION_UUID="windowdivisions@apposite.com.au"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"
SOURCE_DIR="$(pwd)"
BACKUP_DIR="$HOME/.local/share/gnome-shell/extensions/.backup_$EXTENSION_UUID.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}Window Divisions Extension - Safe Installation${NC}"
echo "=============================================="

# Function to create emergency uninstall script
create_uninstall_script() {
    cat > "$HOME/emergency_uninstall_windowdivisions.sh" << 'EOF'
#!/bin/bash
# Emergency uninstall script for Window Divisions extension
# Run this if GNOME Shell fails to start after installing the extension

EXTENSION_UUID="windowdivisions@apposite.com.au"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

echo "Emergency uninstall of Window Divisions extension..."

if [ -L "$EXTENSION_DIR" ]; then
    rm "$EXTENSION_DIR"
    echo "✓ Symlink removed"
elif [ -d "$EXTENSION_DIR" ]; then
    rm -rf "$EXTENSION_DIR"
    echo "✓ Extension directory removed"
else
    echo "Extension not found"
fi

echo "Extension uninstalled. You should be able to log in now."
echo "You can delete this script after successful login."
EOF
    chmod +x "$HOME/emergency_uninstall_windowdivisions.sh"
    echo -e "${YELLOW}Created emergency uninstall script at:${NC}"
    echo -e "${BLUE}$HOME/emergency_uninstall_windowdivisions.sh${NC}"
    echo -e "${YELLOW}If GNOME Shell fails to start, run this script from TTY${NC}"
}

# Check if we're in the right directory
if [ ! -f "extension.js" ] || [ ! -f "metadata.json" ]; then
    echo -e "${RED}Error: Not in the extension directory${NC}"
    echo "Please run this script from the extension source directory"
    exit 1
fi

# Run tests first
echo -e "\n${YELLOW}Step 1: Running tests...${NC}"
if [ -f "bin/test_extension.sh" ]; then
    if ! ./bin/test_extension.sh > /dev/null 2>&1; then
        echo -e "${RED}✗ Tests failed. Please fix issues before installing.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${YELLOW}Warning: No test script found${NC}"
fi

# Check for existing installation
echo -e "\n${YELLOW}Step 2: Checking for existing installation...${NC}"
if [ -e "$EXTENSION_DIR" ]; then
    echo -e "${BLUE}Found existing installation${NC}"

    # Create backup
    echo -e "${YELLOW}Creating backup...${NC}"
    if [ -L "$EXTENSION_DIR" ]; then
        # It's a symlink
        TARGET=$(readlink "$EXTENSION_DIR")
        echo "  Backing up symlink pointing to: $TARGET"
        echo "$TARGET" > "$BACKUP_DIR.symlink"
        rm "$EXTENSION_DIR"
    else
        # It's a directory
        echo "  Backing up directory to: $BACKUP_DIR"
        mv "$EXTENSION_DIR" "$BACKUP_DIR"
    fi
    echo -e "${GREEN}✓ Backup created${NC}"
else
    echo -e "${GREEN}✓ No existing installation found${NC}"
fi

# Compile schemas
echo -e "\n${YELLOW}Step 3: Compiling schemas...${NC}"
glib-compile-schemas schemas/
echo -e "${GREEN}✓ Schemas compiled${NC}"

# Install extension
echo -e "\n${YELLOW}Step 4: Installing extension...${NC}"
ln -sf "$SOURCE_DIR" "$EXTENSION_DIR"
echo -e "${GREEN}✓ Extension installed (symlinked)${NC}"

# Create emergency uninstall script
echo -e "\n${YELLOW}Step 5: Creating emergency uninstall script...${NC}"
create_uninstall_script
echo -e "${GREEN}✓ Emergency script created${NC}"

# Final instructions
echo -e "\n${GREEN}=============================================="
echo -e "Installation Complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Log out and log back in"
echo "2. Enable the extension with:"
echo -e "   ${BLUE}gnome-extensions enable $EXTENSION_UUID${NC}"
echo "   Or use the GNOME Extensions app"
echo ""
echo -e "${YELLOW}Keyboard shortcuts:${NC}"
echo "  Super + C        - Center window"
echo "  Super + Shift + C - Rotate through divisions"
echo ""
echo -e "${YELLOW}If GNOME Shell fails to start:${NC}"
echo "1. Press Ctrl+Alt+F3 to switch to TTY3"
echo "2. Log in with your credentials"
echo "3. Run: ~/emergency_uninstall_windowdivisions.sh"
echo "4. Press Ctrl+Alt+F2 to return to login screen"
echo ""

# Ask if user wants to view the logs
echo -e "${YELLOW}Would you like to monitor GNOME Shell logs after logging in? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cat > "$HOME/monitor_windowdivisions.sh" << 'EOF'
#!/bin/bash
echo "Monitoring GNOME Shell for Window Divisions extension..."
echo "Press Ctrl+C to stop"
journalctl -f /usr/bin/gnome-shell | grep -i --color=always -E "windowdivisions|error|fail|extension"
EOF
    chmod +x "$HOME/monitor_windowdivisions.sh"
    echo -e "${GREEN}Created log monitoring script at:${NC}"
    echo -e "${BLUE}$HOME/monitor_windowdivisions.sh${NC}"
    echo "Run this after logging in to check for any issues"
fi

echo -e "\n${GREEN}✓ Installation completed successfully!${NC}"