package sonq.app.sonq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

public class SetPlayingRequest {

    @SerializedName("song_url")
    private String songURL;
    @SerializedName("is_playing")
    private boolean isPlaying;

    public SetPlayingRequest(String songURL, boolean isPlaying) {
        this.songURL = songURL;
        this.isPlaying = isPlaying;
    }
}
