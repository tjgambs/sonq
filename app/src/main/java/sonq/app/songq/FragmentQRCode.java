package sonq.app.songq;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import net.glxn.qrgen.android.QRCode;

public class FragmentQRCode extends Fragment {

    private ImageView imageView;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.qr_code_view, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        Bitmap bitmap = QRCode.from(PartyActivity.PARTY_ID)
                .withSize(250, 250)
                .bitmap();

        imageView = getView().findViewById(R.id.QRimageView);
        imageView.setImageBitmap(bitmap);
    }

}
