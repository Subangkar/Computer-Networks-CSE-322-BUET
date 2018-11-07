package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class EnvelopeCreated extends State {
	
	EnvelopeCreated( SMTP smtp ) {
		super( smtp );
		next = new RecSet( smtp );
		print("Envelope Created");
	}
	
	@Override
	public void send( String msg ) {
	
	}
}
