namespace EBreakTime {
    public class Widgets.Break : Widgets.CustomGrid {
        public signal void manage_timeout (string action);

        private Gtk.Label breaktime_val;

        public Break (SettingsManager settings) {
            margin_top = 10;
            var breaktime_lbl = new Gtk.Label (_("Before the break:"));
            breaktime_lbl.expand = true;
            breaktime_lbl.halign = Gtk.Align.START;
            breaktime_val = new Gtk.Label ("Off");
            breaktime_val.halign = Gtk.Align.END;

            GLib.Idle.add (() => {
                breaktime_lbl.visible = settings.get_boolean ("break");
                return false;
            });

            var break_label = new Gtk.Label (_("Break"));
            break_label.halign = Gtk.Align.START;
            break_label.get_style_context ().add_class ("block-head");

            var break_switch = new Gtk.Switch ();
            break_switch.halign = Gtk.Align.END;

            var break_reset_button = new Gtk.Button.with_label (_("Reset"));
            break_reset_button.expand = true;
            break_reset_button.tooltip_text = _("Reset timer");
            break_reset_button.clicked.connect (() => {
                manage_timeout ("reset");
            });

            var break_run_button = new Gtk.Button.with_label (_("Run"));
            break_run_button.expand = true;
            break_run_button.tooltip_text = _("Start a break");
            break_run_button.clicked.connect (() => {
                manage_timeout ("run");
            });

            var grid_btns = new Gtk.Grid ();
            grid_btns.attach (break_run_button,   0, 0);
            grid_btns.attach (break_reset_button, 1, 0);

            var time_set_label = new Gtk.Label (_("Time to:"));
            time_set_label.expand = true;
            time_set_label.halign = Gtk.Align.CENTER;

            var break_time_label = new Gtk.Label (_("break (m.):"));
            break_time_label.halign = Gtk.Align.START;
            break_time_label.margin_end = 10;
            var break_time_val = new Gtk.SpinButton.with_range (5, 60, 5);
            break_time_val.set_halign (Gtk.Align.END);
            break_time_val.set_width_chars (3);

            var work_time_label = new Gtk.Label (_("work (m.):"));
            work_time_label.halign = Gtk.Align.START;
            work_time_label.margin_end = 10;
            var work_time_val = new Gtk.SpinButton.with_range (30, 240, 5);
            work_time_val.set_halign (Gtk.Align.END);
            work_time_val.set_width_chars (3);

            var postpone_label = new Gtk.Label (_("Postpone"));
            postpone_label.halign = Gtk.Align.START;

            var postpone_switch = new Gtk.Switch ();
            postpone_switch.halign = Gtk.Align.END;

            postpone_switch.tooltip_text = _("Allow to postpone the break");

            attach (breaktime_lbl,    0, 0);
            attach (breaktime_val,    1, 0);
            attach (break_label,      0, 1);
            attach (break_switch,     1, 1);
            attach (grid_btns,        0, 2, 2, 1);
            attach (time_set_label,   0, 3, 2, 1);
            attach (work_time_label,  0, 4);
            attach (work_time_val,    1, 4);
            attach (break_time_label, 0, 5);
            attach (break_time_val,   1, 5);
            attach (postpone_label,   0, 6);
            attach (postpone_switch,  1, 6);

            settings.bind ("break", break_switch, "active", GLib.SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("postpone", postpone_switch, "active", SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("breaktime", break_time_val, "value", SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("worktime", work_time_val, "value", SettingsBindFlags.GET_NO_CHANGES);

            break_switch.notify["active"].connect (() => {
                breaktime_lbl.visible  = break_switch.get_state ();
            });
        }

        public void update_state (string min) {
            breaktime_val.label = min;
        }
    }
}
