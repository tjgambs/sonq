package sonq.app.sonq.Models.SpotifyAPIModels;

import android.graphics.Bitmap;

import com.google.gson.annotations.SerializedName;

import java.util.Objects;

import sonq.app.sonq.Common.Utils;


public class Song  {

    private String name;
    private String artist;
    private String previewURL;
    private String songURL;
    private String duration;
    private int durationInMs;
    private double durationInSeconds;

    private String partyID;

    //thumbnail
    private String imageURL;
    private int imageWidth;
    private int imageHeight;

    private Bitmap thumbnail;

    @SerializedName("added_by")
    private String addedBy;

    private boolean isInQueue = false;

    @SerializedName("is_playing")
    private boolean isPlaying;

    public Song() { }

    public Song(SearchResult item) {
        name = item.getName();
        previewURL = item.getPreviewUrl();
        songURL = item.getUri();
        durationInMs = item.getDurationMs();
        duration = Utils.getPrettyLength(durationInMs);

        if (item.getArtists().size() > 0)
            artist = item.getArtists().get(0).getName();

        Image img = null;
        if (item.getAlbum().getImages().size() > 1) {
            img = item.getAlbum().getImages().get(1);
        } else if (item.getAlbum().getImages().size() > 0) {
            img = item.getAlbum().getImages().get(0);
        }
        if (img != null) {
            imageURL = img.getUrl();
            imageWidth = img.getWidth();
            imageHeight = img.getHeight();
        }
        durationInSeconds = durationInMs / 1000.0;
    }

    public String getPartyID() { return partyID; }

    public String getName() {
        return name;
    }

    public String getArtist() {
        return artist;
    }

    public String getPreviewURL() {
        return previewURL;
    }

    public String getSongURL() {
        return songURL;
    }

    public String getDuration() {
        return duration;
    }

    public int getDurationInMs() { return durationInMs; }

    public double getDurationInSeconds() { return durationInSeconds; }

    public String getImageURL() {
        return imageURL;
    }

    public int getImageWidth() {
        return imageWidth;
    }

    public int getImageHeight() {
        return imageHeight;
    }

    public Bitmap getThumbnail() {
        return thumbnail;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public void setPreviewURL(String previewURL) {
        this.previewURL = previewURL;
    }

    public void setThumbnail(Bitmap thumbnail) {
        this.thumbnail = thumbnail;
    }

    public String getAddedBy() {
        return addedBy;
    }

    public boolean isInQueue() {
        return isInQueue;
    }

    public void setInQueue(boolean inQueue) {
        isInQueue = inQueue;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Song song = (Song) o;
        return isPlaying == song.isPlaying &&
                Objects.equals(songURL, song.songURL) &&
                Objects.equals(addedBy, song.addedBy);
    }

    @Override
    public int hashCode() {

        return Objects.hash(songURL, addedBy, isPlaying);
    }
}
