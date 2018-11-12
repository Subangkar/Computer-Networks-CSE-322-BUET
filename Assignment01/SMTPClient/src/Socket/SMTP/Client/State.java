package Socket.SMTP.Client;

import Socket.SMTP.Client.SMTP;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public abstract class State {
	
	protected SMTP client;
	State next;
	public String name;
	public String transition_msg;
	public String transition_command;
	
	State( SMTP smtp ) {
		this.client = smtp;
		transition_msg = "";
		transition_command = "";
		name = "";
//		next = null;
	}
	
	void print( String stateName ) {
//		System.out.println( ">> In " + stateName + " state: " );
	}
	void print(  ) {
		System.out.println( ">> In " + name + " state: " );
	}
	
	public String send( String command , String feedback ) {
		// System.out.println("COMAND"+command);
		String newfeedback = "";
		newfeedback = client.send_command( command , feedback );
		if(name.equals( "WritingData" )) client.send_command( "quit" , feedback );
		// System.out.println("feed"+newfeedback);
		transition( newfeedback , command );
		return newfeedback;
	}
	
	public State getNextState( State s ) {
//        if (s.name.equals("Closed"))
//        return new Begin(s.client) ;
//        else if (s.name.equals("Begin"))
//        return new Wait(s.client) ;
//        else if (s.name.equals("Wait"))
//        return new EnvelopeCreated(s.client) ;
//        else if (s.name.equals("EnvelopeCreated"))
//        return new RecSet(s.client) ;
//        else if (s.name.equals("RecSet"))
//        return new WritingData(s.client) ;
//        else if (s.name.equalsIgnoreCase("WritingData"))
//            return null ;
		return s.next;
	}
	

	void transition( String newfeedback , String command ) throws NullPointerException {
		//System.out.println(newfeedback);
		if (newfeedback == null) return;
		
		if (command.startsWith( "rset" ) && newfeedback.startsWith( "250" ) && this.name.equalsIgnoreCase( "begin" )) {
			client.setState(new Wait(client));
		} else if (command.startsWith( "rset" ) && newfeedback.startsWith( "250" )) {
			client.setState( new Wait( client ) );
			//return ;
		} else if (newfeedback.toLowerCase().startsWith( transition_msg ) && command.toLowerCase().startsWith( transition_command )) {
			//   System.out.println("haha"+newfeedback);
			client.setState( this.getNextState( this ) );
			
		} else if (newfeedback.startsWith( "221" )) {
			System.out.println( "quitting..." );
			client.setState( null );
		}
	}
	//print(name);
	
	void parseFeedBack( String feedback ){}
}
