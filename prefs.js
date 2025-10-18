'use strict';

import Gtk from 'gi://Gtk?version=4.0';
import Adw from 'gi://Adw?version=1';
import GObject from 'gi://GObject';
import {ExtensionPreferences} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

const COLUMN_KEY = 0;
const COLUMN_MODS = 1;

const KEYBOARD_SHORTCUTS = [
    {id: 'center-shortcut', desc: 'Center window'},
    {id: 'rotate-shortcut', desc: 'Rotate window position'},
    {id: 'slot-1-shortcut', desc: 'Move to slot 1'},
    {id: 'slot-2-shortcut', desc: 'Move to slot 2'},
    {id: 'slot-3-shortcut', desc: 'Move to slot 3'},
    {id: 'slot-4-shortcut', desc: 'Move to slot 4'},
    {id: 'slot-5-shortcut', desc: 'Move to slot 5'},
    {id: 'slot-6-shortcut', desc: 'Move to slot 6'},
    {id: 'slot-7-shortcut', desc: 'Move to slot 7'},
    {id: 'slot-8-shortcut', desc: 'Move to slot 8'},
    {id: 'slot-9-shortcut', desc: 'Move to slot 9'},
];

export default class WindowDivisionsPreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        window.set_default_size(600, 400);

        const page = new Adw.PreferencesPage();
        window.add(page);

        // Grid adjustment group
        const gridGroup = new Adw.PreferencesGroup({
            title: 'Grid Adjustment',
        });
        page.add(gridGroup);

        // Divisions row
        const divisionsRow = new Adw.SpinRow({
            title: 'Number of Divisions',
            subtitle: 'How many sections to divide the window into',
            adjustment: new Gtk.Adjustment({
                lower: 1,
                upper: 10,
                step_increment: 1,
                value: this.getSettings().get_int('divisions'),
            }),
        });

        divisionsRow.connect('notify::value', (widget) => {
            this.getSettings().set_int('divisions', widget.get_value());
        });

        gridGroup.add(divisionsRow);

        // Keyboard shortcuts group
        const shortcutsGroup = new Adw.PreferencesGroup({
            title: 'Keyboard Shortcuts',
        });
        page.add(shortcutsGroup);

        // Create shortcut rows
        KEYBOARD_SHORTCUTS.forEach((shortcut) => {
            const row = this.createShortcutRow(shortcut);
            shortcutsGroup.add(row);
        });
    }

    createShortcutRow(shortcut) {
        const settings = this.getSettings();
        const currentShortcut = settings.get_strv(shortcut.id)[0] || '';

        const row = new Adw.ActionRow({
            title: shortcut.desc,
        });

        const shortcutLabel = new Gtk.ShortcutLabel({
            disabled_text: 'Disabled',
            accelerator: currentShortcut,
            valign: Gtk.Align.CENTER,
        });

        const button = new Gtk.Button({
            label: 'Set',
            valign: Gtk.Align.CENTER,
        });

        button.connect('clicked', () => {
            const dialog = new Gtk.Dialog({
                title: `Set shortcut for: ${shortcut.desc}`,
                transient_for: row.get_root(),
                modal: true,
            });

            dialog.add_button('Cancel', Gtk.ResponseType.CANCEL);
            dialog.add_button('Clear', Gtk.ResponseType.REJECT);
            dialog.add_button('Set', Gtk.ResponseType.ACCEPT);

            const content = dialog.get_content_area();
            const label = new Gtk.Label({
                label: 'Press the key combination',
                margin_top: 20,
                margin_bottom: 20,
                margin_start: 20,
                margin_end: 20,
            });
            content.append(label);

            let capturedKey = null;
            let capturedMods = null;

            const eventController = new Gtk.EventControllerKey();
            eventController.connect('key-pressed', (controller, keyval, keycode, state) => {
                capturedKey = keyval;
                capturedMods = state;
                const accel = Gtk.accelerator_name(keyval, state);
                label.set_text(`Captured: ${accel}`);
                return true;
            });
            dialog.add_controller(eventController);

            dialog.connect('response', (dialog, response) => {
                if (response === Gtk.ResponseType.ACCEPT && capturedKey) {
                    const accel = Gtk.accelerator_name(capturedKey, capturedMods);
                    settings.set_strv(shortcut.id, [accel]);
                    shortcutLabel.set_accelerator(accel);
                } else if (response === Gtk.ResponseType.REJECT) {
                    settings.set_strv(shortcut.id, []);
                    shortcutLabel.set_accelerator('');
                }
                dialog.destroy();
            });

            dialog.present();
        });

        row.add_suffix(shortcutLabel);
        row.add_suffix(button);

        return row;
    }
}