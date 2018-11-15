package sonq.app.songq.Models.CloudAPIModels;

import sonq.app.songq.Models.SpotifyAPIModels.Song;


public class GetNextSongResponse {

    private Song results;

    public Song getNextSong() {
        return results;
    }
}
