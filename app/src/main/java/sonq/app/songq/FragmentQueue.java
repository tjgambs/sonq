package sonq.app.songq;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sonq.app.songq.entites.Song;

import java.util.ArrayList;

public class FragmentQueue extends Fragment {

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        setHasOptionsMenu(true);
        return inflater.inflate(R.layout.queue_view, container, false);
    }

    @Override
    public void onCreateOptionsMenu (Menu menu, MenuInflater inflater){
        inflater.inflate(R.menu.search, menu);
        final MenuItem search = menu.findItem(R.id.action_search);
        final SearchView searchView = (SearchView) search.getActionView();
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                System.out.println("Submit");
                search.collapseActionView();
                PartyActivity.spotifyAPI.search(query);
                return false;
            }
            @Override
            public boolean onQueryTextChange(String query) {
                System.out.println("Change");
                PartyActivity.spotifyAPI.search(query);
                return false;
            }
        });
    }

    public static void updateSearch(JSONObject jsonObject) {
        try {
            final JSONArray items = jsonObject.getJSONObject("tracks").getJSONArray("items");
            ArrayList songs = new ArrayList<Song>();
            for (int i = 0; i < items.length(); i++) {
                songs.add(new Song(items.getJSONObject(i)));
            }
            if (!songs.isEmpty()) {
                Log.i("search", "First result -> " + songs.get(0).toString());
            }
        } catch (JSONException e) {
            Log.e("search","updateSearch failed");
        }
    }

}
