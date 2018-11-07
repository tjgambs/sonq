package sonq.app.songq.Adapter;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import sonq.app.songq.Common.Constants;
import sonq.app.songq.Models.Song;
import sonq.app.songq.R;
import sonq.app.songq.Task.DownloadImageTask;

public class QueueAdapter extends RecyclerView.Adapter<QueueAdapter.QueueViewHolder> {
    private List<Song> songList;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public static class QueueViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        public TextView songTitle, songArtist, songAlbum, songLength;
        public ImageView songImage;
        public QueueViewHolder(View view) {
            super(view);
            songTitle = view.findViewById(R.id.song_title);
            songArtist = view.findViewById(R.id.song_artist);
            songAlbum = view.findViewById(R.id.song_album);
            songImage = view.findViewById(R.id.song_image);
            songLength = view.findViewById(R.id.song_length);
        }
    }

    // Provide a suitable constructor (depends on the kind of dataset)
    public QueueAdapter(List<Song> songList) {
        this.songList = songList;
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
        new DownloadImageTask(holder.songImage).execute(song.getAlbum().getImages().get(Constants.IMAGE_INDEX_64).getUrl());

        // Set Text
        holder.songTitle.setText(song.getName());
        holder.songArtist.setText(song.getArtists().get(0).getName());
        holder.songAlbum.setText(song.getAlbum().getName());
        holder.songLength.setText(getPrettyLength(song.getDurationMs()));
    }

    private String getPrettyLength(int ms) {
        long minutes = (ms / 1000) / 60;
        long seconds = (ms / 1000) % 60;
        return String.format("%d:%02d", minutes, seconds);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return songList.size();
    }

    public void update(List<Song> data) {
        songList.clear();
        songList.addAll(data);
        notifyDataSetChanged();
    }
}
