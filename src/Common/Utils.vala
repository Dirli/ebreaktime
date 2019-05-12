namespace EBreakTime {
    public class Utils {
        public static void show_notify (string body, string? summary = null) {
#if NOTIFY_ENABLE
            if (summary == null) {
                summary = _("Time break");
            }
            string icon = "tools-timer-symbolic";

            Notify.init ("EBreakTime");

            try {
                Notify.Notification notification = new Notify.Notification (summary, body, icon);
                notification.show ();
            } catch (Error e) {
                warning ("Error: %s", e.message);
            }
#endif
        }
    }
}
