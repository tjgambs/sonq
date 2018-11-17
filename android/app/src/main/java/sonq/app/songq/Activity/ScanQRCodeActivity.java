package sonq.app.songq.Activity;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.SparseArray;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.vision.CameraSource;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;

import java.io.IOException;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.CloudAPIModels.GenericCloudResponse;
import sonq.app.songq.Models.CloudAPIModels.JoinPartyResponse;
import sonq.app.songq.R;
import sonq.app.songq.View.DrawQRRectangle;

public class ScanQRCodeActivity extends AppCompatActivity {

    SurfaceView surfaceView;
    TextView txtBarcodeValue;
    private BarcodeDetector barcodeDetector;
    private CameraSource cameraSource;
    private static final int REQUEST_CAMERA_PERMISSION = 201;
    String partyID = "";
    private RelativeLayout mRelativeLayout;
    private DrawQRRectangle qrRectangle;
    private Toast toast;
    Vibrator v;
    private final long[] VIBRATION_PATTERN = {0, 200, 50, 200};
    private boolean qrCodeFound;
    private String username;
    private CloudAPI cloudAPI;
    private String deviceID;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan_qr_code);

        initViews();
        cloudAPI = CloudAPI.getCloudAPI();

        deviceID = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);

        v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        //add RelativeLayout
        mRelativeLayout = findViewById(R.id.activity_scan_qr_code_layout);

        //add LayoutParams
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);

        qrRectangle = new DrawQRRectangle(this);
        qrRectangle.setLayoutParams(params);
        mRelativeLayout.addView(qrRectangle);

        username = getIntent().getStringExtra("username");
    }

    private void initViews() {
        txtBarcodeValue = findViewById(R.id.txtBarcodeValue);
        surfaceView = findViewById(R.id.surfaceView);
    }

    public void showAToast (String message) {
        if (toast != null) {
            toast.cancel();
        }
        toast = Toast.makeText(this, message, Toast.LENGTH_SHORT);
        toast.show();
    }

    private void createDetectorAndCamera() {

        //Toast.makeText(getApplicationContext(), "Barcode scanner started", Toast.LENGTH_SHORT).show();

        barcodeDetector = new BarcodeDetector.Builder(this)
                .setBarcodeFormats(Barcode.QR_CODE)
                .build();

        cameraSource = new CameraSource.Builder(this, barcodeDetector)
                .setRequestedPreviewSize(1920, 1080)
                .setAutoFocusEnabled(true)
                .setFacing(CameraSource.CAMERA_FACING_BACK)
                .build();

        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                try {
                    surfaceView.setWillNotDraw(false);
                    if (ActivityCompat.checkSelfPermission(ScanQRCodeActivity.this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                        cameraSource.start(surfaceView.getHolder());
                    } else {
                        ActivityCompat.requestPermissions(ScanQRCodeActivity.this, new
                                String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA_PERMISSION);
                    }

                } catch (IOException e) {
                    e.printStackTrace();
                }


            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraSource.stop();
            }
        });


        barcodeDetector.setProcessor(new Detector.Processor<Barcode>() {
            @Override
            public void release() {
                //Toast.makeText(getApplicationContext(), "To prevent memory leaks barcode scanner has been stopped", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void receiveDetections(Detector.Detections<Barcode> detections) {
                final SparseArray<Barcode> qrCodes = detections.getDetectedItems();
                if (qrCodes.size() != 0 && !qrCodeFound) {
                    qrCodeFound = true;
                    txtBarcodeValue.post(new Runnable() {

                        @Override
                        public void run() {
                            if (qrCodes.valueAt(0).rawValue != null) {
                                Rect qrCodeBox = qrCodes.valueAt(0).getBoundingBox();
                                qrRectangle.setQRCode(qrCodeBox);
                                qrRectangle.postInvalidate();
                                v.vibrate(VibrationEffect.createWaveform(VIBRATION_PATTERN, -1));
                                txtBarcodeValue.removeCallbacks(null);
                                partyID = qrCodes.valueAt(0).rawValue;
                                txtBarcodeValue.setText(partyID);
                                cloudAPI.joinParty(partyID, new GenericCallback<GenericCloudResponse<JoinPartyResponse>>() {
                                    @Override
                                    public void onValue(GenericCloudResponse<JoinPartyResponse> joinPartyResponse) {
                                        if (joinPartyResponse.getData().getPartyExists()) {
                                            boolean isHost = deviceID.equals(joinPartyResponse.getData().getCreatedBy());
                                            startActivity(
                                                    new Intent(ScanQRCodeActivity.this, PartyActivity.class)
                                                            .putExtra("partyID", partyID)
                                                            .putExtra("username", username)
                                                            .putExtra("isHost", isHost)
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
                                // Finish for now. TODO: Reset view so it can scan again
                                finish();
                            }
                        }
                    });

                }
            }
        });
    }


    @Override
    protected void onPause() {
        super.onPause();
        cameraSource.release();
    }

    @Override
    protected void onResume() {
        super.onResume();
        createDetectorAndCamera();
        resetView();
    }

    private void resetView() {
        qrCodeFound = false;
        qrRectangle.setQRCode(null);
        txtBarcodeValue.setText(R.string.scan_qr_code);
    }


}
