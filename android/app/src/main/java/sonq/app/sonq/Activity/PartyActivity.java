package sonq.app.sonq.Activity;

import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.preference.PreferenceManager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.aurelhubert.ahbottomnavigation.AHBottomNavigation;
import com.aurelhubert.ahbottomnavigation.AHBottomNavigationItem;

import java.io.IOException;

import pl.droidsonroids.gif.GifDrawable;
import pl.droidsonroids.gif.GifImageView;
import pl.droidsonroids.gif.GifTexImage2D;
import sonq.app.sonq.API.CloudAPI;
import sonq.app.sonq.API.GenericCallback;
import sonq.app.sonq.API.SpotifyAPI;
import sonq.app.sonq.Adapter.BottomBarAdapter;
import sonq.app.sonq.Adapter.NoSwipePager;
import sonq.app.sonq.Fragments.FragmentPlayer;
import sonq.app.sonq.Fragments.FragmentQRCode;
import sonq.app.sonq.Fragments.FragmentQueue;
import sonq.app.sonq.Fragments.FragmentSettings;
import sonq.app.sonq.R;

public class PartyActivity extends AppCompatActivity {

    private String deviceID;
    private AHBottomNavigation navigation;
    private AlertDialog.Builder alertDialogBuilder;
    private AlertDialog leavePartyDialog;
    private SharedPreferences settings;
    private NoSwipePager viewPager;

    private FragmentQueue fragmentQueue;
    private FragmentQRCode fragmentQRCode;
    private FragmentPlayer fragmentPlayer;
    private FragmentSettings fragmentSettings;

    public static SpotifyAPI spotifyAPI;
    public static boolean isHost;
    private CloudAPI cloudAPI;

    private String token;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_party);
        deviceID = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
        cloudAPI = CloudAPI.getCloudAPI();
        settings = PreferenceManager.getDefaultSharedPreferences(this);
        final SharedPreferences.Editor settingsEditor = settings.edit();

        isHost = getIntent().getBooleanExtra("isHost", false);

        token = getIntent().getStringExtra("token");
        spotifyAPI = new SpotifyAPI(token);

        // Log user info, set username. Only works for party host
        if (isHost) {
            spotifyAPI.getUsername(new GenericCallback<String>() {
                @Override
                public void onValue(String username) {
                    // Get first name
                    username = username.split(" ")[0];
                    settingsEditor.putString("username_preference", username);
                    settingsEditor.apply();

                    cloudAPI.updateUsername(deviceID, username);
                }
            });
        }

        viewPager = findViewById(R.id.viewpager);
        viewPager.setPagingEnabled(false);
        viewPager.setOffscreenPageLimit(4);
        setupViewPager(viewPager);


        navigation = findViewById(R.id.navigation);
        addButtons(navigation);
        navigation.setOnTabSelectedListener(new AHBottomNavigation.OnTabSelectedListener() {
            @Override
            public boolean onTabSelected(int position, boolean wasSelected) {
                if (!wasSelected) {
                    viewPager.setCurrentItem(position);
                }
                switch (position) {
                    case 0:
                        setTitle(R.string.title_queue);
                        notifyQueueChanged(true);
                        return true;
                    case 1:
                        if (isHost) {
                            setTitle(R.string.title_player);
                        } else {
                            setTitle(R.string.title_qr_code);
                        }
                        return true;
                    case 2:
                        if (isHost) {
                            setTitle(R.string.title_qr_code);
                        } else {
                            setTitle(R.string.title_settings);
                        }
                        return true;
                    case 3:
                        setTitle(R.string.title_settings);
                        return true;
                }
                return  false;
            }
        });
        navigation.setBehaviorTranslationEnabled(true);
        navigation.setTitleState(AHBottomNavigation.TitleState.ALWAYS_SHOW);
        navigation.setDefaultBackgroundColor(getColor(R.color.background_material_dark));
        navigation.setAccentColor(getColor(R.color.colorAccent));

        setupAlertDialog();

        String partyID = getIntent().getStringExtra("partyID");
        String username_extra = getIntent().getStringExtra("username");
        if (username_extra != null) {
            settingsEditor.putString("username_preference", username_extra);
            cloudAPI.updateUsername(deviceID, username_extra);
        }
        settingsEditor.putString("party_id_preference", partyID);
        settingsEditor.apply();
        setTitle(R.string.title_queue);
    }

    private void addButtons(AHBottomNavigation navigation) {
        AHBottomNavigationItem queue = new AHBottomNavigationItem(
                getString(R.string.title_queue), getDrawable(R.drawable.ic_queue_music_black_24dp));
        AHBottomNavigationItem player = new AHBottomNavigationItem(
                getString(R.string.title_player), getDrawable(R.drawable.ic_play_arrow_black_24dp));
        AHBottomNavigationItem qrCode = new AHBottomNavigationItem(
                getString(R.string.title_qr_code), getDrawable(R.drawable.ic_qrcode));
        AHBottomNavigationItem settings = new AHBottomNavigationItem(
                getString(R.string.title_settings), getDrawable(R.drawable.ic_settings_black_24dp));

        navigation.addItem(queue);
        if (isHost) {
            // Could enable this still and have no controls for guests? Just the progress bar?
            navigation.addItem(player);
        }
        navigation.addItem(qrCode);
        navigation.addItem(settings);
    }

    private void setupViewPager(NoSwipePager viewPager) {
        BottomBarAdapter viewPagerAdapter = new BottomBarAdapter(getSupportFragmentManager());
        fragmentQueue = new FragmentQueue();
        fragmentQRCode = new FragmentQRCode();
        fragmentPlayer = new FragmentPlayer();
        fragmentSettings = new FragmentSettings();
        viewPagerAdapter.addFragments(fragmentQueue);
        if (isHost) {
            viewPagerAdapter.addFragments(fragmentPlayer);
        }
        viewPagerAdapter.addFragments(fragmentQRCode);
        viewPagerAdapter.addFragments(fragmentSettings);
        viewPager.setAdapter(viewPagerAdapter);
    }

    private void setupAlertDialog() {
        alertDialogBuilder = new AlertDialog.Builder(PartyActivity.this);
        alertDialogBuilder.setTitle(R.string.leave_party_title);
        alertDialogBuilder.setMessage(R.string.leave_party_msg);
        alertDialogBuilder.setCancelable(true);

        alertDialogBuilder.setPositiveButton(
                android.R.string.yes,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        finish();
                    }
                });

        alertDialogBuilder.setNegativeButton(
                android.R.string.no,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });
        alertDialogBuilder.setIcon(android.R.drawable.ic_dialog_alert);
        leavePartyDialog = alertDialogBuilder.create();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        leavePartyDialog.show();
    }

    public String getToken() {
        return token;
    }

    public void notifyQueueChanged(boolean runAnimation) {
        fragmentQueue.notifyQueueChanged(runAnimation);
    }
}