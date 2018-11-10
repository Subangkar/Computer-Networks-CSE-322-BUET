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
	
	@Override
	void print() {
		super.print();
		System.out.println( "! write mail ideal format should be" +
				                    " >\n\"Subject: <subject_name>\"\n" +
				                    " >\n\" <mail_body> \"\n \"<CR><LF>.<CR><LF>\"" );
	}
	
	@Override
	void parseFeedBack( String feedback ) {
		super.parseFeedBack( feedback );
		if(feedback==null) return;
		if(feedback.startsWith( "250" ))
			System.out.println("      >> MAIL successfully sent");
	}
	
}
