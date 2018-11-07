package sonq.app.songq.Activity;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v7.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;

import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.API.SpotifyAPI;
import sonq.app.songq.Adapter.ViewPagerAdapter;
import sonq.app.songq.Fragments.FragmentPlayer;
import sonq.app.songq.Fragments.FragmentQRCode;
import sonq.app.songq.Fragments.FragmentQueue;
import sonq.app.songq.Fragments.FragmentSettings;
import sonq.app.songq.R;

public class PartyActivity extends AppCompatActivity {

    private ViewPager viewPager;
    private FragmentQueue fragmentQueue;
    private FragmentQRCode fragmentQRCode;
    private FragmentPlayer fragmentPlayer;
    private FragmentSettings fragmentSettings;
    private BottomNavigationView navigation;
    private AlertDialog.Builder alertDialogBuilder;
    private AlertDialog leavePartyDialog;
    private SharedPreferences settings;

    public static SpotifyAPI spotifyAPI;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_party);
        settings = PreferenceManager.getDefaultSharedPreferences(this);
        final SharedPreferences.Editor settingsEditor = settings.edit();

        String token = getIntent().getStringExtra("token");
        spotifyAPI = new SpotifyAPI(token);

        // Log user info, set username
        spotifyAPI.onGetUserProfileClicked(new GenericCallback<String>() {
            @Override
            public void onValue(String value) {
                settingsEditor.putString("username_preference", value);
                settingsEditor.apply();
            }
        });

        navigation = findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        viewPager = findViewById(R.id.viewpager);
        viewPager.addOnPageChangeListener(mOnPageChangeListener);
        setupViewPager(viewPager);

        setupAlertDialog();

        String partyID = getIntent().getStringExtra("partyID");
        String username_extra = getIntent().getStringExtra("username");
        if (username_extra != null) {
            settingsEditor.putString("username_preference", username_extra);
        }
        settingsEditor.putString("party_id_preference", partyID);
        settingsEditor.apply();
        setTitle(R.string.title_queue);
        Log.i("settingsTEST", settings.getString("username_preference", "None"));
        Log.i("settingsTEST", settings.getString("party_id_preference", "None"));
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
    public void onBackPressed() {
        leavePartyDialog.show();
    }

    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter viewPagerAdapter = new ViewPagerAdapter(getSupportFragmentManager());
        fragmentQueue = new FragmentQueue();
        fragmentQRCode = new FragmentQRCode();
        fragmentPlayer = new FragmentPlayer();
        fragmentSettings = new FragmentSettings();
        viewPagerAdapter.addFragment(fragmentQueue);
        viewPagerAdapter.addFragment(fragmentQRCode);
        viewPagerAdapter.addFragment(fragmentPlayer);
        viewPagerAdapter.addFragment(fragmentSettings);
        viewPager.setAdapter(viewPagerAdapter);
    }

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.navigation_queue:
                    viewPager.setCurrentItem(0);
                    setTitle(R.string.title_queue);
                    return true;
                case R.id.navigation_qr_code:
                    viewPager.setCurrentItem(1);
                    setTitle(R.string.title_qr_code);
                    return true;
                case R.id.navigation_player:
                    viewPager.setCurrentItem(2);
                    setTitle(R.string.title_player);
                    return true;
                case R.id.navigation_settings:
                    viewPager.setCurrentItem(3);
                    setTitle(R.string.title_settings);
                    return true;
            }
            return false;
        }
    };

    private ViewPager.OnPageChangeListener mOnPageChangeListener = new ViewPager.OnPageChangeListener() {
        @Override
        public void onPageScrolled(int i, float v, int i1) {

        }

        @Override
        public void onPageSelected(int position) {
            navigation.getMenu().getItem(position).setChecked(true);
            switch (position) {
                case 0:
                    setTitle(R.string.title_queue);
                    break;
                case 1:
                    setTitle(R.string.title_qr_code);
                    break;
                case 2:
                    setTitle(R.string.title_player);
                    break;
                case 3:
                    setTitle(R.string.title_settings);
                    break;
            }
        }

        @Override
        public void onPageScrollStateChanged(int i) {

        }
    };
}