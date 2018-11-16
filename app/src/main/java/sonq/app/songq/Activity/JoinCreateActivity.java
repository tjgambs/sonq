package sonq.app.songq.Activity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import net.glxn.qrgen.android.QRCode;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.CloudAPIModels.GenericCloudResponse;
import sonq.app.songq.Models.CloudAPIModels.JoinPartyResponse;
import sonq.app.songq.R;

public class JoinCreateActivity extends AppCompatActivity implements  View.OnClickListener {

    private Button joinPartyButton, createPartyButton;
    private EditText usernameInput, partyIDInput;
    private Toast toast;
    private CloudAPI cloudAPI;
    private String deviceID;

    public void showAToast (String message) {
        if (toast != null) {
            toast.cancel();
        }
        toast = Toast.makeText(this, message, Toast.LENGTH_SHORT);
        toast.show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_join_create);
        initViews();
        cloudAPI = CloudAPI.getCloudAPI();
        deviceID = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    private void initViews() {
        usernameInput = findViewById(R.id.userNameInput);
        partyIDInput = findViewById(R.id.partyIDInput);
        joinPartyButton = findViewById(R.id.joinPartyButton);
        createPartyButton = findViewById(R.id.createPartyButton);
        joinPartyButton.setOnClickListener(this);
        createPartyButton.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        final String username = usernameInput.getText().toString();
        final String partyID = partyIDInput.getText().toString();
        switch (v.getId()) {
            case R.id.joinPartyButton:
                if (!username.isEmpty()) {
                    if (partyID.isEmpty()) {
                        // Show QR Scanner
                        startActivity(
                                new Intent(JoinCreateActivity.this, ScanQRCodeActivity.class)
                                        .putExtra("username", username)
                        );
                    } else {
                        cloudAPI.joinParty(partyID, new GenericCallback<GenericCloudResponse<JoinPartyResponse>>() {
                            @Override
                            public void onValue(GenericCloudResponse<JoinPartyResponse> joinPartyResponse) {
                                if (joinPartyResponse.getData().getPartyExists()) {
                                    Log.d("JoinCreateActivity", "deviceID: " + deviceID + " createdBy: " + joinPartyResponse.getData().getCreatedBy());
                                    boolean isHost = deviceID.equals(joinPartyResponse.getData().getCreatedBy());
                                    if (isHost) {
                                        startActivity(
                                                new Intent(JoinCreateActivity.this, SpotifyLoginActivity.class)
                                                        .putExtra("partyID", partyID)
                                        );
                                    } else {
                                        startActivity(
                                                new Intent(JoinCreateActivity.this, PartyActivity.class)
                                                        .putExtra("partyID", partyID)
                                                        .putExtra("username", username)
                                                        .putExtra("isHost", isHost)
                                        );
                                    }
                                } else {
                                    runOnUiThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            showAToast("Party does not exist!");
                                        }
                                    });
                                }
                            }
                        });
                    }
                } else {
                    showAToast("Please enter a name!");
                }
                break;
            case R.id.createPartyButton:
                // Show SpotifyAPI Auth
                startActivity(new Intent(JoinCreateActivity.this, SpotifyLoginActivity.class));
        }
    }
}
