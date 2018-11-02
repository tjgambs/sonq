package sonq.app.songq.entites;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

public class Image {

    public int height;
    public int width;
    public String url;

    public Image(JSONObject jsonObject) {
        try {
            this.height = jsonObject.getInt("height");
            this.width = jsonObject.getInt("width");
            this.url = jsonObject.getString("url");
        } catch (JSONException e) {
            Log.i("Image", "Could not parse jsonObject");
        }
    }
}
