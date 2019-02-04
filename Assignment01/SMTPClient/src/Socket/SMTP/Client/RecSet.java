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
		next = new WritingData( smtp );
	}
	
	@Override
	void print() {
		super.print();
		System.out.println( "! send command \"data\" to start writing mail" );
	}
	@Override
	void parseFeedBack( String feedback ) {
		super.parseFeedBack( feedback );
		if(feedback==null) return;
		if(feedback.startsWith( "500" ))
			System.out.println("      >> \"data\" command not provided");
//		else if(feedback.startsWith( "501" ))
//			System.out.println("      >> recipients mail_ids not provided");
	}
	
}
