package sonq.app.songq.Fragments;

import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.SpotifyAPIModels.Song;
import sonq.app.songq.R;

import com.spotify.sdk.android.player.Config;
import com.spotify.sdk.android.player.Error;
import com.spotify.sdk.android.player.Player;
import com.spotify.sdk.android.player.PlayerEvent;
import com.spotify.sdk.android.player.Spotify;
import com.spotify.sdk.android.player.SpotifyPlayer;


public class FragmentPlayer extends Fragment implements Player.NotificationCallback
{

    private CloudAPI cloudAPI;
    private String deviceID;
    private String partyID;

    private Song song;
    private int previousMs = 0;

    private ImageView playButton;
    private TextView tv_name;
    private TextView tv_artist;
    private ImageView albumArtwork;
    private SpotifyPlayer mediaPlayer;

    private String token;

    public FragmentPlayer() { }
    public FragmentPlayer(String tk) { token = tk; }

    private final Player.OperationCallback mOperationCallback = new Player.OperationCallback() {
        @Override
        public void onSuccess() { }

        @Override
        public void onError(Error error) { }
    };

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.player_view, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        cloudAPI = CloudAPI.getCloudAPI();
        deviceID = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
        partyID = PreferenceManager.getDefaultSharedPreferences(getContext())
                .getString("party_id_preference", "");

        tv_name = getView().findViewById(R.id.tv_previewName);
        tv_artist = getView().findViewById(R.id.tv_previewArtist);
        albumArtwork = getView().findViewById(R.id.albumArtwork);
        playButton = getView().findViewById(R.id.iv_play);
        playButton.setOnClickListener(onClickPlayListener);
        initializePlayer();

        if (song == null) {
            setNextSong(false);
        }
    }

    private void initializePlayer() {
        if (mediaPlayer == null) {
            Config playerConfig = new Config(getContext(), token, "3dcb2de0605f45139b2ab9168eece07d");
            mediaPlayer = SpotifyPlayer.create(playerConfig);
        } else {
            mediaPlayer.login(token);
        }
        mediaPlayer.addNotificationCallback(FragmentPlayer.this);
    }

    private void setNextSong(final boolean playAfter) {
        cloudAPI.getNextSong(partyID, new GenericCallback<Song>() {
            @Override
            public void onValue(final Song nextSong) {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        song = nextSong;
                        if (song != null) {
                            tv_name.setText(song.getName());
                            tv_artist.setText(song.getArtist());
                            // TODO: Set an album image on the player

                            if (playAfter) {
                                onClickPlayListener.onClick(getView());
                            }
                        } else {
                            pausePlayer();
                        }
                    }
                });

            }
        });
    }

    public void pausePlayer() {
        playButton.setImageResource(R.drawable.ic_play_arrow_white_24dp);
        previousMs = (int) mediaPlayer.getPlaybackState().positionMs;
        mediaPlayer.pause(mOperationCallback);
    }

    public void startPlayer() {
        playButton.setImageResource(R.drawable.ic_pause_white_24dp);
        if (previousMs != 0) {
            mediaPlayer.resume(mOperationCallback);
        } else {
            mediaPlayer.playUri(mOperationCallback, song.getSongURL(), 0, previousMs);
        }
        previousMs = 0;
    }

    private View.OnClickListener onClickPlayListener  = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            if (song != null) {
                if (mediaPlayer == null) {
                    initializePlayer();
                }

                if (mediaPlayer.getPlaybackState().isPlaying) {
                    pausePlayer();
                    return;
                }

                if (song.getSongURL() != null) {
                    startPlayer();
                }
            } else {
                setNextSong(true);
            }
        }
    };

    @Override
    public void onDestroy() {
        Spotify.destroyPlayer(this);
        super.onDestroy();
    }

    @Override
    public void onPlaybackEvent(PlayerEvent playerEvent) {
        switch (playerEvent) {
            case kSpPlaybackNotifyAudioDeliveryDone:
                cloudAPI.deleteSong(song, new GenericCallback() {
                    @Override
                    public void onValue(Object value) {
                        setNextSong(true);
                    }
                });
                break;
        }
    }

    @Override
    public void onPlaybackError(Error error) { }
}