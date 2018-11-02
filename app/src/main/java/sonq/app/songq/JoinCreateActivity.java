package sonq.app.songq;

import android.content.Intent;
import android.graphics.Paint;
import android.support.design.widget.TextInputEditText;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class JoinCreateActivity extends AppCompatActivity implements  View.OnClickListener {

    private Button joinPartyButton, createPartyButton;
    private EditText usernameInput, partyIDInput;
    private Toast toast;

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
        String username = usernameInput.getText().toString();
        String partyID = partyIDInput.getText().toString();
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
                        startActivity(
                                new Intent(JoinCreateActivity.this, PartyActivity.class)
                                        .putExtra("partyID", partyID)
                                        .putExtra("username", username)
                        );
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
