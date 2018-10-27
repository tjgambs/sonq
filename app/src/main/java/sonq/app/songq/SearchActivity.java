package sonq.app.songq;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import sonq.app.songq.api.SpotifyAPI;

public class SearchActivity extends AppCompatActivity {

    private String token;
    private SpotifyAPI spotifyAPI;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.token = getIntent().getStringExtra("token");
        this.spotifyAPI = new SpotifyAPI(this.token);


        // Log the user profile under info
        this.spotifyAPI.onGetUserProfileClicked();
    }
}