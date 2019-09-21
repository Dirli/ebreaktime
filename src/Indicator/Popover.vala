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
    public class Widgets.Popover : Gtk.Grid {
        public signal void manage_timeout (string action);

        public Gtk.ModelButton hide_button;

        private Gtk.Label breaktime_val;
        private Gtk.Grid grid_btns;
        private Gtk.Image access_icon;

        public Popover () {
            margin_top = 15;
            row_spacing = 10;

            var access_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            var access_lbl = new Gtk.Label (_("Access tracking"));
            access_lbl.expand = true;
            access_lbl.halign = Gtk.Align.START;

            access_icon = new Gtk.Image ();
            access_lbl.margin_start = access_icon.margin_end = 15;

            access_box.add (access_lbl);
            access_box.add (access_icon);

            var separator_head = new Wingpanel.Widgets.Separator ();
            separator_head.hexpand = true;

            attach (access_box, 0, 0, 2, 1);
            attach (separator_head, 0, 1, 2, 1);

            var breaktime_lbl = new Gtk.Label (_("Before the break:"));
            breaktime_lbl.expand = true;
            breaktime_lbl.halign = Gtk.Align.START;
            breaktime_val = new Gtk.Label ("Off");
            breaktime_val.halign = Gtk.Align.END;
            breaktime_lbl.margin_start = breaktime_val.margin_end = 15;

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

            grid_btns = new Gtk.Grid ();
            grid_btns.margin_start = grid_btns.margin_end = 15;
            grid_btns.attach (break_run_button,   0, 0);
            grid_btns.attach (break_reset_button, 1, 0);

            var separator_foot = new Wingpanel.Widgets.Separator ();
            separator_foot.hexpand = true;

            hide_button = new Gtk.ModelButton ();
            hide_button.text = _("Hide indicator");

            var app_button = new Gtk.ModelButton ();
            app_button.text = _("Start EBreakTime");

            app_button.clicked.connect (() => {
                var app_info = new GLib.DesktopAppInfo(Constants.DESKTOP_FILE_NAME);

                if (app_info == null) {return;}

                try {
                    app_info.launch(null, null);
                } catch (Error e) {
                    warning ("Unable to launch io.elementary.ebreaktime.desktop: %s", e.message);
                }
            });

            attach (breaktime_lbl,  0, 2);
            attach (breaktime_val,  1, 2);
            attach (grid_btns,      0, 3, 2, 1);
            attach (separator_foot, 0, 4, 2, 1);
            attach (hide_button,    0, 5, 2, 1);
            attach (app_button,     0, 6, 2, 1);
        }

        public void update_state (string min) {
            breaktime_val.label = min;
        }

        public void access_state_img (bool access_manager_state) {
            access_icon.set_from_icon_name(access_manager_state ? "user-available" : "user-busy", Gtk.IconSize.MENU);
        }

        public void timed_expired (bool time_expired_state) {
            if (time_expired_state) {
                var exist_widget = get_child_at (0, 0);
                if (exist_widget != null) {
                    exist_widget.destroy ();
                }

                var time_up_lbl = new Gtk.Label (_("Your time is up"));
                time_up_lbl.expand = true;
                time_up_lbl.halign = Gtk.Align.CENTER;


                breaktime_val.label = "Off";

                attach (time_up_lbl,    0, 0, 2, 1);
            }

            grid_btns.sensitive = !time_expired_state;
        }
    }
}
