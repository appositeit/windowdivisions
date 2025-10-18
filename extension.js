'use strict';

import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension, gettext as _} from 'resource:///org/gnome/shell/extensions/extension.js';

export default class WindowDivisionsExtension extends Extension {
    getActiveWindow() {
        return global.workspace_manager
        .get_active_workspace()
        .list_windows()
        .find(window => window.has_focus());
    }

    enable() {
        this._window = null;
        this._previous = null;
        this._settings = this.getSettings();
        this.bindKey('center-shortcut', () => this.moveCenter());
        this.bindKey('rotate-shortcut', () => this.moveAround());

        // Bind number keys for direct slot selection
        for (let i = 1; i <= 9; i++) {
            this.bindKey(`slot-${i}-shortcut`, () => this.moveToSlot(i - 1));
        }
    }

    disable() {
        this.unbindKey('center-shortcut');
        this.unbindKey('rotate-shortcut');

        // Unbind slot shortcuts
        for (let i = 1; i <= 9; i++) {
            this.unbindKey(`slot-${i}-shortcut`);
        }

        this._settings = null;
        this._window = null;
        this._previous = null;
    }

    moveCenter() {
        const activeWindow = this.getActiveWindow();
        if (!activeWindow) return;

        const monitor = activeWindow.get_monitor();
        const divisions = this._settings.get_int('divisions');
        // Move to center of current monitor
        this.moveToSlot(monitor * divisions + Math.floor(divisions / 2));
    }

    moveAround() {
        log("moveAround called")
        const divisions = this._settings.get_int('divisions');
        const nMonitors = global.display.get_n_monitors();
        const totalSlots = nMonitors * divisions;
        log(`divisions: ${divisions}, monitors: ${nMonitors}, totalSlots: ${totalSlots}`);

        let pos = null;
        if (this._previous === null) {
            pos = 0;
        } else {
            pos = this._previous + 1;
            if (pos >= totalSlots) {
                pos = 0;
            }
        }
        this.moveToSlot(pos);
    }

    moveToSlot(slot) {
        log(`moveToSlot(${slot}) called`);
        const activeWindow = this.getActiveWindow();
        if (!activeWindow) {
            log('No active window');
            return;
        }

        const divisions = this._settings.get_int('divisions');
        const nMonitors = global.display.get_n_monitors();
        const totalSlots = nMonitors * divisions;

        // Validate slot
        if (slot < 0 || slot >= totalSlots) {
            log(`Invalid slot ${slot} (max: ${totalSlots - 1})`);
            return;
        }

        // Calculate which monitor and position within that monitor
        const targetMonitor = Math.floor(slot / divisions);
        const positionInMonitor = slot % divisions;

        log(`Slot ${slot} -> Monitor ${targetMonitor}, Position ${positionInMonitor}`);

        this.moveByMode(slot);
    }

    moveByMode(pos) {
        log(`moveByMode(${pos}) called`);
        const activeWindow = this.getActiveWindow();
        if (!activeWindow) {
            log('No active window');
            return;
        }

        const divisions = this._settings.get_int('divisions');
        const nMonitors = global.display.get_n_monitors();

        // Calculate which monitor and position within that monitor
        const targetMonitor = Math.floor(pos / divisions);
        const positionInMonitor = pos % divisions;

        // Validate monitor index
        if (targetMonitor >= nMonitors) {
            log(`Invalid monitor ${targetMonitor} (max: ${nMonitors - 1})`);
            return;
        }

        const workarea = this.getWorkAreaForMonitor(targetMonitor);

        log(`Monitor ${targetMonitor}: divisions: ${divisions}, position: ${positionInMonitor}`);

        const sectionWidth = workarea.width / divisions;
        const x = workarea.x + (positionInMonitor * sectionWidth);
        const y = workarea.y;
        const width = sectionWidth;
        const height = workarea.height;

        log(`Moving to x:${x}, y:${y}, width:${width}, height:${height}`);

        this.moveWindow(activeWindow, {
            x: Math.floor(x),
            y: Math.floor(y),
            width: Math.floor(width),
            height: Math.floor(height),
        });
        this._previous = pos;
    }

    moveWindow(window, area) {
        if (!window)
            return;

        if (window.maximized_horizontally || window.maximized_vertically) {
            window.unmaximize(
                Meta.MaximizeFlags.HORIZONTAL | Meta.MaximizeFlags.VERTICAL
            );
        }
        window.move_resize_frame(true, area.x, area.y, area.width, area.height);
        // In some cases move_resize_frame() will resize but not move the window, so we need to move it again.
        // This usually happens when the window's minimum size is larger than the selected area.
        window.move_frame(true, area.x, area.y);
    }

    getWorkAreaForMonitor(monitor) {
        return global.workspace_manager
      .get_active_workspace()
      .get_work_area_for_monitor(monitor);
    }

    bindKey(key, callback) {
        Main.wm.addKeybinding(
            key,
            this._settings,
            Meta.KeyBindingFlags.IGNORE_AUTOREPEAT,
            Shell.ActionMode.NORMAL,
            callback
        );
    }

    unbindKey(key) {
        Main.wm.removeKeybinding(key);
    }
}