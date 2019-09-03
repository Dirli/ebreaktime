namespace EBreakTime {
    public class Widgets.ServiceItem : Gtk.ListBoxRow {
        public string icon_name { get; construct; }
        public string title { get; construct; }

        public ServiceItem (string icon_name, string title, string label) {
            Object (icon_name: icon_name,
                    title: title);

            var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);
            var title_label = new Gtk.Label (label);
            title_label.get_style_context ().add_class ("h3");
            title_label.ellipsize = Pango.EllipsizeMode.END;
            title_label.xalign = 0;

            var grid = new Gtk.Grid ();
            grid.margin = 6;
            grid.column_spacing = 6;
            grid.attach (icon, 0, 0, 1, 2);
            grid.attach (title_label, 1, 0, 1, 1);

            add (grid);
        }
    }
}
