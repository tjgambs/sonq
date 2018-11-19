package sonq.app.sonq.Adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AnimationUtils;
import android.view.animation.LayoutAnimationController;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import sonq.app.sonq.Fragments.FragmentQueue;
import sonq.app.sonq.Models.SpotifyAPIModels.Song;
import sonq.app.sonq.R;
import sonq.app.sonq.Task.DownloadImageTask;


public class QueueAdapter extends RecyclerView.Adapter<QueueAdapter.QueueViewHolder> {
    private List<Song> songList = new ArrayList<>();
    private FragmentQueue parent;
    private boolean isSearch = false;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class QueueViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        // each data item is just a string in this case
        public TextView songTitle, songArtist, songLength, addedBy;
        public ImageView songImage, isPlaying;
        public CheckBox addedCheckbox;
        public Song song;
        public FragmentQueue parent;
        public QueueViewHolder(View view) {
            super(view);
            view.setOnClickListener(this);
            songTitle = view.findViewById(R.id.song_title);
            songArtist = view.findViewById(R.id.song_artist);
            songImage = view.findViewById(R.id.song_image);
            songLength = view.findViewById(R.id.song_length);
            addedBy = view.findViewById(R.id.added_by);
            addedCheckbox = view.findViewById(R.id.added_checkbox);
            isPlaying = view.findViewById(R.id.is_playing_gif);
        }

        @Override
        public void onClick(View v) {
            if (!addedCheckbox.isChecked()) {
                parent.onClickedSong(song);
                addedCheckbox.setChecked(true);
            }
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public QueueAdapter(FragmentQueue parent) {
        this.parent = parent;
    }

    // Create new views (invoked by the layout manager)
    @Override
    public QueueAdapter.QueueViewHolder onCreateViewHolder(ViewGroup parent,
                                                           int viewType) {
        // create a new view
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.song_list_item, parent, false);
       return new QueueViewHolder(itemView);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(QueueViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        Song song = songList.get(position);
        // Get Image
        if (song.getThumbnail() == null) {
            new DownloadImageTask(holder.songImage).execute(song);
        } else {
            holder.songImage.setImageBitmap(song.getThumbnail());
        }

        // Set parent to use to play once clicked
        holder.parent = parent;

        // Set Text
        holder.songTitle.setText(song.getName());
        holder.songArtist.setText(song.getArtist());
        holder.songLength.setText(song.getDuration());
        holder.addedBy.setText(song.getAddedBy());

        //Set checkbox visible
        if (isSearch) {
            holder.addedCheckbox.setChecked(song.isInQueue());
            holder.addedCheckbox.setVisibility(View.VISIBLE);
        } else {
            holder.addedCheckbox.setVisibility(View.INVISIBLE);
        }

        //Show playing
        if (song.isPlaying()) {
            holder.isPlaying.setVisibility(View.VISIBLE);
        } else {
            holder.isPlaying.setVisibility(View.INVISIBLE);
        }

        // Set search result object
        holder.song = song;
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return songList.size();
    }

    public void update(List<Song> data, boolean isSearch, RecyclerView recyclerView, boolean runAnimation) {
        this.isSearch = isSearch;
        songList.clear();
        if (data != null) {
            songList.addAll(data);
        }

        if (runAnimation) {
            runLayoutAnimation(recyclerView);
        } else {
            notifyDataSetChanged();
        }
    }

    private void runLayoutAnimation(final RecyclerView recyclerView) {
        final Context context = recyclerView.getContext();
        final LayoutAnimationController controller =
                AnimationUtils.loadLayoutAnimation(context, R.anim.layout_animation_fall_down);

        recyclerView.setLayoutAnimation(controller);
        notifyDataSetChanged();
        recyclerView.scheduleLayoutAnimation();
    }

    public List<Song> getSongList() {
        return songList;
    }
}
