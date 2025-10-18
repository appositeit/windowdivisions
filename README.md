# Window Divisions

When you tile a window and it fills half your screen on your ultrawide monitor
does that seem just a bit annoying? Fear not, this extension lets you define
how many "divisions" you want on the screen, then shift your window across
the divisions. So if you set the divisions to 3, then on the first shortcut
press, your window will fill the leftmost third of the screen. On the second
it will fill the middle third, and on the next key press it will fill the
rightmost third of the screen.

But wait! There's more! If you have two monitors it will continue to cycle
across the next monitor going on to the left most third of the second monitor
and so on. Magic!

It's stupid, but it works!

## Features

- **Grid-based window positioning**: Divides each monitor into equal sections (default: 3)
- **Keyboard-driven**: Quick keyboard shortcuts for window positioning
- **Direct slot selection**: Jump to any slot instantly with Alt+Super+Number
- **Multi-monitor support**: Works seamlessly across multiple monitors
- **Configurable divisions**: Adjust the number of divisions per monitor

## Compatibility

Compatible with GNOME Shell versions:
- 3.34, 3.36, 3.38
- 40, 41, 42, 43, 44
- **45, 46, 47, 48, 49** (ES6 module support)

Tested and working on:
- Ubuntu 25.10 (GNOME Shell 49)

## Keyboard Shortcuts

### Basic Controls
- **`Super + C`** - Center window (move to middle division of current monitor)
- **`Super + Shift + C`** - Rotate window through all divisions

### Direct Slot Selection
- **`Alt + Super + 1-9`** - Jump directly to slot 1-9

For example, with 3 divisions and 2 monitors:
- `Alt + Super + 1` - Left third of first monitor
- `Alt + Super + 2` - Middle third of first monitor
- `Alt + Super + 3` - Right third of first monitor
- `Alt + Super + 4` - Left third of second monitor
- `Alt + Super + 5` - Middle third of second monitor
- `Alt + Super + 6` - Right third of second monitor

Note: `Alt + Super + 8` is disabled by default as it conflicts with the GNOME magnifier shortcut.

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/appositeit/windowdivisions.git
   cd windowdivisions
   ```

2. Run the safe installation script:
   ```bash
   ./bin/safe_install.sh
   ```

   Or install manually:
   ```bash
   # Compile the GSchema files
   glib-compile-schemas schemas/

   # Create symlink to extensions directory
   ln -sf $(pwd) ~/.local/share/gnome-shell/extensions/windowdivisions@apposite.com.au
   ```

3. **Log out and log back in** (required for GNOME Shell to detect the extension)

4. Enable the extension:
   ```bash
   gnome-extensions enable windowdivisions@apposite.com.au
   ```

   Or use the GNOME Extensions application GUI.

## Configuration

You can configure the extension through the GNOME Extensions app preferences:

- **Divisions**: Number of sections to divide each monitor into (default: 3)
- **Keyboard shortcuts**: Customize the keyboard shortcuts

## Development

### Testing

Run the test script to validate the extension:
```bash
./bin/test_extension.sh
```

### Project Structure

- `extension.js` - Main extension logic (ES6 modules for GNOME 45+)
- `prefs.js` - Preferences dialog (GTK4/Adwaita for GNOME 45+)
- `metadata.json` - Extension metadata
- `schemas/` - GSettings schema definitions
- `bin/` - Utility scripts for testing and installation

## Repository

GitHub: [https://github.com/appositeit/windowdivisions](https://github.com/appositeit/windowdivisions)

## License

GNU General Public License v3.0

## Author

Apposite IT