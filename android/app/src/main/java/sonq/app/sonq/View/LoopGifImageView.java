package sonq.app.sonq.View;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.AttributeSet;
import android.util.Log;

import java.io.IOException;

import pl.droidsonroids.gif.GifDrawable;
import pl.droidsonroids.gif.GifImageView;
import sonq.app.sonq.R;

public class LoopGifImageView extends GifImageView {

    public LoopGifImageView(Context context) {
        super(context);
    }

    public LoopGifImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        postInit();
    }

    public LoopGifImageView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        postInit();
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    public LoopGifImageView(Context context, AttributeSet attrs, int defStyle, int defStyleRes) {
        super(context, attrs, defStyle, defStyleRes);
        postInit();
    }

    private void postInit() {
        try {
            GifDrawable playingGif = new GifDrawable(getResources(), R.drawable.playing);
            playingGif.setLoopCount(0);
            this.setImageDrawable(playingGif);
        } catch (IOException e) {
            Log.e("LoopGifImageView", "Cant loop gif", e);
        }
    }
}
