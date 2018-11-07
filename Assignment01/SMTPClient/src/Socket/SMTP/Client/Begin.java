package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Begin extends State {
	
	// 'HELO' will be sent in this state
	Begin( SMTP smtp ) {
		super( smtp );
		next = new Wait( smtp );
		print("BEGIN");
	}
	
	@Override
	public void send( String msg ) {
	
	}
}
