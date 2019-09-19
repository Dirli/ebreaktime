namespace EBreakTime {
    public abstract class Core.AbstractManager : GLib.Object {
        public string manager_name;
        public abstract bool init ();
        public abstract bool timer_handler ();
        public virtual void stopped_manager () {}
    }
}
