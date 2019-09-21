namespace EBreakTime {
    public abstract class Core.AbstractManager : GLib.Object {
        public string manager_name;
        public abstract bool init ();
        public abstract bool timer_handler (bool idle);
        public virtual void stopped_manager () {}
    }
}
