package sonq.app.songq;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class JoinCreateActivity extends AppCompatActivity implements  View.OnClickListener {

    Button joinPartyButton, createPartyButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_join_create);
        initViews();
    }

    private void initViews() {
        joinPartyButton = findViewById(R.id.joinPartyButton);
        createPartyButton = findViewById(R.id.createPartyButton);
        joinPartyButton.setOnClickListener(this);
        createPartyButton.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.joinPartyButton:
                // Show QR Scanner
                startActivity(new Intent(JoinCreateActivity.this, ScanQRCodeActivity.class));
                break;
            case R.id.createPartyButton:
                // Show Spotify Auth
                break;
        }
    }
}
