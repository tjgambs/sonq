package sonq.app.songq.entites;


import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class Song {

    public String uri;
    public String type;
    public int trackNumber;
    public String previewUrl;
    public int popularity;
    public String name;
    public Boolean isLocal;
    public String id;
    public String href;
    public Boolean explicit;
    public int durationMs;
    public int discNumber;

    public ArrayList artists = new ArrayList<Artist>();
    public Album album;

    public Song(JSONObject jsonObject) {
        try {
            this.uri = jsonObject.getString("uri");
            this.type = jsonObject.getString("type");
            this.trackNumber = jsonObject.getInt("track_number");
            this.previewUrl = jsonObject.getString("preview_url");
            this.popularity = jsonObject.getInt("popularity");
            this.name = jsonObject.getString("name");
            this.isLocal = jsonObject.getBoolean("is_local");
            this.id = jsonObject.getString("id");
            this.href = jsonObject.getString("href");
            this.explicit = jsonObject.getBoolean("explicit");
            this.durationMs = jsonObject.getInt("duration_ms");
            this.discNumber = jsonObject.getInt("disc_number");
            for (int i = 0; i < jsonObject.getJSONArray("artists").length(); i++) {
                this.artists.add(new Artist(jsonObject.getJSONArray("artists").getJSONObject(i)));
            }
            this.album = new Album(jsonObject.getJSONObject("album"));
        } catch (JSONException e) {
            Log.i("Song", "Could not parse jsonObject");
        }
    }

    @Override
    public String toString() {
        return this.name + " - " + this.album.toString() + " - " + this.artists.get(0).toString();
    }

}
