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

        public Popover () {
            margin_top = 15;
            row_spacing = 10;

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

            var grid_btns = new Gtk.Grid ();
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

            attach (breaktime_lbl,  0, 0);
            attach (breaktime_val,  1, 0);
            attach (grid_btns,      0, 1, 2, 1);
            attach (separator_foot, 0, 2, 2, 1);
            attach (hide_button,    0, 3, 2, 1);
            attach (app_button,     0, 4, 2, 1);
        }

        public void update_state (string min) {
            breaktime_val.label = min;
        }
    }
}
