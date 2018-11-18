package sonq.app.sonq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

public class CreatePartyResponse {

    @SerializedName("party_id")
    private String partyID;

    public String getPartyID() {
        return partyID;
    }
}
