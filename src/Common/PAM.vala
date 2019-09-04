namespace EBreakTime.PAM {
    public enum DayType {
        UNKNOWN,
        ALL,
        WEEKDAY,
        WEEKEND;

        public static DayType to_enum (string str) {
            switch (str) {
                case "Al":
                    return ALL;
                case "Wk":
                    return WEEKDAY;
                case "Wd":
                    return WEEKEND;
                default:
                    return UNKNOWN;
            }
        }

        public string to_string () {
            switch (this) {
                case ALL:
                    return "Al";
                case WEEKDAY:
                    return "Wk";
                case WEEKEND:
                    return "Wd";
                default:
                case UNKNOWN:
                    return "unknown";
            }
        }
    }
}
