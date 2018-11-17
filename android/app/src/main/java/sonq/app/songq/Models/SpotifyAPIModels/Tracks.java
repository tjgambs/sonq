package sonq.app.songq.Models.SpotifyAPIModels;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Tracks {
    @SerializedName("items")
    private List<SearchResult> songList;

    public List<SearchResult> getSongList() {
        return songList;
    }
}
