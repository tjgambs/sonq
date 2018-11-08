package sonq.app.songq.Fragments;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import java.io.IOException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import sonq.app.songq.Common.Constants;
import sonq.app.songq.Interfaces.ICompletedPlaySongPreview;
import sonq.app.songq.Interfaces.IPlaySongPreviewView;
import sonq.app.songq.Presenters.PlaySongPreviewPresenter;
import sonq.app.songq.R;


public class PlaySongPreviewFragment extends Fragment implements Runnable, IPlaySongPreviewView {

    private PlaySongPreviewPresenter presenter;
    private ImageView playButton = null;
    private SeekBar seekBar = null;
    private TextView tv_name = null;
    private TextView tv_artist = null;
    private MediaPlayer mediaPlayer = null;
    private ICompletedPlaySongPreview completedPlaySongPreviewListener;

    public PlaySongPreviewFragment() { }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View v =  inflater.inflate(R.layout.play_song_preview, container, false);

        tv_name = v.findViewById(R.id.tv_previewName);
        tv_artist = v.findViewById(R.id.tv_previewArtist);
        playButton = v.findViewById(R.id.iv_play);
        playButton.setOnClickListener(onClickPlayListener);
        seekBar = v.findViewById(R.id.seekBar_playMusic);

        if (seekBar != null) {
            seekBar.setProgress(0);
            seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                    if (b) {
                        presenter.onChangePlayerPosition(i);
                    }
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) { }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) { }
            });
        }

        presenter = new PlaySongPreviewPresenter(this);
        presenter.onCreateView();

        return v;
    }

    @Override
    public PlaySongPreviewPresenter  getPresenterInstance() {
        return presenter;
    }

    @Override
    public Map<String, Serializable> getBundleArguments() {
        Map<String, Serializable> arguments = new HashMap<>();
        Bundle args = getArguments();
        if (args != null) {
            Serializable previewUrl = args.getSerializable(Constants.PREVIEW_TRACK_URL);
            arguments.put(Constants.PREVIEW_TRACK_URL, previewUrl);
            Serializable name = args.getSerializable(Constants.TRACK_NAME);
            arguments.put(Constants.TRACK_NAME, name);
            Serializable artist = args.getSerializable(Constants.TRACK_ARTIST);
            arguments.put(Constants.TRACK_ARTIST, artist);
        }
        return arguments;
    }

    @Override
    public void setOnCompletedPlaySongPreviewListener(ICompletedPlaySongPreview listener) {
        completedPlaySongPreviewListener = listener;
    }

    @Override
    public void setSongName(String songName) {
        if (tv_name != null) {
            tv_name.setText(songName);
        }
    }

    @Override
    public void setArtistName(String artistName) {
        if(tv_artist != null) {
            tv_artist.setText(artistName);
        }
    }

    @Override
    public boolean isPlayerInitialized() {
        return mediaPlayer != null;
    }

    @Override
    public void initializePlayer() {
        if (mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setOnPreparedListener(onPreparedListener);
            mediaPlayer.setOnCompletionListener(onCompletionListener);
        }
    }

    @Override
    public void playSong(String songUrl) {
        if (seekBar.getProgress() > 0) {
            playButton.setImageResource(R.drawable.ic_pause_white_24dp);
            mediaPlayer.start();
        } else {
            //prepare:
            playButton.setImageResource(R.drawable.ic_pause_white_24dp);
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            try {
                mediaPlayer.reset();
                mediaPlayer.setDataSource(songUrl);
                mediaPlayer.prepareAsync();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void stopPlayer() {
        if (mediaPlayer != null) {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
            mediaPlayer.reset();
            seekBar.setProgress(0);
        }
        playButton.callOnClick();
    }

    @Override
    public void pausePlayer() {
        playButton.setImageResource(R.drawable.ic_play_arrow_white_24dp);
        mediaPlayer.pause();
    }

    @Override
    public boolean isPlaying() {
        return mediaPlayer != null && mediaPlayer.isPlaying();
    }

    @Override
    public void setPlayerPosition(int i) {
        mediaPlayer.seekTo(i);
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
            presenter.onClickedPlay();
        }
    };

    // Start playing the song when created
    private MediaPlayer.OnPreparedListener onPreparedListener = new MediaPlayer.OnPreparedListener() {
        @Override
        public void onPrepared(MediaPlayer mediaPlayer) {
            mediaPlayer.start();
            seekBar.setProgress(0);
            seekBar.setMax(mediaPlayer.getDuration());
            new Thread(PlaySongPreviewFragment.this).start();
        }
    };

    // When the preview stops playing, hide the player.
    private MediaPlayer.OnCompletionListener onCompletionListener = new MediaPlayer.OnCompletionListener() {
        @Override
        public void onCompletion(MediaPlayer mediaPlayer) {

            mediaPlayer.reset();
            mediaPlayer.release();

            if (completedPlaySongPreviewListener != null) {
                completedPlaySongPreviewListener.closePlaySongPreview();
            }
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
