package sonq.app.songq.Fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.List;

import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.SearchResponseModel;
import sonq.app.songq.Models.Song;
import sonq.app.songq.Activity.PartyActivity;
import sonq.app.songq.Adapter.QueueAdapter;
import sonq.app.songq.R;


public class FragmentQueue extends Fragment {

    private RecyclerView mRecyclerView;
    private QueueAdapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;

    private List<Song> songs = new ArrayList<>();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        setHasOptionsMenu(true);
        return inflater.inflate(R.layout.queue_view, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        mRecyclerView = getView().findViewById(R.id.queue_recycler_view);
        mLayoutManager = new LinearLayoutManager(getContext());
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setItemAnimator(new DefaultItemAnimator());
        mRecyclerView.setHasFixedSize(false);
        mRecyclerView.addItemDecoration(new DividerItemDecoration(getContext(), LinearLayoutManager.VERTICAL));
        mAdapter = new QueueAdapter(songs);
        mRecyclerView.setAdapter(mAdapter);
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
                return false;
            }
            @Override
            public boolean onQueryTextChange(String query) {
                System.out.println("Change");
                if (query != null && !query.isEmpty()) {
                    PartyActivity.spotifyAPI.search(query, new GenericCallback<SearchResponseModel>() {
                        @Override
                        public void onValue(SearchResponseModel value) {
                            updateSearch(value);
                        }
                    });
                } else {
                    updateSearch(null);
                }
                return false;
            }
        });

        search.setOnActionExpandListener(new MenuItem.OnActionExpandListener() {
            @Override
            public boolean onMenuItemActionExpand(MenuItem item) {
                return true;
            }

            @Override
            public boolean onMenuItemActionCollapse(MenuItem item) {
                returnToQueue();
                return true;
            }
        });
    }

    private void updateSearch(SearchResponseModel searchResponseModel) {
        if (searchResponseModel != null) {
            songs = searchResponseModel.getTracks().getSongList();
            if (songs != null && !songs.isEmpty()) {
                Log.i("search", "Size: " + songs.size());
                Log.i("search", "First result -> " + songs.get(0).toString());
            }
        } else {
            Log.i("search", "No results");
            songs.clear();
        }
        // Update recycler view
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mAdapter.update(songs);
            }
        });
    }

    private void returnToQueue() {
        // Fetch queue here
        songs = new ArrayList<Song>();
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mAdapter.update(songs);
            }
        });
    }

}
