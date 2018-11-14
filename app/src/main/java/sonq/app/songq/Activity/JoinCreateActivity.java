package sonq.app.songq.Activity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import net.glxn.qrgen.android.QRCode;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.R;

public class JoinCreateActivity extends AppCompatActivity implements  View.OnClickListener {

    private Button joinPartyButton, createPartyButton;
    private EditText usernameInput, partyIDInput;
    private Toast toast;
    private CloudAPI cloudAPI;

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
                        cloudAPI.joinParty(partyID, new GenericCallback<Boolean>() {
                            @Override
                            public void onValue(Boolean partyExists) {
                                if (partyExists) {
                                    startActivity(
                                            new Intent(JoinCreateActivity.this, PartyActivity.class)
                                                    .putExtra("partyID", partyID)
                                                    .putExtra("username", username)
                                    );
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
