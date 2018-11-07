package sonq.app.songq.models;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Tracks {
    @SerializedName("items")
    private List<Song> songList;

    public List<Song> getSongList() {
        return songList;
    }
}
