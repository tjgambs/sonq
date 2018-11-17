package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

public class JoinPartyResponse {

    @SerializedName("party_exists")
    Boolean partyExists;
    @SerializedName("created_by")
    String createdBy;

    public Boolean getPartyExists() {
        return partyExists;
    }

    public String getCreatedBy() {
        return createdBy;
    }
}
