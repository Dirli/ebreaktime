namespace EBreakTime {
    public abstract class Core.AbstractManager : GLib.Object {
        public abstract bool init ();
        public abstract bool timer_handler ();
    }
}
