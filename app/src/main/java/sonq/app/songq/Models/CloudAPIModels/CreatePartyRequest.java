package sonq.app.songq.Models.CloudAPIModels;

import com.google.gson.annotations.SerializedName;

import java.security.SecureRandom;
import java.util.Random;


public class CreatePartyRequest {

    @SerializedName("party_id")
    private String partyID;
    @SerializedName("device_id")
    private String deviceID;

    public CreatePartyRequest(String deviceID) {
        this.deviceID = deviceID;
        this.partyID = generatePartyId();
    }

    private String generatePartyId() {
        StringBuilder sb = new StringBuilder();
        Random rand = new SecureRandom();
        for(int i= 0; i< 6 ; i++){
            // 0 to 9
            sb.append(rand.nextInt(10));
        }
        return sb.toString();
    }
}
