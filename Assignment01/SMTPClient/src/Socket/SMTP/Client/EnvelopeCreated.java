package Socket.SMTP.Client;

import java.util.StringTokenizer;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class EnvelopeCreated extends State {

    EnvelopeCreated(SMTP smtp) {
        super(smtp);
        name = "EnvelopeCreated";
        transition_msg = "250";
        transition_command = "rcpt to";
        print(name);
        next=new RecSet( smtp );
    }

//    @Override
//    public String send(String command, String feedback) {
//
//        
//        else return super.send(command, feedback);
//    }
    //return super.send(command, feedback); //To change body of generated methods, choose Tools | Templates.

}
