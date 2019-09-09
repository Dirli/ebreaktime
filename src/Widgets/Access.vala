namespace EBreakTime {
    public class Widgets.Access : Granite.SimpleSettingsPage {
        private Gee.HashMap<string, string> access_map;
        private Gee.HashMap<PAM.DayType, string> names_map;
        private Gtk.SizeGroup title_group;

        public Access () {
            Object (activatable: true,
                    description: _("Limit computer use"),
                    icon_name: "preferences-system-privacy",
                    title: _("Access time"));

            status_switch.notify["active"].connect (() => {
                PAM.Token.switch_pam (status_switch.active);
                content_area.sensitive = status_switch.active;
                action_area.sensitive = status_switch.active;
            });

            status_switch.active = PAM.Token.get_pam_state ();
            content_area.sensitive = status_switch.active;
            action_area.sensitive = status_switch.active;

            names_map = new Gee.HashMap<PAM.DayType, string> ();
            names_map[PAM.DayType.ALL] = _("All days");
            names_map[PAM.DayType.WEEKDAY] = _("Weekdays");
            names_map[PAM.DayType.WEEKEND] = _("Weekends");
            names_map[PAM.DayType.MONDAY] = _("Monday");
            names_map[PAM.DayType.TUESDAY] = _("Tuesday");
            names_map[PAM.DayType.WEDNESDAY] = _("Wednesday");
            names_map[PAM.DayType.THURSDAY] = _("Thursday");
            names_map[PAM.DayType.FRIDAY] = _("Friday");
            names_map[PAM.DayType.SATURDAY] = _("Saturday");
            names_map[PAM.DayType.SUNDAY] = _("Sunday");

            access_map = new Gee.HashMap<string, string> ();

            title_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);

            content_area.column_spacing = content_area.row_spacing = 12;
            content_area.margin_top = 20;
            content_area.halign = Gtk.Align.CENTER;

            var upd_button = new Gtk.Button.with_label (_("Update limits"));
            upd_button.clicked.connect (update_pam);

            var restore_button = new Gtk.Button.with_label (_("Restore limits"));
            restore_button.tooltip_text =_("All unsaved changes will be discarded");
            restore_button.clicked.connect (load_restrictions);

            var clear_button = new Gtk.Button.with_label (_("Clear limits"));
            clear_button.tooltip_text =_("All your limits will be deleted");
            clear_button.clicked.connect (() => {
                PAM.Token.set_token_for_user (Posix.getlogin ());
                load_restrictions ();
            });

            action_area.halign = Gtk.Align.CENTER;
            action_area.add (clear_button);
            action_area.add (restore_button);
            action_area.add (upd_button);

            load_restrictions ();
        }

        private void load_restrictions () {
            access_map.clear ();
            var token = PAM.Token.get_token_for_user (Posix.getlogin ());

            if (token != null) {
                access_map = token.get_times_info ();
            }

            add_frame (create_frame_box ());
        }

        public void update_pam () {
            if (access_map.size > 0) {
                string[] new_restrictions = {};
                access_map.foreach ((entry) => {
                    new_restrictions += (entry.key + entry.value);
                    return true;
                });
                PAM.Token.set_token_for_user (Posix.getlogin (), new_restrictions);
                load_restrictions ();
            }
        }

        private void on_changed_box (string d_type, string? t_limits) {
            if (t_limits == null) {
                access_map.unset (d_type);
            } else {
                access_map[d_type] = t_limits;
            }
        }

        private void add_frame (Gtk.Box frame_box) {
            var exist_widget = content_area.get_child_at (0, 0);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            var frame = new Gtk.Frame (null);
            frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            frame.add (frame_box);

            content_area.attach (frame, 0, 0);
            content_area.show_all ();
        }

        private Gtk.Box create_frame_box () {
            var frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

            frame_box.add (get_iter_box (PAM.DayType.ALL));
            frame_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            frame_box.add (get_iter_box (PAM.DayType.WEEKDAY));
            frame_box.add (get_iter_box (PAM.DayType.WEEKEND));
            frame_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            foreach (var day_type in PAM.DayType.get_days ()) {
                frame_box.add (get_iter_box (day_type));
            }

            return frame_box;
        }

        private WeekSpinBox get_iter_box (PAM.DayType day_type) {
            var iter_box = new WeekSpinBox (names_map[day_type], day_type, title_group);
            if (access_map.has_key (day_type.to_string ())) {
                string[] bounds = access_map[day_type.to_string ()].split ("-");
                iter_box.set_from (bounds[0]);
                iter_box.set_to (bounds[1]);
                iter_box.highlight_restriction ();
            }

            iter_box.changed.connect (on_changed_box);
            return iter_box;
        }
    }
}
