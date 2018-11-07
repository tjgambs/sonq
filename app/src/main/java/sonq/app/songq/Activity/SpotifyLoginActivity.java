package sonq.app.songq.Activity;

import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;

import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.authentication.AuthenticationClient;
import android.content.Intent;

public class SpotifyLoginActivity extends AppCompatActivity {

    private static final int REQUEST_CODE = 1337;
    private static final String CLIENT_ID = "1df21b37504648758e66548b7aa15e11";
    private static final String REDIRECT_URI = "sonq.app.songq://login";

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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
            AuthenticationResponse response = AuthenticationClient.getResponse(resultCode, intent);

            switch (response.getType()) {
                // Response was successful and contains auth token
                case TOKEN:
                    startActivity(
                            new Intent(SpotifyLoginActivity.this, PartyActivity.class)
                                    .putExtra("token", response.getAccessToken())
                                    .putExtra("partyID", Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID))
                    );
                    finish();
                    // Handle successful response
                    break;

                // Auth flow returned an error
                case ERROR:
                    // Handle error response
                    break;

                // Most likely auth flow was cancelled
                default:
                    // Handle other cases
            }
        }
    }
}