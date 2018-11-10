package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class RecSet extends State {
	
	RecSet( SMTP smtp ) {
		super( smtp );
		name = "RecSet";
		transition_msg = "354";
		transition_command = "data";
		print( name );
		next = new WritingData( smtp );
	}
}
