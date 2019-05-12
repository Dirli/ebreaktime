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
    public class MainWindow : Gtk.Window {
        private EBreakTime? break_time = null;

        public MainWindow (EBreakTimeApp app) {
            set_application (app);
            resizable = false;
            window_position = Gtk.WindowPosition.CENTER;
            margin = 10;

            var settings = SettingsManager.get_default ();

            Gtk.CssProvider provider = new Gtk.CssProvider();
            provider.load_from_resource ("/io/elementary/ebreaktime/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var header_bar = new Gtk.HeaderBar ();
            header_bar.set_title ("EBreakTime");
            header_bar.show_close_button = true;

            set_titlebar (header_bar);

            var settings_widget = new Widgets.Settings (settings);
            settings_widget.valign = Gtk.Align.CENTER;
            var break_widget = new Widgets.Break (settings);

            try {
                break_time = GLib.Bus.get_proxy_sync (GLib.BusType.SESSION, Constants.DBUS_NAME, Constants.DBUS_PATH);
                break_time.changed_break.connect ((val) => {
                    break_widget.update_state (val);
                });

                break_widget.manage_timeout.connect ((state) => {
                    try {
                        break_time.break_manage (state);
                    } catch (Error e) {
                        warning ("Error: %s\n", e.message);
                    }
                });

                break_time.break_manage ("");
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }

            var view_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view_box.margin = 10;
            view_box.pack_start (settings_widget, true, true, 0);
            view_box.pack_start (break_widget, true, true, 0);

            add (view_box);
        }
    }
}
