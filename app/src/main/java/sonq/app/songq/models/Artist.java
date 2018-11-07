package sonq.app.songq.models;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

public class Artist {

    private String href;
    private String id;
    private String name;
    private String type;
    private String uri;

    @Override
    public String toString() {
        return this.name;
    }

}
