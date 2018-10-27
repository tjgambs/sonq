package sonq.app.songq.api;

import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.IOException;
import android.util.Log;


public class SpotifyAPI {

    private String token;

    private final OkHttpClient mOkHttpClient = new OkHttpClient();
    private Call mCall;


    public SpotifyAPI(String token) {
        this.token = token;
    }

    public void onGetUserProfileClicked() {
        final Request request = new Request.Builder()
                .url("https://api.spotify.com/v1/me")
                .addHeader("Authorization","Bearer " + this.token)
                .build();

        this.cancelCall();
        this.mCall = this.mOkHttpClient.newCall(request);

        this.mCall.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("onGetUserProfileClicked", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    final JSONObject jsonObject = new JSONObject(response.body().string());
                    Log.i("onGetUserProfileClicked", jsonObject.toString(3));
                } catch (JSONException e) {
                    Log.e("onGetUserProfileClicked", "Failed to parse data: " + e);
                }
            }
        });
    }

    private void cancelCall() {
        if (this.mCall != null) {
            this.mCall.cancel();
        }
    }
}