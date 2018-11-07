package sonq.app.songq.models;


import android.util.Log;

import com.google.gson.annotations.SerializedName;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Song {

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

    @Override
    public String toString() {
        return this.name + " - " + this.album.toString() + " - " + this.artists.get(0).toString();
    }

}
