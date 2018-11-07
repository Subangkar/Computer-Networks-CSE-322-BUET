package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Wait extends State {
	
	Wait( SMTP smtp ) {
		super( smtp );
	}
	
	@Override
	public void print() {
		System.out.println(">> In WAIT state: ");
	}
	
}
