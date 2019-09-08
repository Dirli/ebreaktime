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

namespace Constants {
    public const string DBUS_NAME = "io.elementary.EBreakTime";
    public const string DBUS_PATH = "/io/elementary/ebreaktime";
    public const string LOGIN1_DBUS_NAME = "org.freedesktop.login1";
    public const string LOGIN1_DBUS_PATH = "/org/freedesktop/login1";
    public const string DAEMON_FILE_NAME = "io.elementary.ebreaktimed.desktop";
    public const string DESKTOP_FILE_NAME = "io.elementary.ebreaktime.desktop";
    public const string PAM_TIME_CONF_PATH = "/etc/security/time.conf";
    public const string PAM_CONF_START = "## BREAK_TIME_START";
    public const string PAM_CONF_END = "## BREAK_TIME_END";
}
