namespace EBreakTime.Utils {
    private static Polkit.Permission? permission = null;

    public static Polkit.Permission? get_permission () {
        if (permission != null) {
            return permission;
        }

        try {
            permission = new Polkit.Permission.sync ("io.elementary.breaktime.administration", new Polkit.UnixProcess (Posix.getpid ()));
            return permission;
        } catch (Error e) {
            critical (e.message);
            return null;
        }
    }

    public static void run_cli (string options) {
        if (get_permission ().allowed) {
            string stdout;
            string stderr;
            int status;

            try {
                Process.spawn_command_line_sync (
                    "pkexec io.elementary.ebreaktime-cli " + options,
                    out stdout,
                    out stderr,
                    out status);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}
