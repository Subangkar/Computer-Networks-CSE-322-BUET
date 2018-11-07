package Socket.SMTP.Client;

import Socket.SMTP.Client.SMTP;

/**
 * Created by Subangkar on 07-Nov-18.
 */
public abstract class State {
	private SMTP client;
	State next;
	
	State(SMTP smtp){
		this.client = smtp;
	}
	
	abstract void print();
	
	public void send( String msg ){
		//sending codes of
		
		//read server reply
		// print server message
		
//      if(this.next==null) QUIT
//		else if(successful)
//		{
//			client.setState( next );
//		}
//      else print Error infos
	}
}
