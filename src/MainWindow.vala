namespace EBreakTime {
    public class MainWindow : Gtk.Window {
        private EBreakTime? break_time = null;

        public MainWindow (EBreakTimeApp app) {
            set_application (app);
            resizable = false;
            window_position = Gtk.WindowPosition.CENTER;
            margin = 10;

            var settings = SettingsManager.get_default ();

            Gtk.CssProvider provider = new Gtk.CssProvider();
            provider.load_from_resource ("/io/elementary/ebreaktime/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var header_bar = new Gtk.HeaderBar ();
            header_bar.set_title ("EBreakTime");
            header_bar.show_close_button = true;

            set_titlebar (header_bar);

            /* view = new Gtk.Grid ();
            view.expand = true;
            view.halign = view.valign = Gtk.Align.FILL; */

            var settings_widget = new Widgets.Settings (settings);
            settings_widget.valign = Gtk.Align.CENTER;
            var break_widget = new Widgets.Break (settings);

            try {
                break_time = GLib.Bus.get_proxy_sync (GLib.BusType.SESSION, Constants.DBUS_NAME, Constants.DBUS_PATH);
                break_time.changed_break.connect ((val) => {
                    break_widget.update_state (val);
                });

                break_widget.manage_timeout.connect ((state) => {
                    try {
                        break_time.break_manage (state);
                    } catch (Error e) {
                        warning ("Error: %s\n", e.message);
                    }
                });

                break_time.break_manage ("");
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }

            var view_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view_box.margin = 10;
            view_box.pack_start (settings_widget, true, true, 0);
            view_box.pack_start (break_widget, true, true, 0);

            /* view.attach (col_1, 0, 0); */

            add (view_box);
        }
    }
}
