package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Begin extends State {
	
	public Begin( SMTP smtp ) {
		super( smtp );
		next = new Wait( smtp );
	}
	
	@Override
	public void print() {
		System.out.println(">> In BEGIN state: ");
	}
}
