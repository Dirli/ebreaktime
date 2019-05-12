namespace EBreakTime.Core {
    public class Daemon : Gtk.Application {
        private static Daemon? instance = null;

        public static unowned Daemon get_instance () {
            if (instance == null) {
                instance = new Daemon ();
            }

            return instance;
        }

        private void on_bus_acquired (GLib.DBusConnection conn) {
            try {
                conn.register_object (Constants.DBUS_PATH, DBusService.get_default ());
            } catch (IOError e) {
                warning ("Error: %s\n", e.message);
                on_exit (1);
            }
        }

        public override void activate () {
            GLib.Bus.own_name (GLib.BusType.SESSION,
                               Constants.DBUS_NAME,
                               GLib.BusNameOwnerFlags.NONE,
                               on_bus_acquired,
                               () => {},
                               () => on_bus_not_aquired);
            hold ();
        }

        private void on_bus_not_aquired () {
            warning ("Could not aquire Session bus for ebreaktime.");
            on_exit (1);
        }

        public static void on_exit (int signum) {
            GLib.Application.get_default ().release ();
        }

        public static void main (string [] args) {
            GLib.Process.signal (GLib.ProcessSignal.INT, on_exit);
            GLib.Process.signal (GLib.ProcessSignal.TERM, on_exit);
            Daemon.get_instance ().run ();
        }
    }
}
