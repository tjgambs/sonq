package sonq.app.sonq.Models.SpotifyAPIModels;

import java.util.ArrayList;
import java.util.List;

public class SongList {

    private List<Song> songList = new ArrayList<>();

    public SongList (List<SearchResult> results) {
        for (SearchResult result : results) {
                this.songList.add(new Song(result));
        }
    }

    public List<Song> getSongList() {
        return songList;
    }
}
