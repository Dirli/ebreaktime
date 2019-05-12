namespace EBreakTime {
    public class Widgets.CustomGrid : Gtk.Grid {
        public CustomGrid () {
            row_spacing = 10;

            get_style_context ().add_class ("block");

            valign = Gtk.Align.START;
            halign = Gtk.Align.CENTER;
        }
        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = 300;
            natural_width = 300;
        }
    }
}
