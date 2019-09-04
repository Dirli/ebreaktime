namespace EBreakTime {
    public class Widgets.WeekSpinBox : Gtk.Box {
        public signal void changed (string d_type, string? time_limits);
        private Granite.Widgets.TimePicker picker_from;
        private Granite.Widgets.TimePicker picker_to;
        private string day_type;

        public WeekSpinBox (string title, PAM.DayType day_type, Gtk.SizeGroup size_group) {
            orientation = Gtk.Orientation.HORIZONTAL;
            spacing = 12;
            margin = 12;
            halign = Gtk.Align.CENTER;

            this.day_type = day_type.to_string ();

            picker_from = new Granite.Widgets.TimePicker ();
            picker_from.time_changed.connect (on_picker_changed);
            picker_to = new Granite.Widgets.TimePicker ();
            picker_to.time_changed.connect (on_picker_changed);

            var label = new Gtk.Label (title);
            label.get_style_context ().add_class ("h4");
            size_group.add_widget (label);

            add (label);
            add (new Gtk.Label (_("From:")));
            add (picker_from);
            add (new Gtk.Label (_("To:")));
            add (picker_to);
        }

        private void on_picker_changed () {
            var time_from = get_from ();
            var time_to = get_to ();
            // var t_limits = time_from == time_to ? null : (time_from + time_to);

            changed (day_type, time_from == time_to ? null : (time_from + time_to));
        }

        public string get_from () {
            return format_time_string (picker_from.time.get_hour ()) + format_time_string (picker_from.time.get_minute ());
        }

        public string get_to () {
            return format_time_string (picker_to.time.get_hour ()) + format_time_string (picker_to.time.get_minute ());
        }

        public void set_from (string from) {
            string hours = from.slice (0, 2);
            string minutes = from.substring (2);
            var time = new DateTime.local (new DateTime.now_local ().get_year (), 1, 1, int.parse (hours), int.parse (minutes), 0);
            picker_from.time = time;
        }

        public void set_to (string to) {
            string hours = to.slice (0, 2);
            string minutes = to.substring (2);
            var time = new DateTime.local (new DateTime.now_local ().get_year (), 1, 1, int.parse (hours), int.parse (minutes), 0);
            picker_to.time = time;
        }

        private string format_time_string (int val) {
            if (val < 10) {
                return "0" + val.to_string ();
            }

            return val.to_string ();
        }
    }
}
