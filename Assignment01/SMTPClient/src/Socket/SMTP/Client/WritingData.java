package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class WritingData extends State {
	
	WritingData( SMTP smtp ) {
		super( smtp );
		next = null;
		print("Writing Data");
	}
	
	@Override
	public void send( String msg ) {
	
	}
	
}
