package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Wait extends State {

	Wait( SMTP smtp ) {
		super( smtp );
                name = "Wait" ;
                transition_msg = "250" ;
                transition_command = "mail from" ;
		print(name);
		next = new EnvelopeCreated( smtp );
	}

//	@Override
//	public void send( String msg ) {
//
//	}

}
