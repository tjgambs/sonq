package sonq.app.songq.api;

import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okio.BufferedSink;
import sonq.app.songq.PartyActivity;

import java.io.IOException;
import android.util.Log;


public class SpotifyAPI {

    private final String BASIC_TOKEN = "MWRmMjFiMzc1MDQ2NDg3NThlNjY1NDhiN2FhMTVlMTE6ZDkxMzBmOGNmMjQxNDU1Nzk2ZDJhNjA4YmIwZGEzN2U=";
    private String token;

    private final OkHttpClient mOkHttpClient = new OkHttpClient();
    private Call mCall;

    public SpotifyAPI(String token) {
        if (token == null) {
            getBasicToken();
        }
        else {
            this.token = token;
        }
    }

    public void search(String query) {
        String keywords = query.replace(" ", "+");
        String searchURL = String.format("https://api.spotify.com/v1/search?q=%s&type=track", keywords);
        final Request request = new Request.Builder()
                .url(searchURL)
                .addHeader("Authorization","Bearer " + this.token)
                .build();

        this.mCall = this.mOkHttpClient.newCall(request);

        this.mCall.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("search", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    final JSONObject jsonObject = new JSONObject(response.body().string());
                    Log.i("search", jsonObject.toString(3));
                } catch (JSONException e) {
                    Log.e("search", "Failed to parse data: " + e);
                }
            }
        });
    }

    public void onGetUserProfileClicked(final GenericCallback<String> callback) {
        final Request request = new Request.Builder()
                .url("https://api.spotify.com/v1/me")
                .addHeader("Authorization","Bearer " + this.token)
                .build();

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
                    String username = jsonObject.getString("display_name");
                    callback.onValue(username);
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

    private void getBasicToken() {
        RequestBody formBody = new FormBody.Builder()
                .add("grant_type", "client_credentials")
                .build();
        final Request request = new Request.Builder()
                .url("https://accounts.spotify.com/api/token")
                .addHeader("Authorization","Basic " + BASIC_TOKEN)
                .post(formBody)
                .build();

        this.mCall = this.mOkHttpClient.newCall(request);

        this.mCall.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("getBasicToken", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    final JSONObject jsonObject = new JSONObject(response.body().string());
                    Log.i("getBasicToken", jsonObject.toString(3));
                    token = jsonObject.getString("access_token");
                } catch (JSONException e) {
                    Log.e("getBasicToken", "Failed to parse data: " + e);
                }
            }
        });
    }
}