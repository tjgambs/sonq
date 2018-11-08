package sonq.app.songq.Presenters;

import java.io.Serializable;
import java.util.Map;

import sonq.app.songq.Common.Constants;
import sonq.app.songq.Interfaces.IPlaySongPreviewView;
import sonq.app.songq.Models.Song;


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
                model.preview_url = (String) args.get(Constants.PREVIEW_TRACK_URL);
            if (args.containsKey(Constants.TRACK_NAME))
                model.name = (String) args.get(Constants.TRACK_NAME);
            if (args.containsKey(Constants.TRACK_ARTIST))
                model.artist = (String) args.get(Constants.TRACK_ARTIST);

            view.setSongName(model.name);
            view.setArtistName(model.artist);
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
        if(model.preview_url != null) {
            String url = model.preview_url;
            if (!model.preview_url.contains(".mp3"))
                url = model.preview_url + ".mp3";

            view.playSong(url);
        }
    }

    public void onChangePlayerPosition(int position) {
        if(!view.isPlayerInitialized())
            view.initializePlayer();
        view.setPlayerPosition(position);
    }

    public void setSong(String songPreviewUrl, String name, String artist) {
        model.preview_url = songPreviewUrl;
        model.name = name;
        model.artist = artist;

        view.stopPlayer();
        view.setSongName(model.name);
        view.setArtistName(model.artist);
        view.initializePlayer();
    }
}
