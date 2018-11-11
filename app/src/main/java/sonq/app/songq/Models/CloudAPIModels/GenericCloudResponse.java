package sonq.app.songq.Models.CloudAPIModels;

public class GenericCloudResponse<T> {

    private T data;

    public T getData() {
        return data;
    }
}
