package sonq.app.songq.Models;


import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchResult {

    private String uri;
    private String type;
    @SerializedName("track_number")
    private int trackNumber;
    @SerializedName("preview_url")
    private String previewUrl;
    private int popularity;
    private String name;
    @SerializedName("is_local")
    private Boolean isLocal;
    private String id;
    private String href;
    private Boolean explicit;
    @SerializedName("duration_ms")
    private int durationMs;
    @SerializedName("disc_number")
    private int discNumber;

    private List<Artist> artists;
    private Album album;

    public String getUri() {
        return uri;
    }

    public String getType() {
        return type;
    }

    public int getTrackNumber() {
        return trackNumber;
    }

    public String getPreviewUrl() {
        return previewUrl;
    }

    public int getPopularity() {
        return popularity;
    }

    public String getName() {
        return name;
    }

    public Boolean getLocal() {
        return isLocal;
    }

    public String getId() {
        return id;
    }

    public String getHref() {
        return href;
    }

    public Boolean getExplicit() {
        return explicit;
    }

    public int getDurationMs() {
        return durationMs;
    }

    public int getDiscNumber() {
        return discNumber;
    }

    public List<Artist> getArtists() {
        return artists;
    }

    public Album getAlbum() {
        return album;
    }

    @Override
    public String toString() {
        return this.name + " - " + this.album.toString() + " - " + this.artists.get(0).toString();
    }

}
