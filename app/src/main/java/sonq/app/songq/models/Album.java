package sonq.app.songq.models;

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

    @Override
    public String toString() {
        return this.name;
    }

}
