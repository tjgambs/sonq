package sonq.app.sonq.Models.CloudAPIModels;

import java.util.List;

import sonq.app.sonq.Models.SpotifyAPIModels.Song;

public class GetQueueResponse {

    private List<Song> queue;

    public List<Song> getQueue() {
        return queue;
    }
}
