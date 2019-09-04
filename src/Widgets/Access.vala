namespace EBreakTime {
    public class Widgets.Access : Granite.SimpleSettingsPage {
        private Gtk.ComboBoxText limit_combobox;

        private Gee.HashMap<string, string> access_map;
        private Gtk.SizeGroup title_group;

        public Access () {
            Object (activatable: true,
                    description: _("Limit computer use"),
                    icon_name: "preferences-system-privacy",
                    title: _("Access time"));

            access_map = new Gee.HashMap<string, string> ();

            limit_combobox = new Gtk.ComboBoxText ();
            limit_combobox.hexpand = false;
            limit_combobox.append (PAM.DayType.ALL.to_string (), _("On weekdays and weekends"));
            limit_combobox.append (PAM.DayType.WEEKDAY.to_string (), _("Only on weekdays"));
            limit_combobox.append (PAM.DayType.WEEKEND.to_string (), _("Only on weekends"));
            limit_combobox.active = 0;
            limit_combobox.changed.connect (on_limit_combobox_changed);

            title_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);

            content_area.column_spacing = content_area.row_spacing = 12;
            content_area.margin_top = 60;
            content_area.halign = Gtk.Align.CENTER;
            content_area.attach (limit_combobox, 0, 0);

            var upd_button = new Gtk.Button.with_label (_("Update limits"));
            upd_button.clicked.connect (update_pam);

            action_area.halign = Gtk.Align.CENTER;
            action_area.add (upd_button);

            on_limit_combobox_changed ();
        }

        public void update_pam () {
            if (access_map.size > 0) {
                //
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
            var exist_widget = content_area.get_child_at (0, 1);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            var frame = new Gtk.Frame (null);
            frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            frame.add (frame_box);

            content_area.attach (frame, 0, 1);
            content_area.show_all ();
        }

        private Gtk.Box create_frame_box (PAM.DayType id) {
            var frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

            if (id == PAM.DayType.WEEKDAY || id == PAM.DayType.ALL) {
                var weekday_box = new WeekSpinBox (_("Weekdays"), id, title_group);
                weekday_box.changed.connect (on_changed_box);
                frame_box.add (weekday_box);
            }

            if (id == PAM.DayType.ALL) {
                frame_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            }

            if (id == PAM.DayType.WEEKEND || id == PAM.DayType.ALL) {
                var weekend_box = new WeekSpinBox (_("Weekends"), id, title_group);
                weekend_box.changed.connect (on_changed_box);
                frame_box.add (weekend_box);
            }

            return frame_box;
        }

        private void on_limit_combobox_changed () {
            access_map.clear ();
            string id = limit_combobox.get_active_id ();

            add_frame (create_frame_box (PAM.DayType.to_enum (id)));
        }
    }
}
