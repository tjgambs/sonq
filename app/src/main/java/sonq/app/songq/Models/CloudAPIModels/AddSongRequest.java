package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

import sonq.app.songq.Models.SpotifyAPIModels.Song;

public class AddSongRequest {

    private String partyID;
    private String name;
    private String artist;
    private String duration;
    private float durationInSeconds;
    private String imageURL;
    private String songURL;
    @SerializedName("added_by")
    private String addedBy;

    public AddSongRequest(String partyID, String addedBy, Song song) {
        this.partyID = partyID;
        this.name = song.getName();
        this.artist = song.getArtist();
        this.duration = song.getDuration();
        this.durationInSeconds = song.getDurationInMs() / 1000;
        this.imageURL = song.getImageURL();
        this.songURL = song.getSongURL();
        this.addedBy = addedBy;
    }
}
