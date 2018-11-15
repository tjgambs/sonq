package sonq.app.songq.Fragments;

import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import java.io.IOException;

import sonq.app.songq.API.CloudAPI;
import sonq.app.songq.API.GenericCallback;
import sonq.app.songq.Models.SpotifyAPIModels.Song;
import sonq.app.songq.R;

public class FragmentPlayer extends Fragment implements Runnable {

    private CloudAPI cloudAPI;
    private String deviceID;
    private String partyID;

    private Song song;

    private ImageView playButton = null;
    private SeekBar seekBar = null;
    private TextView tv_name = null;
    private TextView tv_artist = null;
    private TextView duration = null;
    private ImageView albumArtwork = null;
    private MediaPlayer mediaPlayer = null;

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
        duration = getView().findViewById(R.id.tv_previewDuration);
        albumArtwork = getView().findViewById(R.id.albumArtwork);
        playButton = getView().findViewById(R.id.iv_play);
        playButton.setOnClickListener(onClickPlayListener);
        seekBar = getView().findViewById(R.id.seekBar_playMusic);

        if (song == null) {
            setNextSong(false);
        }

        if (seekBar != null) {
            seekBar.setProgress(0);
            seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                    if (b) {
                        setPlayerPosition(i);
                    }
                }
                @Override
                public void onStartTrackingTouch(SeekBar seekBar) { }
                @Override
                public void onStopTrackingTouch(SeekBar seekBar) { }
            });
        }
    }

    private void setNextSong(final boolean playAfter) {
        cloudAPI.getNextSong(partyID, new GenericCallback<Song>() {
            @Override
            public void onValue(Song nextSong) {
                song = nextSong;
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tv_name.setText(song.getName());
                        tv_artist.setText(song.getArtist());
                        duration.setText(song.getDuration());

                        // TODO: Set an album image on the player
                    }
                });

                if (playAfter) {
                    initializePlayer();
                    onClickPlayListener.onClick(getView());
                }

            }
        });
    }

    public boolean isPlayerInitialized() {
        return mediaPlayer != null;
    }

    public void initializePlayer() {
        if (mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setOnPreparedListener(onPreparedListener);
            mediaPlayer.setOnCompletionListener(onCompletionListener);
        }
    }

    public void playSong(String url) {
        if (seekBar.getProgress() > 0) {
            playButton.setImageResource(R.drawable.ic_pause_white_24dp);
            mediaPlayer.start();
        } else {
            //prepare:
            playButton.setImageResource(R.drawable.ic_pause_white_24dp);
            mediaPlayer.setAudioAttributes(
                    new AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build());
            try {
                mediaPlayer.reset();
                mediaPlayer.setDataSource(url);
                mediaPlayer.prepareAsync();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void pausePlayer() {
        playButton.setImageResource(R.drawable.ic_play_arrow_white_24dp);
        mediaPlayer.pause();
    }

    public boolean isPlaying() {
        return isPlayerInitialized() && mediaPlayer.isPlaying();
    }

    public void setPlayerPosition(int i) {
        if (isPlaying()) {
            mediaPlayer.seekTo(i);
        }
    }

    // play song thread.
    @Override
    public void run() {
        int currentPosition = 0;
        if (mediaPlayer != null) {
            int total = mediaPlayer.getDuration();
            while (mediaPlayer != null
                    && currentPosition < total) {
                try {
                    Thread.sleep(50);
                    if (mediaPlayer != null) {
                        currentPosition = mediaPlayer.getCurrentPosition();
                        seekBar.setProgress(currentPosition);
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                    currentPosition = total;
                }
            }
        }
    }

    private View.OnClickListener onClickPlayListener  = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            if (song != null) {
                if (!isPlayerInitialized())
                    initializePlayer();

                //pause:
                if (isPlaying()) {
                    pausePlayer();
                    return;
                }
                //play
                if (song.getSongURL() != null) {
                    String url = song.getSongURL();
                    if (!url.contains(".mp3"))
                        url = song.getSongURL() + ".mp3";
                    url = "https://p.scdn.co/mp3-preview/2870009a723d30859e9cdb2f4d160b37d12d0ecb?cid=1df21b37504648758e66548b7aa15e11";
                    playSong(url);
                }
            } else {
                setNextSong(true);
            }
        }
    };

    // Start playing the song when created
    private MediaPlayer.OnPreparedListener onPreparedListener = new MediaPlayer.OnPreparedListener() {
        @Override
        public void onPrepared(MediaPlayer mediaPlayer) {
            mediaPlayer.start();
            seekBar.setProgress(0);
            seekBar.setMax(mediaPlayer.getDuration());
            new Thread(FragmentPlayer.this).start();
        }
    };

    // When the preview stops playing, hide the player.
    private MediaPlayer.OnCompletionListener onCompletionListener = new MediaPlayer.OnCompletionListener() {
        @Override
        public void onCompletion(MediaPlayer mediaPlayer) {
            setNextSong(true);
        }
    };


    @Override
    public void onDestroyView() {
        super.onDestroyView();
        try {
            if(mediaPlayer != null) {
                mediaPlayer.release();
            }
        }
        catch (Exception e){
            Log.e("PlaySongPreviewFragment", "releasing player");
        }
    }

}