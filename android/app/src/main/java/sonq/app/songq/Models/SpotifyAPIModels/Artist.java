package sonq.app.songq.Models.SpotifyAPIModels;

public class Artist {

    private String href;
    private String id;
    private String name;
    private String type;
    private String uri;

    public String getHref() {
        return href;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public String getUri() {
        return uri;
    }

    @Override
    public String toString() {
        return this.name;
    }

}
