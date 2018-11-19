package sonq.app.sonq.Fragments;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.preference.EditTextPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import sonq.app.sonq.API.CloudAPI;
import sonq.app.sonq.R;

public class FragmentSettings extends PreferenceFragmentCompat {

    private String deviceID;

    private SharedPreferences settings;
    private CloudAPI cloudAPI;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        // Load the preferences from an XML resource
        setPreferencesFromResource(R.xml.preferences, rootKey);

        deviceID = Settings.Secure.getString(
                getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
        cloudAPI = CloudAPI.getCloudAPI();

        settings = PreferenceManager.getDefaultSharedPreferences(getContext());
        EditTextPreference partyIDPreference = (EditTextPreference) findPreference("party_id_preference");
        EditTextPreference usernamePreference = (EditTextPreference) findPreference("username_preference");

        setSummary(partyIDPreference, "party_id_preference");
        setSummary(usernamePreference, "username_preference");
    }

    private void setSummary(EditTextPreference preference, final String key) {
        String value = settings.getString(key, "None");
        Log.i("SettingsFragment", "Key: " + key + " Value: " + value);
        preference.setSummary(value);

        preference.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object o) {
                Log.i("SettingsFragment", "onPreferenceChange");
                String newValue = o.toString();
                if (key.equals("username_preference") && newValue.isEmpty()) {
                    Toast toast = Toast.makeText(getContext(), "Name cannot be blank!", Toast.LENGTH_SHORT);
                    toast.show();
                    return true;
                } else {
                    settings.edit().putString(key, newValue).apply();
                    preference.setSummary(newValue);

                    if (key.equals("username_preference")) {
                        cloudAPI.updateUsername(deviceID, newValue);
                    }
                    return true;

                }
            }
        });
    }

}
