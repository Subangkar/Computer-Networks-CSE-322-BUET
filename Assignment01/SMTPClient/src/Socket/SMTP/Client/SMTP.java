package Socket.SMTP.Client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
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
//			if (command.startsWith( "rcpt to:" )) {
//				String finalcommand = "";
//				command = command.substring( 8 );
//				StringTokenizer stk = new StringTokenizer( command , "," );
//				String header = stk.nextToken();
//				finalcommand = "rcpt to:<" + header + ">";
//				System.out.println( header );
//				pr.println( finalcommand );
//				pr.flush();//ignore rcpt
//				while (stk.hasMoreTokens()) {
//					String mail = stk.nextToken();
//					finalcommand = "rcpt to:<" + mail + ">";
//					pr.println( finalcommand );
//					pr.flush();
//				}
//
//				System.out.println( "final" + finalcommand );
//				//return super.send(finalcommand, feedback) ;
//				f = in.readLine();
//				state.transition( f , finalcommand );
//				System.out.println( f );
//			} else {
			System.out.println( ">> C: >> " + command );
			pr.println( command );
			pr.flush();
//			}
			f = in.readLine();
			System.out.println( ">> S: >> " + f );
			
		} catch (Exception e) {
			f = "exception";
			e.printStackTrace();
			System.out.println( "Timed out..." );
			System.exit( 0 );
		}
		
		return f;
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
	
	public void run( String[] args ) throws Exception {
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
				// System.out.println("{{" + state.name);
				command = "";
				if (state.name.equalsIgnoreCase( "WritingData" )) {
					String body = "";
					while (true) {
						//System.out.println("waiting in while");
						body = sc.nextLine();
						command = command + "\n" + body;
						if (body.equalsIgnoreCase( "." )) {
							break;
						}
					}
					pr.println( command );
					//pr.println(".");
					state.send( "." , feedback );
					//System.out.println(in.readLine());
				} else {
					command = sc.nextLine();
					
					if (state != null) {
						if (command.startsWith( "rcpt to:" ) || command.startsWith( "RCPT TO:" )) {
							StringTokenizer stk = new StringTokenizer( command.replaceAll( "(?i)rcpt to:" , "" ) , ", " );
							
							while (stk.hasMoreTokens()) {
								String cmd = "RCPT TO: " + stk.nextToken();
//								System.out.println( cmd );
								feedback = state.send( cmd , feedback );
//							feedback = in.readLine();
//							System.out.println( feedback );
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
