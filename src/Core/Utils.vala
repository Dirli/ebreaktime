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
    public class Utils {
        public static void show_notify (string body, string? summary = null) {
#if NOTIFY_ENABLE
            if (summary == null) {
                summary = _("Time break");
            }
            string icon = "tools-timer-symbolic";

            Notify.init ("EBreakTime");

            try {
                Notify.Notification notification = new Notify.Notification (summary, body, icon);
                notification.show ();
            } catch (Error e) {
                warning ("Error: %s", e.message);
            }
#endif
        }

        public static ulong get_idle () {
            unowned X.Display x_display = Gdk.X11.get_default_xdisplay ();
            var scrsaver = XScreenSaver.query_info (x_display, x_display.default_root_window ());

            return scrsaver.idle;
        }
    }
}
