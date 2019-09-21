[DBus (name = "org.freedesktop.login1.User")]
interface LogoutInterface : Object {
    public abstract void terminate () throws GLib.Error;
}

namespace EBreakTime {
    public class Core.AccessManager : Core.AbstractManager {
        public signal void time_expired ();

        private static LogoutInterface? logout_interface;

        private TimeInfo[] time_access;
        private int current_day;
        private int counter;
        private bool t_expired;

        public AccessManager () {
            try {
                logout_interface = Bus.get_proxy_sync (BusType.SYSTEM,
                                                       Constants.LOGIN1_DBUS_NAME,
                                                       Constants.LOGIN1_DBUS_PATH + "/user/self");
            } catch (Error e) {
                warning (e.message);
            }

            manager_name = "access";
            counter = 5;
            t_expired = false;
        }

        public bool time_expired_state () {
            return t_expired;
        }

        public override bool init () {
            var now_dt = new DateTime.now_local();
            current_day = now_dt.get_day_of_week ();
            var cur_year = now_dt.get_year ();
            var cur_month = now_dt.get_month ();
            var cur_day = now_dt.get_day_of_month ();
            var times_list = new Gee.HashMap<string, string> ();
            var token = PAM.Token.get_token_for_user (Posix.getlogin ());
            time_access = {};

            if (token != null) {
                times_list = token.get_times_info ();

                if (times_list.has_key ("Al")) {
                    time_access += parse_timeline (times_list["Al"], cur_year, cur_month, cur_day);
                }

                if (times_list.has_key (current_day > 5 ? "Wd" : "Wk")) {
                    time_access += parse_timeline (times_list[current_day > 5 ? "Wd" : "Wk"], cur_year, cur_month, cur_day);
                }

                string[] days_list = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"};
                if (times_list.has_key (days_list[current_day - 1])) {
                    time_access += parse_timeline (times_list[days_list[current_day - 1]], cur_year, cur_month, cur_day);
                }

                return time_access.length > 0;
            }

            return false;
        }

        private TimeInfo parse_timeline (string timeline, int year, int month, int day) {
            TimeInfo time_info = {};
            string[] bounds = timeline.split ("-");

            var from_date = new DateTime.local (year,
                                                month,
                                                day,
                                                int.parse (bounds[0].substring (0, 2)),
                                                int.parse (bounds[0].substring (2)),
                                                0);

            var to_date = new DateTime.local (year,
                                              month,
                                              day,
                                              int.parse (bounds[1].substring (0, 2)),
                                              int.parse (bounds[1].substring (2)),
                                              0);

            time_info.from = from_date.to_unix ();
            time_info.to = to_date.to_unix ();
            return time_info;
        }

        public override bool timer_handler (bool idle) {
            if (!t_expired) {
                var timer_dt = new DateTime.now_local();
                if (timer_dt.get_hour () == 23 && timer_dt.get_minute () == 59) {
                    return true;
                }

                if (current_day != timer_dt.get_day_of_week ()) {
                    current_day = timer_dt.get_day_of_week ();
                    if (!init ()) {
                        return false;
                    }
                }

                var timer_dt_unix = timer_dt.to_unix ();
                t_expired = true;
                foreach (TimeInfo times in time_access) {
                    if (timer_dt_unix > times.from && times.to > timer_dt_unix) {
                        t_expired = false;
                        break;
                    }
                }

                if (t_expired) {
                    Core.Utils.show_notify (_("Your time is up. The session will close in a few minutes. We recommend that you save and close open applications."),
                                            _("Time is over"));
                    time_expired ();
                }
            } else {
                if (counter-- == 0) {
                    try {
                        logout_interface.terminate ();
                    } catch (Error e) {
                        warning (e.message);
                    }
                }
            }

            return true;
        }
    }

    public struct TimeInfo {
        public int64 from;
        public int64 to;
    }
}
