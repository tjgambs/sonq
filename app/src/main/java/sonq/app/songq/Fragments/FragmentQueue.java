package sonq.app.songq.Fragments;

import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.preference.PreferenceManager;
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
import android.widget.Toast;

import com.aurelhubert.ahbottomnavigation.AHBottomNavigation;

import java.util.List;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.SpotifyAPIModels.SearchResponseModel;
import sonq.app.songq.Activity.PartyActivity;
import sonq.app.songq.Adapter.QueueAdapter;
import sonq.app.songq.Models.SpotifyAPIModels.Song;
import sonq.app.songq.Models.SpotifyAPIModels.SongList;
import sonq.app.songq.R;


public class FragmentQueue extends Fragment {

    private RecyclerView mRecyclerView;
    private QueueAdapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;
    private AHBottomNavigation navigation;

    private CloudAPI cloudAPI;
    private String deviceID;
    private String partyID;
    private boolean searchOpen = false;

    private Toast toast;

    public void showAToast (String message) {
        if (toast != null) {
            toast.cancel();
        }
        toast = Toast.makeText(getContext(), message, Toast.LENGTH_SHORT);
        toast.show();
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        setHasOptionsMenu(true);
        return inflater.inflate(R.layout.queue_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mRecyclerView = getView().findViewById(R.id.queue_recycler_view);
        mLayoutManager = new LinearLayoutManager(getContext());
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setHasFixedSize(false);
        mRecyclerView.addItemDecoration(new DividerItemDecoration(getContext(), LinearLayoutManager.VERTICAL));
        mAdapter = new QueueAdapter(this);
        mRecyclerView.setAdapter(mAdapter);
        cloudAPI = CloudAPI.getCloudAPI();
        deviceID = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
        navigation = view.getRootView().findViewById(R.id.navigation);
        partyID = PreferenceManager.getDefaultSharedPreferences(getContext())
                    .getString("party_id_preference", "");
        returnToQueue();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
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
                searchOpen = true;
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

    public void onClickedSong(Song song) {
        if (searchOpen) {
            cloudAPI.addSong(partyID, deviceID, song, new GenericCallback<Boolean>() {
                @Override
                public void onValue(Boolean success) {
                    if (success) {
                        Log.d("onClickedSong", "Song added to queue!");
                    } else {
                        getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                showAToast("Song already in queue!");
                            }
                        });
                    }
                }
            });
        }
    }

    private void updateSearch(SearchResponseModel searchResponseModel) {
        if (searchResponseModel != null) {
            final List<Song> songs = new SongList(searchResponseModel.getTracks().getSongList()).getSongList();
            if (songs != null && !songs.isEmpty()) {
                // Update recycler view
                cloudAPI.checkInQueue(partyID, songs, new GenericCallback<List<Integer>>() {
                    @Override
                    public void onValue(List<Integer> songsInQueue) {
                        for (int idx : songsInQueue) {
                            songs.get(idx).setInQueue(true);
                        }
                        getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mAdapter.update(songs, true, mRecyclerView);
                            }
                        });
                    }
                });
            }
        } else {
            Log.i("search", "No results");
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mAdapter.update(null, true, mRecyclerView);
                }
            });
        }
    }

    private void returnToQueue() {
        // Fetch queue here
        navigation.restoreBottomNavigation();
        searchOpen = false;
        cloudAPI.getQueue(partyID, new GenericCallback<List<Song>>() {
            @Override
            public void onValue(final List<Song> songs) {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mAdapter.update(songs, false, mRecyclerView);
                    }
                });
            }
        });
    }

}
