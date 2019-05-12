public class EBreakTime.SettingsManager : GLib.Settings {
    private static SettingsManager? instance = null;

    public SettingsManager () {
        Object (schema_id: "io.elementary.ebreaktime");
    }

    public static SettingsManager get_default () {
        if (instance == null) {
            instance = new SettingsManager ();
        }

        return instance;
    }
}
