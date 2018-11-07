package sonq.app.songq.Fragments;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v7.preference.EditTextPreference;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;
import android.support.v7.preference.PreferenceManager;
import android.util.Log;

import sonq.app.songq.R;

public class FragmentSettings extends PreferenceFragmentCompat {

    private SharedPreferences settings;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        // Load the preferences from an XML resource
        setPreferencesFromResource(R.xml.preferences, rootKey);

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
                settings.edit().putString(key, newValue).apply();
                preference.setSummary(newValue);
                return true;
            }
        });
    }

}
