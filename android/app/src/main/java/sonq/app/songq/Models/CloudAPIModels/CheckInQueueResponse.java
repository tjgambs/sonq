package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class CheckInQueueResponse {

    @SerializedName("in_queue")
    private List<Integer> inQueue;

    public List<Integer> getInQueue() {
        return inQueue;
    }
}
