package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class WritingData extends State {
	
	WritingData( SMTP smtp ) {
		super( smtp );
		next = null;
		name = "WritingData";
		print( name );
	}

//	@Override
//	public void send( String msg ) {
//
//	}

}
