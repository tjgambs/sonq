package sonq.app.sonq.Fragments;

import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import sonq.app.sonq.API.CloudAPI;
import sonq.app.sonq.API.GenericCallback;
import sonq.app.sonq.Activity.PartyActivity;
import sonq.app.sonq.Models.SpotifyAPIModels.Song;
import sonq.app.sonq.R;
import sonq.app.sonq.Task.DownloadImageTask;

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
    private ImageView skipButton;
    private TextView tv_name;
    private TextView tv_artist;
    private ImageView albumArtwork;
    private SeekBar seekBar;
    private SpotifyPlayer mediaPlayer;
    private PartyActivity partyActivity;
    private boolean songChanged = false;
    private Handler mHandler;

    private String token;

    public FragmentPlayer() { }

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
        partyActivity = (PartyActivity) getActivity();
        deviceID = Settings.Secure.getString(getActivity().getContentResolver(), Settings.Secure.ANDROID_ID);
        partyID = PreferenceManager.getDefaultSharedPreferences(getContext())
                .getString("party_id_preference", "");

        tv_name = getView().findViewById(R.id.tv_previewName);
        tv_artist = getView().findViewById(R.id.tv_previewArtist);
        albumArtwork = getView().findViewById(R.id.albumArtwork);
        seekBar = getView().findViewById(R.id.seekBar);
        playButton = getView().findViewById(R.id.iv_play);
        playButton.setOnClickListener(onClickPlayListener);
        skipButton = getView().findViewById(R.id.iv_skip);
        skipButton.setOnClickListener(onClickSkipListener);
        token = partyActivity.getToken();
        initializePlayer();

        if (song == null) {
            setNextSong(false);
        }

        mHandler = new Handler();
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    double currentPosition = mediaPlayer.getPlaybackState().positionMs;
                    seekBar.setProgress((int) currentPosition);
                } catch (Exception e) { }
                mHandler.postDelayed(this, 1000);
            }
        });

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser && mediaPlayer != null) {
                    mediaPlayer.seekToPosition(mOperationCallback, progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

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
                            seekBar.setMax((int) song.getDurationInSeconds() * 1000);
                            seekBar.setProgress(0);
                            if (song.getThumbnail() == null) {
                                new DownloadImageTask(albumArtwork).execute(song);
                            } else {
                                albumArtwork.setImageBitmap(song.getThumbnail());
                            }
                            songChanged = true;
                            previousMs = 0;
                            if (playAfter) {
                                onClickPlayListener.onClick(getView());
                            }
                        } else {
                            pausePlayer();
                            song = null;
                            seekBar.setMax(1);
                            seekBar.setProgress(0);
                            tv_name.setText("");
                            tv_artist.setText("");
                            albumArtwork.setImageResource(0);
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
        if (song != null) {
            cloudAPI.setPlaying(partyID, song.getSongURL(), false, new GenericCallback<Boolean>() {
                @Override
                public void onValue(Boolean success) {
                    if (success) {
                        partyActivity.notifyQueueChanged(false);
                    }
                }
            });
        }
    }

    public void startPlayer() {
        playButton.setImageResource(R.drawable.ic_pause_white_24dp);
        if (previousMs != 0 && !songChanged) {
            mediaPlayer.resume(mOperationCallback);
        } else {
            songChanged = false;
            mediaPlayer.playUri(mOperationCallback, song.getSongURL(), 0, previousMs);
        }
        previousMs = 0;
        cloudAPI.setPlaying(partyID, song.getSongURL(), true, new GenericCallback<Boolean>() {
            @Override
            public void onValue(Boolean success) {
                if (success) {
                    partyActivity.notifyQueueChanged(false);
                }
            }
        });
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

    private View.OnClickListener onClickSkipListener  = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            if (song != null) {
                if (mediaPlayer.getPlaybackState().isPlaying) {
                    pausePlayer();
                    cloudAPI.deleteSong(song, new GenericCallback<Boolean>() {
                        @Override
                        public void onValue(Boolean success) {
                            if (success) {
                                setNextSong(true);
                                partyActivity.notifyQueueChanged(false);
                            }
                        }
                    });
                } else {
                    cloudAPI.deleteSong(song, new GenericCallback<Boolean>() {
                        @Override
                        public void onValue(Boolean success) {
                            if (success) {
                                setNextSong(false);
                                partyActivity.notifyQueueChanged(false);
                            }
                        }
                    });
                }
            }
        }
    };

    @Override
    public void onDestroy() {
        cloudAPI.setPlaying(partyID, song.getSongURL(), false, new GenericCallback<Boolean>() {
            @Override
            public void onValue(Boolean success) {
                // Do nothing we are dead
            }
        });
        mediaPlayer.shutdown();
        Spotify.destroyPlayer(this);
        super.onDestroy();
        mHandler.removeCallbacksAndMessages(null);

    }

    @Override
    public void onPlaybackEvent(PlayerEvent playerEvent) {
        switch (playerEvent) {
            case kSpPlaybackNotifyAudioDeliveryDone:
                cloudAPI.deleteSong(song, new GenericCallback<Boolean>() {
                    @Override
                    public void onValue(Boolean success) {
                        if (success) {
                            setNextSong(true);
                            partyActivity.notifyQueueChanged(true);
                        }
                    }
                });
                break;
        }
    }

    @Override
    public void onPlaybackError(Error error) { }
}