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

import net.glxn.qrgen.android.QRCode;

import sonq.app.songq.R;

public class FragmentQRCode extends Fragment {

    private ImageView imageView;
    private SharedPreferences settings;
    private Bitmap qrCode;
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        settings = PreferenceManager.getDefaultSharedPreferences(getContext());
        // Inflate the layout for this fragment
        if (qrCode == null) {
            qrCode = QRCode.from(settings.getString("party_id_preference", "None"))
                    .withSize(250, 250)
                    .bitmap();
        }
        return inflater.inflate(R.layout.qr_code_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        imageView = view.findViewById(R.id.QRimageView);
        imageView.setImageBitmap(qrCode);
    }
}
