namespace EBreakTime {
    public class Widgets.Settings : Widgets.CustomGrid {

        public Settings (SettingsManager settings) {
            var autostart_label = new Gtk.Label (_("Autostart"));
            autostart_label.halign = Gtk.Align.START;
            autostart_label.expand = true;
            var autostart_switch = new Gtk.Switch ();
            autostart_switch.halign = Gtk.Align.END;

            settings.bind ("autostart", autostart_switch, "active", GLib.SettingsBindFlags.DEFAULT);

            attach (autostart_label,  0, 0);
            attach (autostart_switch, 1, 0);

#if INDICATOR_EXIST
            var indicator_label = new Gtk.Label (_("Indicator"));
            indicator_label.halign = Gtk.Align.START;
            indicator_label.expand = true;
            var indicator_switch = new Gtk.Switch ();
            indicator_switch.halign = Gtk.Align.END;

            settings.bind ("indicator", indicator_switch, "active", SettingsBindFlags.DEFAULT);

            attach (indicator_label,  0, 1);
            attach (indicator_switch, 1, 1);
#endif
        }
    }
}
