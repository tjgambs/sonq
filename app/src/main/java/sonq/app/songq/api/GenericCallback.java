package sonq.app.songq.api;

public interface GenericCallback<T> {
    void onValue(T value);
}
