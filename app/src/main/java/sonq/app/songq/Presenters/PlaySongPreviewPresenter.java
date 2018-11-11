package sonq.app.songq.Presenters;

import java.io.Serializable;
import java.util.Map;

import sonq.app.songq.Common.Constants;
import sonq.app.songq.Interfaces.IPlaySongPreviewView;
import sonq.app.songq.Models.SpotifyAPIModels.Song;


public class PlaySongPreviewPresenter {

    private IPlaySongPreviewView view;
    private Song model;

    public PlaySongPreviewPresenter(IPlaySongPreviewView _view) {
        view = _view;
        model = new Song();
    }

    public void onCreateView() {
        Map<String, Serializable> args = view.getBundleArguments();
        if(args != null) {
            if (args.containsKey(Constants.PREVIEW_TRACK_URL))
                model.setPreviewURL((String) args.get(Constants.PREVIEW_TRACK_URL));
            if (args.containsKey(Constants.TRACK_NAME))
                model.setName((String) args.get(Constants.TRACK_NAME));
            if (args.containsKey(Constants.TRACK_ARTIST))
                model.setArtist((String) args.get(Constants.TRACK_ARTIST));

            view.setSongName(model.getName());
            view.setArtistName(model.getArtist());
            view.initializePlayer();

            onClickedPlay();
        }
    }

    public void onClickedPlay() {

        if(!view.isPlayerInitialized())
            view.initializePlayer();

        //pause:
        if(view.isPlaying()){
            view.pausePlayer();
            return;
        }
        //play
        if(model.getPreviewURL() != null) {
            String url = model.getPreviewURL();
            if (!model.getPreviewURL().contains(".mp3"))
                url = model.getPreviewURL() + ".mp3";

            view.playSong(url);
        }
    }

    public void onChangePlayerPosition(int position) {
        if(!view.isPlayerInitialized())
            view.initializePlayer();
        view.setPlayerPosition(position);
    }

    public void setSong(String songPreviewUrl, String name, String artist) {
        model.setPreviewURL(songPreviewUrl);
        model.setName(name);
        model.setArtist(artist);

        view.stopPlayer();
        view.setSongName(model.getName());
        view.setArtistName(model.getArtist());
        view.initializePlayer();
    }
}
