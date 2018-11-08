package sonq.app.songq.Interfaces;

import java.io.Serializable;
import java.util.HashMap;


public interface ISearchSongsView {

    void showProgressBar();
    void hideProgressBar();
    IPlaySongPreviewView showPlaySongPreviewView(HashMap<String, Serializable> bundleArguments);
    void hidePlaySongPreviewView();
    IPlaySongPreviewView getPlaySongPreviewView();

}
