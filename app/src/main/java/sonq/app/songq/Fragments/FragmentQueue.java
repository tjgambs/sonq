package sonq.app.songq.Fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Common.Constants;
import sonq.app.songq.Interfaces.ICompletedPlaySongPreview;
import sonq.app.songq.Interfaces.IPlaySongPreviewView;
import sonq.app.songq.Interfaces.ISearchSongsView;
import sonq.app.songq.Models.SearchResponseModel;
import sonq.app.songq.Models.SearchResult;
import sonq.app.songq.Activity.PartyActivity;
import sonq.app.songq.Adapter.QueueAdapter;
import sonq.app.songq.Models.Song;
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

    private List<SearchResult> songs = new ArrayList<>();

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
        playPreviewContainer = getView().findViewById(R.id.cv_playPreviewContainer);
        mLayoutManager = new LinearLayoutManager(getContext());
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setItemAnimator(new DefaultItemAnimator());
        mRecyclerView.setHasFixedSize(false);
        mRecyclerView.addItemDecoration(new DividerItemDecoration(getContext(), LinearLayoutManager.VERTICAL));
        mAdapter = new QueueAdapter(songs, this);
        mRecyclerView.setAdapter(mAdapter);
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

    public void onClickedPlayPreview(Song song) {
        if (this.mAdapter != null) {
            if (song != null && song.preview_url != null && !TextUtils.isEmpty(song.preview_url)) {

                IPlaySongPreviewView playSongPreviewView = this.getPlaySongPreviewView();
                if (playSongPreviewView == null) {

                    HashMap<String, Serializable> data = new HashMap<>();
                    data.put(Constants.PREVIEW_TRACK_URL, song.preview_url);
                    data.put(Constants.TRACK_NAME, song.name);
                    data.put(Constants.TRACK_ARTIST, song.artist);

                    playSongPreviewView = this.showPlaySongPreviewView(data);
                } else {

                    PlaySongPreviewPresenter playSongPreviewPresenter = playSongPreviewView.getPresenterInstance();
                    if (playSongPreviewPresenter != null) {
                        playSongPreviewPresenter.setSong(song.preview_url, song.name, song.artist);
                    }
                }
                playSongPreviewView.setOnCompletedPlaySongPreviewListener(this);
            }
        }
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
        songs = new ArrayList<>();
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mAdapter.update(songs);
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
