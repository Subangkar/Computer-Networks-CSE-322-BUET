package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Closed extends State {
	
	// 'HELO' will be sent in this state
	Closed( SMTP smtp ) {
		super( smtp );
		transition_msg = "220";//need to be implemented
		name = "Closed";
		print( name );
		next = new Begin(smtp);
	}
	
	
}
