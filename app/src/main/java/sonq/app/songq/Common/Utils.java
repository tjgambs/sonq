package sonq.app.songq.Common;

public abstract class Utils {

    public static String getPrettyLength(int ms) {
        long minutes = (ms / 1000) / 60;
        long seconds = (ms / 1000) % 60;
        return String.format("%d:%02d", minutes, seconds);
    }
}
