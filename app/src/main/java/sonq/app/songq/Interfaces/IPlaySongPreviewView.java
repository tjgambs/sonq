package sonq.app.songq.Interfaces;

import java.io.Serializable;
import java.util.Map;

import sonq.app.songq.Presenters.PlaySongPreviewPresenter;


public interface IPlaySongPreviewView {

    void setSongName(String songName);
    void setArtistName(String artistName);
    boolean isPlayerInitialized();
    void initializePlayer();
    void playSong(String songUrl);
    void stopPlayer();
    void pausePlayer();
    boolean isPlaying();
    void setPlayerPosition(int i);
    PlaySongPreviewPresenter getPresenterInstance();
    Map<String, Serializable> getBundleArguments();
    void setOnCompletedPlaySongPreviewListener(ICompletedPlaySongPreview listener);
}
