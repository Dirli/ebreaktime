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
    [DBus (name = "org.freedesktop.login1.Manager")]
    interface ILogindManager : DBusProxy {
        public abstract signal void prepare_for_sleep (bool start);
    }

    public class Core.BreakManager : Object {
        private int interval;
        private int counter;
        private int postpone;

        public signal void changed_count (string cur_val);
        public signal void run_break (bool break_state);

        private bool postpone_flag = false;
        private bool check_idle;

        private int _break_time;
        public int break_time {
            get {return _break_time;}
            set {_break_time = value;}
        }

        private int _work_time;
        public int work_time {
            get {return _work_time;}
            set {_work_time = value;}
        }

        private string _timer_state;
        public string timer_state {
            get {return _timer_state;}
            set {
                _timer_state = value;
                start_timer ();
            }
        }

        private uint source_id;
        private ILogindManager? logind_manager;

        public BreakManager (int work_time, int break_time) {
            postpone = 3;
            interval = 60;

            this.work_time = counter = work_time;
            this.break_time = break_time;

            check_idle = FileUtils.test("/usr/bin/xprintidle", FileTest.IS_EXECUTABLE);

            try {
                logind_manager = GLib.Bus.get_proxy_sync (BusType.SYSTEM,
                                                          Constants.LOGIN1_DBUS_NAME,
                                                          Constants.LOGIN1_DBUS_PATH);
                if (logind_manager != null) {
                    logind_manager.prepare_for_sleep.connect((start) => {
                        if (!start) {
                            if (timer_state == "break") {
                                run_break (false);
                            }

                            timer_state = "work";
                        }
                    });
                }
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }
        }

        public void init () {
            timer_state = "work";
        }

        private void start_timer () {
            stop_timer ();
            interval = 60;

            if (timer_state == "break") {
                interval = 1;
                counter = 60 * break_time;
            } else {
                counter = postpone_flag ? postpone : work_time;
                postpone_flag = false;
            }

            if (counter < 1) {return;}

            timer_handler ();
            source_id = GLib.Timeout.add_seconds (interval, timer_handler);
        }

        public void stop_timer () {
            counter = this.work_time;
            if (source_id > 0) {
                GLib.Source.remove(source_id);
            }
        }

        private void emit_break_signal () {
            bool run_break_state = timer_state == "break" ? false : true;
            run_break (run_break_state);
        }

        private bool timer_handler () {
            if (counter == 0) {
                emit_break_signal ();
                timer_state = timer_state == "break" ? "work" : "break";
                return false;
            }

            if (counter == 5 && timer_state == "work") {
                EBreakTime.Utils.show_notify (_("5 minutes before the break"));
            }

            emit_changed_count ();
            --counter;

            if (check_idle && counter % 5 == 0 && timer_state == "work") {
                string ls_stdout;

                try {
                    GLib.Process.spawn_command_line_sync ("xprintidle", out ls_stdout, null, null);

                    if (int.parse(ls_stdout) > 600000) {
                        timer_state = "work";
                    }

                } catch (SpawnError e) {
                    warning ("Error: %s\n", e.message);
                }
            }

            return true;
        }

        public void emit_changed_count (int? inc = 0) {
            if (timer_state == "break") {
                int min = counter / 60;
                int sec = counter % 60;
                changed_count ("%d:%2.2d".printf (min, sec));
            } else {
                changed_count ("%d ".printf (counter + inc) + _("min"));
            }
        }

        public void postpone_timer () {
            if (timer_state == "break") {
                postpone_flag = true;
                emit_break_signal ();
                timer_state = "work";
            }
        }

        public void reset_timer () {
            if (timer_state != "break") {
                timer_state = "work";
            }
        }

        public void force_break () {
            if (timer_state != "break") {
                emit_break_signal ();
                timer_state = "break";
            }
        }
    }
}
