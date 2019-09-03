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

namespace EBreakTime.Core {
    public class Daemon : Gtk.Application {
        private static Daemon? instance = null;

        public static unowned Daemon get_instance () {
            if (instance == null) {
                instance = new Daemon ();
            }

            return instance;
        }

        private void on_bus_acquired (GLib.DBusConnection conn) {
            try {
                conn.register_object (Constants.DBUS_PATH, DBusService.get_default ());
            } catch (IOError e) {
                warning ("Error: %s\n", e.message);
                on_exit (1);
            }
        }

        public override void activate () {
            GLib.Bus.own_name (GLib.BusType.SESSION,
                               Constants.DBUS_NAME,
                               GLib.BusNameOwnerFlags.NONE,
                               on_bus_acquired,
                               () => {},
                               () => on_bus_not_aquired);
            hold ();
        }

        private void on_bus_not_aquired () {
            warning ("Could not aquire Session bus for ebreaktime.");
            on_exit (1);
        }

        public static void on_exit (int signum) {
            GLib.Application.get_default ().release ();
        }

        public static int main (string [] args) {
            GLib.Process.signal (GLib.ProcessSignal.INT, on_exit);
            GLib.Process.signal (GLib.ProcessSignal.TERM, on_exit);
            return Daemon.get_instance ().run (args);
        }
    }
}
