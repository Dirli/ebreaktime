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
    [DBus (name = "io.elementary.EBreakTime")]
    interface EBreakTime : Object {
        public abstract void break_manage (string? msg) throws GLib.DBusError, GLib.IOError;
        public abstract void reload_access () throws GLib.DBusError, GLib.IOError;
        public abstract bool expired_time_state () throws GLib.DBusError, GLib.IOError;
        public abstract bool get_manager_state (string mng_name) throws GLib.DBusError, GLib.IOError;
        public signal void changed_break (string new_val);
        public signal void changed_access (bool a_state);
        public signal void changed_manager_state (string name, bool state);
    }
}
