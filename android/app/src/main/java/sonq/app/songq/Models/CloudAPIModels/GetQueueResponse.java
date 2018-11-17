package sonq.app.songq.Models.CloudAPIModels;

import java.util.List;

import sonq.app.songq.Models.SpotifyAPIModels.Song;

public class GetQueueResponse {

    private List<Song> queue;

    public List<Song> getQueue() {
        return queue;
    }
}
