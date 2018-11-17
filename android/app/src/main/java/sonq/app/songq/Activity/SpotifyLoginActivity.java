package sonq.app.songq.Activity;

import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;

import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.authentication.AuthenticationClient;
import android.content.Intent;
import android.util.Log;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;

public class SpotifyLoginActivity extends AppCompatActivity {

    private static final int REQUEST_CODE = 1337;
    private static final String CLIENT_ID = "3dcb2de0605f45139b2ab9168eece07d";
    private static final String REDIRECT_URI = "sonq.app.songq://login";
    private CloudAPI cloudAPI;
    private String partyID;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        cloudAPI = CloudAPI.getCloudAPI();
        partyID = getIntent().getStringExtra("partyID");
        AuthenticationRequest.Builder builder = new AuthenticationRequest.Builder(
                CLIENT_ID, AuthenticationResponse.Type.TOKEN, REDIRECT_URI);
        builder.setScopes(new String[]{"streaming"});
        AuthenticationRequest request = builder.build();
        AuthenticationClient.openLoginActivity(this, REQUEST_CODE, request);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        // Check if result comes from the correct activity
        if (requestCode == REQUEST_CODE) {
            final AuthenticationResponse response = AuthenticationClient.getResponse(resultCode, intent);

            switch (response.getType()) {
                // Response was successful and contains auth token
                case TOKEN:
                    // Create a new party
                    if (partyID != null) {
                        startActivity(
                                new Intent(SpotifyLoginActivity.this, PartyActivity.class)
                                        .putExtra("token", response.getAccessToken())
                                        .putExtra("partyID", partyID)
                                        .putExtra("isHost", true)
                        );
                    } else {
                        cloudAPI.createParty(Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID)
                                , new GenericCallback<String>() {
                                    @Override
                                    public void onValue(String partyID) {
                                        if (partyID != null) {
                                            startActivity(
                                                    new Intent(SpotifyLoginActivity.this, PartyActivity.class)
                                                            .putExtra("token", response.getAccessToken())
                                                            .putExtra("partyID", partyID)
                                                            .putExtra("isHost", true)
                                            );
                                        }
                                    }
                                });
                    }
                    finish();
                    // Handle successful response
                    break;

                // Auth flow returned an error
                case ERROR:
                    // Handle error response
                    Log.e("SpotifyLoginActivity", "Authentication Failed - " + response.getError());
                    finish();
                    break;

                // Most likely auth flow was cancelled
                default:
                    finish();
                    // Handle other cases
            }
        }
    }
}