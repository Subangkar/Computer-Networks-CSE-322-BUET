package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Wait extends State {
	
	Wait( SMTP smtp ) {
		super( smtp );
		next = new EnvelopeCreated( smtp );
		print("Wait");
	}
	
	@Override
	public void send( String msg ) {
	
	}
	
}
