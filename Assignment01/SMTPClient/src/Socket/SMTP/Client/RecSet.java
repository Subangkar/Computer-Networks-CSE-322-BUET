package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class RecSet extends State {
	
	RecSet( SMTP smtp ) {
		super( smtp );
		next = new WritingData( smtp );
	}
	
	@Override
	public void print() {
		System.out.println(">> In Recipients Set state: ");
	}
}
