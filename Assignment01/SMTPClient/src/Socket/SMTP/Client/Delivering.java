package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Delivering extends State {
	
	Delivering( SMTP smtp ) {
		super( smtp );
		next = null;
	}
	
	@Override
	public void print() {
		System.out.println(">> In Delivering state: ");
	}
	
}
