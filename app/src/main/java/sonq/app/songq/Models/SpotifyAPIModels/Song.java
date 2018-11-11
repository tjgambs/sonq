package sonq.app.songq.Models.SpotifyAPIModels;

import android.graphics.Bitmap;

import com.google.gson.annotations.SerializedName;

import sonq.app.songq.Common.Utils;


public class Song  {

    private String name;
    private String artist;
    private String previewURL;
    private String songURL;
    private String duration;
    private int durationInMs;


    //thumbnail
    private String imageURL;
    private int imageWidth;
    private int imageHeight;

    private Bitmap thumbnail;

    @SerializedName("added_by")
    private String addedBy;

    private boolean isInQueue = false;

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
    }

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

    public int getDurationInMs() {
        return durationInMs;
    }

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
}
