namespace EBreakTime {
    public class Core.TimerManager : GLib.Object {
        public signal bool emit_time ();

        private uint source_id;

        private static TimerManager? instance = null;
        public static TimerManager get_default () {
            if (instance == null) {
                instance = new TimerManager ();
            }

            return instance;
        }

        private TimerManager () {
            source_id = 0;
        }

        public bool get_state () {
            return source_id > 0;
        }

        public void stop_timer () {
            if (source_id > 0) {
                GLib.Source.remove(source_id);
                source_id = 0;
            }
        }

        public void start_timer (int interval = 60) {
            stop_timer ();

            if (interval == 0) {
                return;
            }

            source_id = GLib.Timeout.add_seconds (interval, () => {
                return emit_time ();
            });
        }

    }
}
