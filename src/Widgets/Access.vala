/*
 * Copyright (c) 2019 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace EBreakTime {
    public class Widgets.Access : Granite.SimpleSettingsPage {
        public signal void pam_changed ();

        private Gee.HashMap<string, string> access_map;
        private Gee.HashMap<PAM.DayType, string> names_map;
        private Gtk.SizeGroup title_group;

        public bool status_switch_state {
            set {
                status_switch.sensitive = value;
                action_area.sensitive = value;
            }
        }

        public Access () {
            Object (activatable: true,
                    description: _("Here you can configure the periods in which the computer will be available to you. Time limits are checked a little, but if you really want, I think you can shoot yourself in the leg))"),
                    icon_name: "preferences-system-privacy",
                    title: _("Access time"));

            status_switch.active = PAM.Token.get_pam_state ();
            status_switch.notify["active"].connect (() => {
                Utils.run_cli ("--state=%s".printf (status_switch.active ? "on" : "off"));
                pam_changed ();
            });

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
                Utils.run_cli ("--user=%s".printf (Posix.getlogin ()));
                load_restrictions ();
                pam_changed ();
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

                Utils.run_cli ("--user=%s --timeline=%s".printf (Posix.getlogin (), string.joinv (Constants.LIST_SEPARATOR, new_restrictions)));
                load_restrictions ();
                pam_changed ();
            }
        }

        private void on_changed_box (string d_type, string? t_limits) {
            if (t_limits == null) {
                access_map.unset (d_type);
            } else {
                access_map[d_type] = t_limits;
            }
        }

        private void add_frame (Gtk.Stack frames_stack) {
            var exist_widget = content_area.get_child_at (0, 0);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            exist_widget = content_area.get_child_at (0, 1);
            if (exist_widget != null) {
                exist_widget.destroy ();
            }

            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.homogeneous = true;
            stack_switcher.margin_top = 12;
            stack_switcher.stack = frames_stack;

            var frame = new Gtk.Frame (null);
            frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            frame.add (frames_stack);

            content_area.attach (stack_switcher, 0, 0);
            content_area.attach (frame, 0, 1);
            content_area.show_all ();
        }

        private Gtk.Stack create_frame_box () {
            var periods_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            periods_box.valign = Gtk.Align.CENTER;
            var days_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

            periods_box.add (get_iter_box (PAM.DayType.ALL));
            periods_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            periods_box.add (get_iter_box (PAM.DayType.WEEKDAY));
            periods_box.add (get_iter_box (PAM.DayType.WEEKEND));

            foreach (var day_type in PAM.DayType.get_days ()) {
                days_box.add (get_iter_box (day_type));
            }

            var frames_stack = new Gtk.Stack ();
            frames_stack.expand = true;
            frames_stack.add_titled (periods_box, "periods", _("Periods"));
            frames_stack.add_titled (days_box, "days", _("Days"));

            return frames_stack;
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
