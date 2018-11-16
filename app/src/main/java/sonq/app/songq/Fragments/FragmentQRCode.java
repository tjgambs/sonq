package sonq.app.songq.Fragments;

import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import net.glxn.qrgen.android.QRCode;

import sonq.app.songq.R;

public class FragmentQRCode extends Fragment {

    private ImageView imageView;
    private TextView partyIDTextView;
    private SharedPreferences settings;
    private Bitmap qrCode;
    private String partyID;
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        settings = PreferenceManager.getDefaultSharedPreferences(getContext());
        // Inflate the layout for this fragment
        partyID = settings.getString("party_id_preference", "None");
        if (qrCode == null) {
            qrCode = QRCode.from(partyID)
                    .withSize(250, 250)
                    .bitmap();
        }
        return inflater.inflate(R.layout.qr_code_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        imageView = view.findViewById(R.id.QRimageView);
        partyIDTextView = view.findViewById(R.id.qr_code_party_id);
        imageView.setImageBitmap(qrCode);
        partyIDTextView.setText(partyID);
    }
}
