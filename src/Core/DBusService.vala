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

        private BreakManager break_manager;
        private TimerManager timer_manager;
        private BreakWidget? break_widget = null;
        private EBreakTime.SettingsManager settings;

        private static DBusService? instance = null;
        public static DBusService get_default () {
            if (instance == null) {
                instance = new DBusService ();
            }

            return instance;
        }

        protected DBusService () {
            settings = EBreakTime.SettingsManager.get_default ();
            settings.set_boolean ("autostart", checked_autostart ());

            timer_manager = TimerManager.get_default ();
            timer_manager.emit_time.connect (on_emit_time);

            break_manager = new BreakManager (settings.get_int ("worktime"), settings.get_int ("breaktime"));
            break_manager.changed_count.connect (on_changed_count);
            break_manager.run_break.connect (on_run_break);
            break_manager.bump_timer.connect ((interval) => {
                timer_manager.start_timer (interval);
            });

            init_settings_signals ();

            if (settings.get_boolean ("break")) {
                break_manager.init ();
            }
        }

        private bool on_emit_time () {
            break_manager.timer_handler ();
            return true;
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
                    break_manager.init ();
                } else {
                    timer_manager.start_timer (0);
                    // break_manager.stop_timer ();
                    changed_break ("Off");
                }
            });
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
                if (break_widget == null) {
                    break_widget = new BreakWidget (settings.get_boolean ("postpone"));
                    break_widget.postpone_break.connect(() => {
                        break_manager.postpone_timer ();
                    });
                }
            } else {
                if (break_widget != null) {
                    break_widget.fade_out_and_remove ();
                }

                break_widget = null;
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
