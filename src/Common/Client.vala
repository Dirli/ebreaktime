namespace EBreakTime {
    [DBus (name = "io.elementary.EBreakTime")]
    interface EBreakTime : Object {
        public abstract void break_manage (string? msg) throws GLib.DBusError, GLib.IOError;
        public signal void changed_break (string new_val);
    }
}
