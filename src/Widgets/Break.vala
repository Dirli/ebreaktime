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
    public class Widgets.Break : Granite.SimpleSettingsPage {
        public signal void manage_timeout (string action);

        private Gtk.Label breaktime_val;

        public Break (SettingsManager settings) {
            Object (activatable: true,
                    description: _("Break time description"),
                    icon_name: "preferences-system-time",
                    title: _("Break time"));

            status_switch.notify["active"].connect (() => {
                content_area.sensitive = status_switch.active;
            });
            status_switch.active = settings.get_boolean ("break");

            var breaktime_lbl = new Gtk.Label (_("Before the break:"));
            breaktime_lbl.halign = Gtk.Align.END;
            breaktime_val = new Gtk.Label ("Off");

            var break_time_label = new Gtk.Label (_("Break time (m.):"));
            break_time_label.halign = Gtk.Align.END;
            var break_time_val = new Gtk.SpinButton.with_range (5, 60, 5);
            break_time_val.set_width_chars (3);
            break_time_val.halign = Gtk.Align.START;

            var work_time_label = new Gtk.Label (_("Work time (m.):"));
            work_time_label.halign = Gtk.Align.END;
            var work_time_val = new Gtk.SpinButton.with_range (10, 240, 5);
            work_time_val.set_width_chars (3);
            work_time_val.halign = Gtk.Align.START;

            var postpone_label = new Gtk.Label (_("Allow to postpone the break"));
            postpone_label.halign = Gtk.Align.END;
            var postpone_switch = new Gtk.Switch ();
            postpone_switch.halign = Gtk.Align.START;

            content_area.column_spacing = content_area.row_spacing = 12;
            content_area.margin_top = 60;
            content_area.halign = Gtk.Align.CENTER;
            content_area.attach (breaktime_lbl,    0, 0);
            content_area.attach (breaktime_val,    1, 0);
            content_area.attach (work_time_label,  0, 1);
            content_area.attach (work_time_val,    1, 1);
            content_area.attach (break_time_label, 0, 2);
            content_area.attach (break_time_val,   1, 2);
            content_area.attach (postpone_label,   0, 3);
            content_area.attach (postpone_switch,  1, 3);

            settings.bind ("break", status_switch, "active", GLib.SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("postpone", postpone_switch, "active", SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("breaktime", break_time_val, "value", SettingsBindFlags.GET_NO_CHANGES);
            settings.bind ("worktime", work_time_val, "value", SettingsBindFlags.GET_NO_CHANGES);

            var break_reset_button = new Gtk.Button.with_label (_("Reset timer"));
            break_reset_button.clicked.connect (() => {
                manage_timeout ("reset");
            });

            var break_run_button = new Gtk.Button.with_label (_("Start a break"));
            break_run_button.clicked.connect (() => {
                manage_timeout ("run");
            });

            action_area.halign = Gtk.Align.CENTER;
            action_area.add (break_reset_button);
            action_area.add (break_run_button);
        }

        public void update_state (string min) {
            breaktime_val.label = min;
        }
    }
}
