package Socket.SMTP.Client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.Scanner;
import java.util.StringTokenizer;

public class SMTP {
	
	Scanner sc;
	String user;
	String password;
	public static final String mailServer = "localhost";
	InetAddress mailHost;
	InetAddress localHost;
	Socket smtpSocket;
	BufferedReader in;
	PrintWriter pr;
	String feedback;
	
	//State st ;
	private State state;
	
	SMTP() throws IOException {
		feedback = "";
		//user = "c3BvbmRvbg==";
		//password = "U3BvbmRvbjc3";
		sc = new Scanner( System.in );
		mailHost = InetAddress.getByName( mailServer );
		localHost = InetAddress.getLocalHost();
		smtpSocket = new Socket( mailHost , 1050 );
		in = new BufferedReader( new InputStreamReader( smtpSocket.getInputStream() ) );
		pr = new PrintWriter( smtpSocket.getOutputStream() , true );
		state = new Closed( this );
		smtpSocket.setSoTimeout( 20000 );
	}
	
	String send_command( String command , String feedback ) {
		String f;
		try {
			System.out.println( ">> C: >> " + command );
			pr.println( command );
			pr.flush();
			f = in.readLine();
			System.out.println( ">> S: >> " + f );
			state.parseFeedBack( f );
			return f;
		} catch (SocketTimeoutException s) {
			System.out.println( "Timed out..." );
			System.exit( 0 );
		} catch (Exception e) {
//			e.printStackTrace();
			System.out.println( "Server Timed out..." );
			System.exit( 1 );
		}
		return "exception";
	}
	
	public State getState() {
		return state;
	}
	
	void setState( State s ) {
		this.state = s;
		if (s != null) s.print();
	}
	
	public static void main( String[] args ) {
		try {
			SMTP obj = new SMTP();
			obj.run( args );
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void run( String[] args ) throws Exception {
		//while (true) {
		feedback = in.readLine();
		System.out.println( feedback );
		state.transition( feedback , "" );
		//    System.out.println(feedback);
		String command = "";
		while (true) {
			try {
				
				if (state == null) {
					break;
				}
				state.print( state.name );
				command = "";
				if (state.name.equalsIgnoreCase( "WritingData" )) {
					String body;
					do {
						body = sc.nextLine();
						command = command + "\n" + body;
					} while (!body.equalsIgnoreCase( "." ));
					pr.println( command );
					System.out.println( ">> Written Mail Body" );
					state.send( "." , feedback );
				} else {
					command = sc.nextLine();
					
					if (state != null) {
						if (command.startsWith( "rcpt to:" ) || command.startsWith( "RCPT TO:" )) {
							StringTokenizer stk = new StringTokenizer( command.replaceAll( "(?i)rcpt to:" , "" ) , ", " );
							System.out.println( ">> " + "Adding " + stk.countTokens() + " recipients." );
							while (stk.hasMoreTokens()) {
								String cmd = "RCPT TO: " + stk.nextToken();
								feedback = state.send( cmd , feedback );
							}
						} else
							feedback = state.send( command , feedback );
					}
				}
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
		}
	}
}
