package Socket.SMTP.Client;

import Socket.SMTP.Client.SMTP;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public abstract class State {
	private SMTP client;
	State next;
	private String name;
	
	State( SMTP smtp ) {
		this.client = smtp;
	}
	
	void print( String stateName ) {
		System.out.println( ">> In " + stateName + " state: " );
	}
	
	public abstract void send( String msg );
//	{
		//sending codes of
		
		//read server reply
		
		// print server message


//		if(successful)
//		{
//		if (this.next == null) ;
			// QUIT
//		else client.setState( next );
//		}
//        else{
//        	print Error infos
//		    client.setState( this ); or QUIT
//		}
//	}
}
