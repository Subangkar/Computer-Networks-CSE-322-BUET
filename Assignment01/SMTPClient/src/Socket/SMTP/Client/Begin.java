package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Begin extends State {

	// 'HELO' will be sent in this state
	Begin( SMTP smtp ) {
		super( smtp );
		transition_msg = "250" ;//need to be implemented
                transition_command = "helo" ;
                name = "Begin";
		print(name);
		next = new Wait(smtp);
	}


}
