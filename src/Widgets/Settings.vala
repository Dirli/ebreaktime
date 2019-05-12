namespace EBreakTime {
    public class Widgets.Settings : Widgets.CustomGrid {

        public Settings (SettingsManager settings) {
            var autostart_label = new Gtk.Label (_("Autostart"));
            autostart_label.halign = Gtk.Align.START;
            autostart_label.expand = true;
            var autostart_switch = new Gtk.Switch ();
            autostart_switch.halign = Gtk.Align.END;

            settings.bind ("autostart", autostart_switch, "active", GLib.SettingsBindFlags.GET_NO_CHANGES);

            attach (autostart_label,  0, 0);
            attach (autostart_switch, 1, 0);
        }
    }
}
