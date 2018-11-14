package sonq.app.songq.Fragments;

import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.preference.PreferenceManager;
import android.support.v7.widget.CardView;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Common.Constants;
import sonq.app.songq.Interfaces.ICompletedPlaySongPreview;
import sonq.app.songq.Interfaces.IPlaySongPreviewView;
import sonq.app.songq.Interfaces.ISearchSongsView;
import sonq.app.songq.Models.SpotifyAPIModels.SearchResponseModel;
import sonq.app.songq.Models.SpotifyAPIModels.SearchResult;
import sonq.app.songq.Activity.PartyActivity;
import sonq.app.songq.Adapter.QueueAdapter;
import sonq.app.songq.Models.SpotifyAPIModels.Song;
import sonq.app.songq.Models.SpotifyAPIModels.SongList;
import sonq.app.songq.Presenters.PlaySongPreviewPresenter;
import sonq.app.songq.R;


public class FragmentQueue extends Fragment implements
        ICompletedPlaySongPreview, ISearchSongsView {

    private RecyclerView mRecyclerView;
    private QueueAdapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;
    private CardView playPreviewContainer;

    private PlaySongPreviewFragment playSongPreviewFragment = null;
    private FrameLayout progressBarFrameLayout = null;
    private ProgressBar progressBar = null;

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
        playPreviewContainer = getView().findViewById(R.id.cv_playPreviewContainer);
        mLayoutManager = new LinearLayoutManager(getContext());
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setHasFixedSize(false);
        mRecyclerView.addItemDecoration(new DividerItemDecoration(getContext(), LinearLayoutManager.VERTICAL));
        mAdapter = new QueueAdapter(this);
        mRecyclerView.setAdapter(mAdapter);
        cloudAPI = CloudAPI.getCloudAPI();
        deviceID = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
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
            /* Disable preview, not sure if using?
            if (this.mAdapter != null) {
                if (song != null && song.getPreviewURL() != null && !TextUtils.isEmpty(song.getPreviewURL())) {

                    IPlaySongPreviewView playSongPreviewView = this.getPlaySongPreviewView();
                    if (playSongPreviewView == null) {

                        HashMap<String, Serializable> data = new HashMap<>();
                        data.put(Constants.PREVIEW_TRACK_URL, song.getPreviewURL());
                        data.put(Constants.TRACK_NAME, song.getName());
                        data.put(Constants.TRACK_ARTIST, song.getArtist());

                        playSongPreviewView = this.showPlaySongPreviewView(data);
                    } else {

                        PlaySongPreviewPresenter playSongPreviewPresenter = playSongPreviewView.getPresenterInstance();
                        if (playSongPreviewPresenter != null) {
                            playSongPreviewPresenter.setSong(song.getPreviewURL(), song.getName(), song.getArtist());
                        }
                    }
                    playSongPreviewView.setOnCompletedPlaySongPreviewListener(this);
                }
            }*/
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

    @Override
    public void closePlaySongPreview() {
        this.hidePlaySongPreviewView();
    }

    @Override
    public void showProgressBar() {
        if (progressBarFrameLayout != null) {
            progressBarFrameLayout.setVisibility(View.VISIBLE);
        }
        if (progressBar != null) {
            progressBar.setIndeterminate(true);
        }
    }

    @Override
    public void hideProgressBar() {
        if (progressBarFrameLayout != null) {
            progressBarFrameLayout.setVisibility(View.INVISIBLE);
        }
    }

    @Override
    public IPlaySongPreviewView showPlaySongPreviewView(HashMap<String, Serializable> bundleArguments) {
        if (playPreviewContainer != null) {
            playPreviewContainer.setVisibility(View.VISIBLE);
        }
        playSongPreviewFragment = new PlaySongPreviewFragment();
        if (bundleArguments != null) {
            Bundle arguments = new Bundle();
            arguments.putSerializable(Constants.PREVIEW_TRACK_URL, bundleArguments.get(Constants.PREVIEW_TRACK_URL));
            arguments.putSerializable(Constants.TRACK_NAME, bundleArguments.get(Constants.TRACK_NAME));
            arguments.putSerializable(Constants.TRACK_ARTIST, bundleArguments.get(Constants.TRACK_ARTIST));
            playSongPreviewFragment.setArguments(arguments);
        }

        FragmentManager fm = getActivity().getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();
        ft.replace(R.id.cv_playPreviewContainer, playSongPreviewFragment);
        ft.commit();

        return playSongPreviewFragment;
    }

    @Override
    public void hidePlaySongPreviewView() {
        FragmentManager fm = getActivity().getSupportFragmentManager();
        if (playSongPreviewFragment != null && fm != null) {
            fm.beginTransaction().remove(playSongPreviewFragment).commit();
        }
        if (playPreviewContainer != null) {
            playPreviewContainer.setVisibility(View.GONE);
        }
        playSongPreviewFragment = null;
    }

    @Override
    public IPlaySongPreviewView getPlaySongPreviewView() {
        return playSongPreviewFragment;
    }
}
