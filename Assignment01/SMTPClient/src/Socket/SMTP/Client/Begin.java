package Socket.SMTP.Client;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class Begin extends State {
	
	// 'HELO' will be sent in this state
	Begin( SMTP smtp ) {
		super( smtp );
		transition_msg = "250";//need to be implemented
		transition_command = "helo";
		name = "Begin";
		next = new Wait( smtp );
	}
	
	@Override
	void print() {
		super.print();
		System.out.println( "! start mail with \"helo <hostname>\"" );
	}
	
	@Override
	void parseFeedBack( String feedback ) {
		super.parseFeedBack( feedback );
		if(feedback==null) return;
		if(feedback.startsWith( "500" ))
			System.out.println("      >> \"helo\" command not provided at first");
		else if(feedback.startsWith( "501" ))
			System.out.println("      >> \"<hostname>\" not provided after \"helo\"");
	}
}
