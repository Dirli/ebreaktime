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
    [DBus (name = "io.elementary.EBreakTimeError")]
    public errordomain EBreakTimeError {
        COMMON_ERROR
    }

    [DBus (name = "io.elementary.EBreakTime")]
    public class DBusService : Object {
        public signal void changed_break (string new_val);
        public signal void changed_access (bool state);
        public signal void changed_manager_state (string name, bool state);

        private AccessManager access_manager;
        private BreakManager break_manager;
        private TimerManager timer_manager;
        private BreakWidget? break_widget = null;
        private EBreakTime.SettingsManager settings;

        private bool break_timer_state;
        private int timer_counter;

        private Gee.HashMap<string, AbstractManager> managers_map;

        private static DBusService? instance = null;
        public static DBusService get_default () {
            if (instance == null) {
                instance = new DBusService ();
            }

            return instance;
        }

        protected DBusService () {
            break_timer_state = false;
            settings = EBreakTime.SettingsManager.get_default ();
            settings.set_boolean ("autostart", checked_autostart ());

            managers_map = new Gee.HashMap<string, AbstractManager> ();

            timer_manager = TimerManager.get_default ();
            timer_manager.emit_time.connect (on_emit_time);

            timer_counter = 1;

            break_manager = new BreakManager (settings.get_int ("worktime"), settings.get_int ("breaktime"));
            break_manager.changed_count.connect (on_changed_count);
            break_manager.run_break.connect (on_run_break);
            if (settings.get_boolean ("break")) {
                add_manager (break_manager);
            }

            access_manager = new AccessManager ();
            access_manager.time_expired.connect (() => {
                managers_map.foreach ((entry) => {
                    if (entry.key != "access") {
                        managers_map.unset (entry.key);
                    }
                    return true;
                });

                on_run_break (false);
                changed_access (false);
            });

            init_settings_signals ();

            if (PAM.Token.get_pam_state ()) {
                add_manager (access_manager);
            }
        }

        private bool on_emit_time () {
            bool idle = false;
            if (!break_timer_state && timer_counter++ == 5) {
                if (Core.Utils.get_idle () > 600000) {
                    idle = true;
                }
                timer_counter = 1;
            }
            managers_map.foreach ((mng) => {
                if (!break_timer_state || mng.value.manager_name == "break") {
                    mng.value.timer_handler (idle);
                }
                return true;
            });

            return true;
        }

        public bool get_manager_state (string mng_name) throws GLib.DBusError, GLib.IOError {
            return managers_map.has_key (mng_name);
        }

        public bool expired_time_state () throws GLib.DBusError, GLib.IOError {
            return access_manager.time_expired_state ();
        }

        public void reload_access () throws GLib.DBusError, GLib.IOError {
            if (PAM.Token.get_pam_state ()) {
                add_manager (access_manager);
            } else {
                delete_manager ("access");
            }
        }

        public void break_manage (string? action = "") throws GLib.DBusError, GLib.IOError {
            switch (action) {
                case "run":
                    break_manager.force_break ();
                    break;
                case "reset":
                    break_manager.reset_timer ();
                    break;
                default:
                    if (settings.get_boolean ("break")) {
                        break_manager.emit_changed_count (1);
                    }
                    break;
            }
        }

        private void add_manager (AbstractManager manager) {
            delete_manager (manager.manager_name);

            if (manager.init ()) {
                managers_map[manager.manager_name] = manager;
                changed_manager_state (manager.manager_name, true);
                if (!timer_manager.get_state ()) {
                    timer_manager.start_timer ();
                }
            }
        }

        private void delete_manager (string mng_name) {
            if (managers_map.has_key (mng_name)) {
                managers_map.unset (mng_name);
                changed_manager_state (mng_name, false);
                if (managers_map.size == 0) {
                    timer_manager.stop_timer ();
                }
            }
        }

        private void init_settings_signals () {
            settings.changed["autostart"].connect (on_changed_autostart);
            settings.changed["worktime"].connect(() => {
                break_manager.work_time = settings.get_int ("worktime");
                break_manager.reset_timer ();
            });
            settings.changed["breaktime"].connect(() => {
                break_manager.break_time = settings.get_int ("breaktime");
            });
            settings.changed["break"].connect (() => {
                if (settings.get_boolean ("break")) {
                    add_manager (break_manager);
                } else {
                    delete_manager ("break");
                    changed_break ("Off");
                }
            });
        }

        private void on_changed_count (string new_val) {
            if (break_manager.timer_state == "break") {
                if (break_widget != null) {
                    break_widget.set_break_state (new_val);
                }
            } else {
                changed_break (new_val);
            }
        }

        private void on_run_break (bool run_break) {
            if (run_break) {
                break_timer_state = true;
                timer_manager.start_timer (1);

                if (break_widget == null) {
                    break_widget = new BreakWidget (settings.get_boolean ("postpone"));
                    break_widget.postpone_break.connect(() => {
                        break_manager.postpone_timer ();
                    });
                }
            } else {
                break_timer_state = false;
                timer_manager.start_timer ();
                timer_counter = 1;

                if (break_widget != null) {
                    break_widget.fade_out_and_remove ();
                }

                break_widget = null;
            }
        }

        private void on_changed_autostart () {
            var dest_path = GLib.Path.build_path (
                GLib.Path.DIR_SEPARATOR_S,
                Environment.get_user_config_dir (),
                "autostart",
                Constants.DAEMON_FILE_NAME
            );

            if (settings.get_boolean ("autostart")) {
                var desktop_file_path = new GLib.DesktopAppInfo ("io.elementary.ebreaktimed.desktop").filename;
                var desktop_file = GLib.File.new_for_path (desktop_file_path);

                var dest_file = GLib.File.new_for_path (dest_path);

                try {
                    desktop_file.copy (dest_file, FileCopyFlags.OVERWRITE);
                } catch (Error e) {
                    warning ("Error making copy of desktop file for autostart: %s", e.message);
                }
            } else {
                if (checked_autostart ()) {
                    GLib.FileUtils.remove (dest_path);
                }
            }
        }

        private bool checked_autostart () {
            var dest_path = Path.build_path (
                Path.DIR_SEPARATOR_S,
                Environment.get_user_config_dir (),
                "autostart",
                Constants.DAEMON_FILE_NAME
            );

            return GLib.FileUtils.test (dest_path, FileTest.IS_REGULAR);
        }
    }
}
