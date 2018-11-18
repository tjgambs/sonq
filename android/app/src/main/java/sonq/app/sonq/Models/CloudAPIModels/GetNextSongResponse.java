package sonq.app.sonq.Models.CloudAPIModels;

import sonq.app.sonq.Models.SpotifyAPIModels.Song;


public class GetNextSongResponse {

    private Song results;

    public Song getNextSong() {
        return results;
    }
}
