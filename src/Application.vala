namespace EBreakTime {
    public class EBreakTimeApp : Gtk.Application {
        public MainWindow window;

        public EBreakTimeApp () {
            application_id = "io.elementary.ebreaktime";
            flags |= GLib.ApplicationFlags.FLAGS_NONE;
        }

        public override void activate () {
            if (get_windows () == null) {
                window = new MainWindow (this);
                window.show_all ();
            } else {
                window.present ();
            }
        }

        public static void main (string [] args) {
            var app = new EBreakTimeApp ();
            app.run (args);
        }
    }
}
