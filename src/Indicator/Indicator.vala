/*
 * Copyright (c) 2019 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace EBreakTime {
    public class Indicator : Wingpanel.Indicator {
        private Widgets.Popover? main_widget = null;
        private Gtk.Box? panel_label = null;
        private SettingsManager settings;

        private EBreakTime? break_time = null;

        public Indicator () {
            Object (code_name : "ebreaktime-indicator",
                    display_name : "Elementary Break Time Indicator",
                    description: _("Manage time break from the panel."));

            settings = SettingsManager.get_default ();

            GLib.Bus.watch_name (
                GLib.BusType.SESSION,
                Constants.DBUS_NAME,
                GLib.BusNameWatcherFlags.NONE,
                () => {
                    on_changed_indicator ();
                },
                () => {
                    break_time = null;
                    visible = false;
                }
            );

            settings.changed["break"].connect (on_changed_indicator);
            settings.changed["indicator"].connect (on_changed_indicator);

            visible = false;
        }

        private void on_changed_indicator () {
            visible = settings.get_boolean ("indicator") && settings.get_boolean ("break");

            if (visible) {
                try {
                    break_time = GLib.Bus.get_proxy_sync (BusType.SESSION, Constants.DBUS_NAME, Constants.DBUS_PATH);
                    break_time.changed_break.connect (on_changed_break);
                    if (main_widget != null) {
                        break_time.break_manage ("");
                    }
                } catch (Error e) {
                    warning ("Error: %s\n", e.message);
                }
            } else {
                break_time = null;
            }
        }

        private void on_changed_break (string val) {
            if (visible && main_widget != null) {
                main_widget.update_state (val);
            }
        }

        public override Gtk.Widget get_display_widget () {
            if (panel_label == null) {
                panel_label = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
                var places_icon = new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
                panel_label.pack_start (places_icon);
            }

            return panel_label;
        }

        public override Gtk.Widget? get_widget () {
            if (main_widget == null) {
                main_widget = new Widgets.Popover ();
                main_widget.manage_timeout.connect ((state) => {
                    if (state == "run") {close ();}

                    try {
                        if (break_time != null) {
                            break_time.break_manage (state);
                        }
                    } catch (Error e) {
                        warning ("Error: %s\n", e.message);
                    }
                });
                main_widget.hide_button.clicked.connect (() => {
                    settings.set_boolean ("indicator", false);
                });

                try {
                    break_time.break_manage ("");
                } catch (Error e) {
                    warning ("Error: %s\n", e.message);
                }
            }

            return main_widget;
        }

        public override void opened () {}
        public override void closed () {}
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating EBreakTime Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    var indicator = new EBreakTime.Indicator ();
    return indicator;
}
