package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

public class JoinPartyResponse {

    @SerializedName("party_exists")
    Boolean partyExists;

    public Boolean getPartyExists() {
        return partyExists;
    }
}
