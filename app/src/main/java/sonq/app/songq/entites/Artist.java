package sonq.app.songq.entites;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

public class Artist {

    public String href;
    public String id;
    public String name;
    public String type;
    public String uri;

    public Artist(JSONObject jsonObject) {
        try {
            this.href = jsonObject.getString("href");
            this.id = jsonObject.getString("id");
            this.name = jsonObject.getString("name");
            this.type = jsonObject.getString("type");
            this.uri = jsonObject.getString("uri");
        } catch (JSONException e) {
            Log.i("Artist", "Could not parse jsonObject");
        }
    }

    @Override
    public String toString() {
        return this.name;
    }

}
