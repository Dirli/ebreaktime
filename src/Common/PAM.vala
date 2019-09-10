namespace EBreakTime.PAM {
    public enum DayType {
        ALL,
        WEEKDAY,
        WEEKEND,
        MONDAY,
        TUESDAY,
        WEDNESDAY,
        THURSDAY,
        FRIDAY,
        SATURDAY,
        SUNDAY;

        public static DayType[] get_days () {
            return { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY };
        }

        public static DayType to_enum (string str) {
            switch (str) {
                case "Al":
                    return ALL;
                case "Wk":
                    return WEEKDAY;
                case "Wd":
                    return WEEKEND;
                case "Mo":
                    return MONDAY;
                case "Tu":
                    return TUESDAY;
                case "We":
                    return WEDNESDAY;
                case "Th":
                    return THURSDAY;
                case "Fr":
                    return FRIDAY;
                case "Sa":
                    return SATURDAY;
                case "Su":
                    return SUNDAY;
                default:
                    return ALL;
            }
        }

        public string to_string () {
            switch (this) {
                case ALL:
                    return "Al";
                case WEEKDAY:
                    return "Wk";
                case WEEKEND:
                    return "Wd";
                case MONDAY:
                    return "Mo";
                case TUESDAY:
                    return "Tu";
                case WEDNESDAY:
                    return "We";
                case THURSDAY:
                    return "Th";
                case FRIDAY:
                    return "Fr";
                case SATURDAY:
                    return "Sa";
                case SUNDAY:
                    return "Su";
                default:
                    return "unknown";
            }
        }
    }

    public class Token : Object {
        private const int SERVICES_INDEX = 0;
        private const int TTYS_INDEX = 1;
        private const int USERS_INDEX = 2;
        private const int TIMES_INDEX = 3;

        private const string TYPE_SEPARATOR = ";";

        public string[] services;
        public string[] ttys;
        public string[] users;
        public string[] times;

        public static bool get_pam_state () {
            string[] paths = {"/etc/pam.d/lightdm",  "/etc/pam.d/login"};

            foreach (var path in paths) {
                string contents;
                try {
                    FileUtils.get_contents (path, out contents);
                    string conf_line = "\naccount required pam_time.so";
                    if (!(conf_line in contents)) {return false;}
                } catch (FileError e) {
                    warning (e.message);
                    return false;
                }
            }

            return true;
        }

        public static Token? get_token_for_user (string username) {
            GLib.File file = GLib.File.new_for_path (Constants.PAM_TIME_CONF_PATH);
            if (file.query_exists ()) {
                try {
                    GLib.DataInputStream dis = new GLib.DataInputStream (file.read ());
                    string line;

                    bool parse = false;

                    while ((line = dis.read_line ()) != null) {
                        if (line == Constants.PAM_CONF_END) {parse = false;}

                        if (parse) {
                            var token = parse_line (line);
                            if (token != null && token.get_user_arg0 () == username) {
                                return token;
                            }
                        }

                        if (line == Constants.PAM_CONF_START) {parse = true;}
                    }

                } catch (Error e) {
                    warning (e.message);
                }
            }

            return null;
        }

        public string get_user_arg0 () {
            return users.length == 0 ? "" : users[0];
        }

        public Gee.HashMap<string, string> get_times_info () {
            var times_list = new Gee.HashMap<string, string> ();

            if (times.length == 0) {return times_list;}

            foreach (string time in times) {
                string bounds = time.substring (2);
                if (bounds.split ("-").length < 2) {continue;}
                times_list[time.slice (0, 2)] = bounds;
            }

            return times_list;
        }

        public static Token? parse_line (string line) {
            if (line.has_prefix ("#")) {
                return null;
            }

            string[] strv = line.split (TYPE_SEPARATOR);
            if (strv.length != 4) {
                return null;
            }

            var token = new Token ();
            token.services = strv[SERVICES_INDEX].split (Constants.LIST_SEPARATOR);
            token.ttys = strv[TTYS_INDEX].split (Constants.LIST_SEPARATOR);
            token.users = strv[USERS_INDEX].split (Constants.LIST_SEPARATOR);
            token.times = strv[TIMES_INDEX].split (Constants.LIST_SEPARATOR);

            return token;
        }
    }

    public struct TimeInfo {
        public DayType day_type;
        public string from;
        public string to;
    }
}
