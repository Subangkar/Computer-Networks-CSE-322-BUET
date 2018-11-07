package Socket.SMTP.Client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.Scanner;

public class SMTP {
	
	Scanner sc;
	String user;
	String password;
	public static final String mailServer = "smtp.sendgrid.net";
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
		user = "c3BvbmRvbg==";
		password = "U3BvbmRvbjc3";
		sc = new Scanner( System.in );
		mailHost = InetAddress.getByName( mailServer );
		localHost = InetAddress.getLocalHost();
		smtpSocket = new Socket( mailHost , 587 );
		in = new BufferedReader( new InputStreamReader( smtpSocket.getInputStream() ) );
		pr = new PrintWriter( smtpSocket.getOutputStream() , true );
		// st = new State() ;
		
		
		
		
		
		state = new Begin(this);
	}
	
	String exec_state( String command , String feedback ) {
		String f = "";
		try {
			
			System.out.println( "msg:" + command + "/" );
			pr.println( command );
			pr.flush();
			
			f = in.readLine();
			System.out.println( f );
			//st.setState(f);
			
		} catch (Exception e) {
			f = "exception";
			e.printStackTrace();
		}
		//  System.out.println(f);
		return f;
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
		// while (true){
		feedback = in.readLine();
		System.out.println( feedback );
		while (true) {
			String command = sc.nextLine();
			System.out.println( "msg" + command );
			pr.println( command );
			
			pr.flush();
			
			String f = in.readLine();
			System.out.println( f );
			// feedback = exec_state(command, feedback) ;
		}
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	public State getState() {
		return state;
	}
	
	public void setState( State state ) {
		this.state = state;
	}
	
	
	
	void send(String msg){
		state.send(msg);
	}
}
