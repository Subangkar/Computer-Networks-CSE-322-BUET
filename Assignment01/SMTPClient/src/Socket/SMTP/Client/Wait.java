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
	
	@Override
	void print() {
		super.print();
		System.out.println( "! provide sender mail \"mail from: <mail_id>\"" );
	}
	
	@Override
	void parseFeedBack( String feedback ) {
		super.parseFeedBack( feedback );
		if(feedback==null) return;
		if(feedback.startsWith( "500" ))
			System.out.println("      >> \"mail\" command not provided at first");
		else if(feedback.startsWith( "501" ))
			System.out.println("      >> \"mail from:\" not provided after \"helo\"");
	}


}
