package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class EnvelopeCreated extends State {
	
	EnvelopeCreated( SMTP smtp ) {
		super( smtp );
		next = new RecSet( smtp );
	}
	
	@Override
	public void print() {
		System.out.println(">> In Envelope Created state: ");
	}
}
