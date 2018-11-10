package Socket.SMTP.Client;

import java.util.StringTokenizer;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public class EnvelopeCreated extends State {

    EnvelopeCreated(SMTP smtp) {
        super(smtp);
        name = "EnvelopeCreated";
        transition_msg = "250";
        transition_command = "rcpt to";
        next=new RecSet( smtp );
    }
	
	@Override
	void print() {
		super.print();
		System.out.println( "! provide recipient(s) mail \"rcpt to: <mail_id1,mail_id2,mail_id3......>\"" );
	}
	
	@Override
	void parseFeedBack( String feedback ) {
		super.parseFeedBack( feedback );
		if(feedback==null) return;
		if(feedback.startsWith( "500" ))
			System.out.println("      >> \"rcpt to:\" command not provided at first");
		else if(feedback.startsWith( "501" ))
			System.out.println("      >> recipients mail_ids not provided");
	}
	
	
}
