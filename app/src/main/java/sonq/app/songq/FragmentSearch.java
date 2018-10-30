package sonq.app.songq;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.widget.SearchView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import java.util.Timer;

public class FragmentSearch extends Fragment {

    private String accessToken;
    private Timer updateAuthTimer;

    private void updateAuth() {
         headers = ["Authorization": "Basic MzYyZmM1YmRkMGQ1NDYxNDk5Y2NmNmU0ZTc0ODM4MDA6ODhiNGNlOWVhMTQ2NDdjOTlkOGI0YjU3MGYxYTk5OGE="];
        let para = ["grant_type": "client_credentials"];
        String url = "https://accounts.spotify.com/api/token";

    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        setHasOptionsMenu(true);
        return inflater.inflate(R.layout.search_view, container, false);
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
                String keywords = query.replace(" ", "+");
                String searchURL = String.format("https://api.spotify.com/v1/search?q=%s&type=track", keywords);

                return false;
            }
            @Override
            public boolean onQueryTextChange(String s) {
                System.out.println("Change");
                return false;
            }
        });
    }

}
