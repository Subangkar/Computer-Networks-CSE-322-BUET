package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class WritingData extends State {
	
	WritingData( SMTP smtp ) {
		super( smtp );
		next = new Delivering( smtp );
	}
	
	@Override
	public void print() {
		System.out.println(">> In Writing Data state: ");
	}
	
}
