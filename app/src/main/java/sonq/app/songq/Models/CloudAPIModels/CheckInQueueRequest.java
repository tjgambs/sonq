package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

import sonq.app.songq.Models.SpotifyAPIModels.Song;

public class CheckInQueueRequest {

    @SerializedName("search_results")
    private List<SearchItem> searchResults = new ArrayList<>();

    public CheckInQueueRequest(List<Song> songs) {
        int idx = 0;
        for (Song song : songs) {
            searchResults.add(new SearchItem(idx, song.getSongURL()));
            idx++;
        }
    }
}

class SearchItem {

    private int idx;
    @SerializedName("song_url")
    private String songURL;

    protected SearchItem(int idx, String songURL) {
        this.idx = idx;
        this.songURL = songURL;
    }
}
