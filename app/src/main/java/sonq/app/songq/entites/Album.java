package sonq.app.songq.entites;


import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class Album {

    public String albumType;
    public String href;
    public String id;
    public String name;
    public String releaseDate;
    public String releaseDatePrecision;
    public int totalTracks;
    public String type;
    public String uri;

    public ArrayList artists = new ArrayList<Artist>();
    public ArrayList images = new ArrayList<Image>();

    public Album(JSONObject jsonObject) {
        try {
            this.albumType = jsonObject.getString("album_type");
            this.href = jsonObject.getString("href");
            this.id = jsonObject.getString("id");
            this.name = jsonObject.getString("name");
            this.releaseDate = jsonObject.getString("release_date");
            this.releaseDatePrecision = jsonObject.getString("release_date_precision");
            this.totalTracks = jsonObject.getInt("total_tracks");
            this.type = jsonObject.getString("type");
            this.uri = jsonObject.getString("uri");
            for (int i = 0; i < jsonObject.getJSONArray("artists").length(); i++) {
                this.artists.add(new Artist(jsonObject.getJSONArray("artists").getJSONObject(i)));
            }
            for (int i = 0; i < jsonObject.getJSONArray("images").length(); i++) {
                this.images.add(new Image(jsonObject.getJSONArray("images").getJSONObject(i)));
            }
        } catch (JSONException e) {
            Log.i("Album", "Could not parse jsonObject");
        }
    }

    @Override
    public String toString() {
        return this.name;
    }

}
