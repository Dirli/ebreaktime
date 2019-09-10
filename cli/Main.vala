namespace EBTHelper {
    private const GLib.OptionEntry[] options = {
		// --user
        { "user", 0, 0, OptionArg.STRING, ref user, "Username whose access will change", "STRING" },
        // --timeline
		{ "timeline", 't', 0, OptionArg.STRING, ref timeline, "New time limits for user", "STRING" },
		// --state
		{ "state", 0, 0, OptionArg.STRING, ref state, "Changes the state of the time module (on/off)", "STRING" },
		// list terminator
		{ null }
	};

    private static string? timeline = null;
    private static string? user = null;
    private static string? state = null;

    public static int main (string[] args) {
        try {
			var opt_context = new GLib.OptionContext (null);
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			print ("error: %s\n", e.message);
			print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return Posix.EXIT_FAILURE;
		}

        if (state != null) {
            switch_pam (state == "on" ? true : false);
            return Posix.EXIT_SUCCESS;
        }
        if (user != null) {
            set_token_for_user (user, timeline);
        }

        return Posix.EXIT_SUCCESS;
    }

    public static void switch_pam (bool pam_state) {
        string[] paths = {"/etc/pam.d/lightdm",  "/etc/pam.d/login"};

        foreach (var path in paths) {
            string contents;
            try {
                FileUtils.get_contents (path, out contents);
                string conf_line = "\naccount required pam_time.so";
                if (pam_state && conf_line in contents) {
                    return;
                }
                if (!pam_state && !(conf_line in contents)) {
                    return;
                }

                string new_content = "";
                if (pam_state) {
                    new_content = contents;
                    new_content += conf_line;
                } else {
                    foreach (var str in contents.split ("\n")) {
                        if (str == "" || str == "account required pam_time.so") {continue;}
                        new_content += str;
                        new_content += "\n";
                    }
                }

                FileUtils.set_contents (path, new_content);
            } catch (FileError e) {
                warning (e.message);
                return;
            }
        }
    }

    private static void set_token_for_user (string username, string? new_restrictions) {
        string contents;
        string new_content = "";
        try {
            FileUtils.get_contents (Constants.PAM_TIME_CONF_PATH, out contents);

            bool first_record = false;
            string new_restrictions_str = "";
            if (new_restrictions != null) {
                first_record = (contents.index_of (Constants.PAM_CONF_START) == -1);
                new_restrictions_str = "*;*;%s;%s".printf (username, new_restrictions);
            }

            if (first_record) {
                new_content = contents;
                new_content += Constants.PAM_CONF_START + "\n";
                new_content += new_restrictions_str + "\n";
                new_content += Constants.PAM_CONF_END;
            } else {
                bool parse = false;

                foreach (var str in contents.split ("\n")) {
                    if (str == "") {continue;}

                    if (str == Constants.PAM_CONF_END) {
                        if (new_restrictions != null) {
                            new_content += new_restrictions_str;
                            new_content += "\n";
                        }
                        parse = false;
                    }

                    if (parse) {
                        var token = EBreakTime.PAM.Token.parse_line (str);
                        if (token != null && token.get_user_arg0 () == username) {
                            continue;
                        }
                    }
                    if (str == Constants.PAM_CONF_START) {parse = true;}

                    new_content += str;
                    new_content += "\n";
                }
            }

            FileUtils.set_contents (Constants.PAM_TIME_CONF_PATH, "%s".printf (new_content));
        } catch (FileError e) {
            warning (e.message);
            return;
        }
    }
}
