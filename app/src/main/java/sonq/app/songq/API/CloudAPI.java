package sonq.app.songq.API;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import sonq.app.songq.Models.CloudAPIModels.AddSongRequest;
import sonq.app.songq.Models.CloudAPIModels.CheckInQueueRequest;
import sonq.app.songq.Models.CloudAPIModels.CheckInQueueResponse;
import sonq.app.songq.Models.CloudAPIModels.CreatePartyRequest;
import sonq.app.songq.Models.CloudAPIModels.CreatePartyResponse;
import sonq.app.songq.Models.CloudAPIModels.GenericCloudResponse;
import sonq.app.songq.Models.CloudAPIModels.GetQueueResponse;
import sonq.app.songq.Models.CloudAPIModels.JoinPartyResponse;
import sonq.app.songq.Models.CloudAPIModels.UpdateUsernameRequest;
import sonq.app.songq.Models.SpotifyAPIModels.Song;

public class CloudAPI {

    private static CloudAPI shared = new CloudAPI();
    private final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    private final String SCHEME = "http";
    private final String HOST = "ec2-18-222-250-104.us-east-2.compute.amazonaws.com";
    private final int PORT = 80;

    private final OkHttpClient mOkHttpClient = new OkHttpClient();
    private Call mCall;

    private final GsonBuilder builder = new GsonBuilder();
    private final Gson gson = builder.create();

    public CloudAPI() { }
    public static CloudAPI getCloudAPI() {
        return shared;
    }

    private void cancelCall(){
        if (mCall != null) {
            mCall.cancel();
        }
    }

    private void postRequest(RequestBody body, String path, Callback callback) {
        final Request request = new Request.Builder()
                .url(new HttpUrl.Builder()
                        .scheme(SCHEME)
                        .host(HOST)
                        .port(PORT)
                        .addPathSegments(path).build())
                .addHeader("Content-Type","application/json")
                .post(body)
                .build();

        cancelCall();
        this.mCall = this.mOkHttpClient.newCall(request);
        this.mCall.enqueue(callback);
    }

    private void getRequest(String path, Callback callback) {
        final Request request = new Request.Builder()
                .url(new HttpUrl.Builder()
                        .scheme(SCHEME)
                        .host(HOST)
                        .port(PORT)
                        .addPathSegments(path).build())
                .build();

        cancelCall();
        this.mCall = this.mOkHttpClient.newCall(request);
        this.mCall.enqueue(callback);
    }

    public void createParty(String deviceID, final GenericCallback<String> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(new CreatePartyRequest(deviceID)));
        String path = "v1/titan/create_party";
        postRequest(body, path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("create_party", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.code() == 409) {
                    Log.e("create_party", "Party Exists");
                    callback.onValue(null);
                }
                else {
                    String json = response.body().string();
                    final GenericCloudResponse<CreatePartyResponse> createPartyResponse = gson.fromJson(
                            json,
                            new TypeToken<GenericCloudResponse<CreatePartyResponse>>(){}.getType()
                    );
                    callback.onValue(createPartyResponse.getData().getPartyID());
                }
            }
        });
    }

    public void updateUsername(String deviceID, String username) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(new UpdateUsernameRequest(username)));
        String path = String.format("v1/titan/update_username/%s", deviceID);

        postRequest(body, path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("update_username", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.code() == 400) {
                    Log.e("update_username", "Device does not exist");
                }
                else if (response.code() == 200){
                    Log.d("update_username", "Username Updated");
                }
            }
        });
    }

    public void joinParty(String partyID, final GenericCallback<Boolean> callback) {
        String path = String.format("v1/titan/join_party/%s", partyID);

        getRequest(path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("join_party", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                String json = response.body().string();
                final GenericCloudResponse<JoinPartyResponse> joinPartyResponse = gson.fromJson(
                        json,
                        new TypeToken<GenericCloudResponse<JoinPartyResponse>>(){}.getType()
                );
                callback.onValue(joinPartyResponse.getData().getPartyExists());
            }
        });
    }

    public void addSong(String partyID, String deviceID, Song song, final GenericCallback<Boolean> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(new AddSongRequest(partyID, deviceID, song)));
        String path = "v1/titan/add_song";

        postRequest(body, path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("addSong", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.code() == 409) {
                    Log.e("addSong", "Song Exists in queue");
                    callback.onValue(false);
                }
                else {
                    callback.onValue(true);
                }
            }
        });
    }

    public void getQueue(String partyID, final GenericCallback<List<Song>> callback) {
        String path = String.format("v1/titan/get_queue/%s", partyID);

        getRequest(path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("getQueue", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                String json = response.body().string();
                final GenericCloudResponse<GetQueueResponse> getQueueResponse = gson.fromJson(
                        json,
                        new TypeToken<GenericCloudResponse<GetQueueResponse>>(){}.getType()
                );
                callback.onValue(getQueueResponse.getData().getQueue());
            }
        });
    }

    public void checkInQueue(String partyID, List<Song> songs, final GenericCallback<List<Integer>> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(new CheckInQueueRequest(songs)));
        String path = String.format("v1/titan/check_in_queue/%s", partyID);

        postRequest(body, path, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e("checkInQueue", "Failed to fetch data: " + e);
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                String json = response.body().string();
                final GenericCloudResponse<CheckInQueueResponse> checkInQueueResponse = gson.fromJson(
                        json,
                        new TypeToken<GenericCloudResponse<CheckInQueueResponse>>(){}.getType()
                );
                callback.onValue(checkInQueueResponse.getData().getInQueue());
            }
        });
    }


}
