package sonq.app.sonq.Models.SpotifyAPIModels;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Album {

    @SerializedName("album_type")
    private String albumType;
    private String href;
    private String id;
    private String name;
    @SerializedName("release_date")
    private String releaseDate;
    @SerializedName("release_date_precision")
    private String releaseDatePrecision;
    @SerializedName("total_tracks")
    private int totalTracks;
    private String type;
    private String uri;

    private List<Artist> artists;
    private List<Image> images;

    public String getAlbumType() {
        return albumType;
    }

    public String getHref() {
        return href;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getReleaseDate() {
        return releaseDate;
    }

    public String getReleaseDatePrecision() {
        return releaseDatePrecision;
    }

    public int getTotalTracks() {
        return totalTracks;
    }

    public String getType() {
        return type;
    }

    public String getUri() {
        return uri;
    }

    public List<Artist> getArtists() {
        return artists;
    }

    public List<Image> getImages() {
        return images;
    }

    @Override
    public String toString() {
        return this.name;
    }

}
