package Socket.SMTP.Client;

import java.io.*;
import java.net.InetAddress;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.nio.file.Files;
import java.util.Base64;
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
//			obj.attach();
//			obj.run( args );
//			obj.testAttachment();
			obj.sendAttachment( "C:\\Users\\Subangkar\\Desktop\\NETWORK\\Assignment01\\HTTPSocket\\jpgpic.jpg","Text Part" );
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void run( String[] args ) throws Exception {
//		testAttachment();
		
		//while (true) {
		feedback = in.readLine();
		System.out.println( feedback );
		state.transition( feedback , "" );
		//    System.out.println(feedback);
		String command;
		while (true) {
			try {
				
				if (state == null) {
					break;
				}
				state.print( state.name );
				command = "";
				if (state.name.equalsIgnoreCase( "WritingData" )) {
					String body;
					while (!(body = sc.nextLine()+"\r\n").startsWith( "." )){
						command = command + "\r\n" + body;
						pr.print( body );
						System.out.print( ">> " + body );
					}
					state.send( "." , feedback );
//					pr.flush();
//					writeMailBody( command );
//					System.out.println("Here");
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
	
	
	void writeMailBody( String command ) throws IOException {
		
		if (command.startsWith( "-attachments: " )) {
			String message = command.substring( command.indexOf( "\r\n" , command.indexOf( "Subject: " ) ) + 1 );
			sendAttachment( command.substring( command.indexOf( ':' ) + 1 ) , message );
		} else {
			Scanner scanner = new Scanner( command );
			while (scanner.hasNextLine())
				pr.write( scanner.nextLine() + "\r\n" );
//			pr.println();
			state.send( "." , feedback );
			pr.flush();
		}
//		smtpSocket.getOutputStream().write( command.getBytes() );
//		pr.flush();
//		testAttachment();
//		pr.println();
//		state.send( "." , feedback );
//		pr.flush();
		System.out.println( ">> Written Mail Body" );
	}
	
	void testAttachment() throws IOException {
//		File file = new File("C:\\Users\\Subangkar\\Desktop\\NETWORK\\Assignment01\\SMTPClient\\script.sh");
//		if(!file.canRead()) return;
//		byte[] encoded = new byte[0];
//		try {
//			encoded = Files.readAllBytes(file.toPath());
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//		String img_code = Base64.getMimeEncoder().encodeToString(encoded);
//
//		pr.println("Subject: Freaking\r\n" +
//				           "From: <msshamil.xcp@yahoo.com>\r\n" +
//				           "To: <1505021.mss@ugrad.cse.buet.ac.bd>\r\n" +
//				           "To: <zahinwahab@gmail.com>\r\n" +
//				           "MIME-Version: 1.0\r\n" +
//				           "Content-type: multipart/mixed; boundary=\"simple boundary\"\r\n" +
//				           "\r\n" +
//				           "This is the preamble.  It is to be ignored, though it is a handy place for mail composers to include an explanatory note to non-MIME compliant readers.\r\n" +
//				           "--simple boundary\r\n" +  "msg\r\n" + "--simple boundary\r\n"+
//				           "Content-Type: "+Files.probeContentType( file.toPath() )+"\r\n" +
//				           "Content-Transfer-Encoding: Base64\r\n" +
//				           "Content-Disposition: attachment; filename="+file.getName()+"\r\n"+
//				           img_code + "\r\r\n" +
//				           "--simple boundary--\r\n"+
//				           "");
//		System.out.println(img_code);
//		System.out.println(Files.probeContentType( file.toPath() ));
//		pr.flush();
		
		try {
			Scanner sc1 = new Scanner( new File( "attach.txt" ) );
			while (sc1.hasNextLine()) {
				pr.println( sc1.nextLine() );
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	void sendAttachment( String fileName , String message ) throws IOException {
		File file = new File( fileName );
		if (!file.canRead()) return;
		byte[] encoded = new byte[0];
		try {
			encoded = Files.readAllBytes( file.toPath() );
		} catch (IOException e) {
			e.printStackTrace();
		}
		String img_code = Base64.getMimeEncoder().encodeToString( encoded );
		
		
		
		InetAddress mailHost = InetAddress.getByName( mailServer );
		InetAddress localHost = InetAddress.getLocalHost();
		Socket smtpSocket = new Socket( mailHost , 1050 );
		BufferedReader in = new BufferedReader( new InputStreamReader( smtpSocket.getInputStream() ) );
		PrintWriter pr = new PrintWriter( smtpSocket.getOutputStream() , true );
		String initialID = in.readLine();
		System.out.println( initialID );
		pr.println( "HELO " + localHost.getHostName() );
		pr.flush();
		String welcome = in.readLine();
		System.out.println( welcome );
		
		String msg;
		pr.println( "mail from: msshamil.xcp@yahoo.com " );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		pr.println( "rcpt to:<1505021.mss@ugrad.cse.buet.ac.bd>" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		
		pr.println( "rcpt to:<zahinwahab@gmail.com>" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		
		pr.println( "DATA" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		
		
		pr.println( "Subject: SMTP_Attachment\r\n" +
				            "MIME-Version: 1.0\r\n" +
				            "Content-Type: multipart/mixed;\r\n" +
				            "\tboundary=\"----=_NextPart_000_038E_01D47443.F07FDF90\"\r\n" +
				            "\r\n" +
				            "This is a multipart message in MIME format.\r\n" +
				            "\r\n" +
				            "------=_NextPart_000_038E_01D47443.F07FDF90\r\n" +
				            "Content-Type: multipart/alternative;\r\n" +
				            "\tboundary=\"----=_NextPart_001_038F_01D47443.F07FDF90\"\r\n" +
				            "\r\n" +
				            "\r\n" +
				            "------=_NextPart_001_038F_01D47443.F07FDF90\r\n" +
				            "Content-Type: text/plain;\r\n" +
				            "\tcharset=\"us-ascii\"\r\n" +
				            "Content-Transfer-Encoding: 7bit\r\n" +
				            "\r\n" +
				            message +
				            "\r\n" +
				            "\r\n" +
				            "\r\n" +
				            "\r\n" +
				            "------=_NextPart_001_038F_01D47443.F07FDF90--\r\n" +
				            "\r\n" +
				            "------=_NextPart_000_038E_01D47443.F07FDF90\r\n" +
				            "Content-Type: "+Files.probeContentType( file.toPath() )+";\r\n" +
				            "\tname=\""+file.getName()+"\"\r\n" +
				            "Content-Transfer-Encoding: base64\r\n" +
				            "Content-Disposition: attachment;\r\n" +
				            "\tfilename=\""+file.getName()+"\"\r\n" +
				            "\r\n" +
				            img_code +
				            "\r\n" +
				            "------=_NextPart_000_038E_01D47443.F07FDF90--\n" +
				            "\r\n" +
				            ".\r\n" );
		
		
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		pr.println( "quit" );
		msg = in.readLine();
		System.out.println( msg );
	}
	
	void attach() throws IOException {
		File file = new File( "C:\\Users\\Subangkar\\Desktop\\NETWORK\\Assignment01\\HTTPSocket\\jpgpic.jpg" );
		byte[] encoded = Files.readAllBytes( file.toPath() );
		String img_code = Base64.getMimeEncoder().encodeToString( encoded );
		InetAddress mailHost = InetAddress.getByName( mailServer );
		InetAddress localHost = InetAddress.getLocalHost();
		Socket smtpSocket = new Socket( mailHost , 1050 );
		BufferedReader in = new BufferedReader( new InputStreamReader( smtpSocket.getInputStream() ) );
		PrintWriter pr = new PrintWriter( smtpSocket.getOutputStream() , true );
		String initialID = in.readLine();
		System.out.println( initialID );
		pr.println( "HELO " + localHost.getHostName() );
		pr.flush();
		String welcome = in.readLine();
		System.out.println( welcome );

		String msg;
		pr.println( "mail from: msshamil.xcp@yahoo.com " );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		pr.println( "rcpt to:<1505021.mss@ugrad.cse.buet.ac.bd>" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		
		pr.println( "rcpt to:<zahinwahab@gmail.com>" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		
		pr.println( "DATA" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );
		
		pr.print( "Subject: Image Sender\r\n" +
				            "From: msshamil.xcp@yahoo.com\r\n" +
				            "To: subangkar.karmaker@gmail.com\r\n" +
				            "To: 1505015.skb@ugrad.cse.buet.ac.bd\r\n" +
				            "MIME-Version: 1.0\r\n" +
				            "Content-type: multipart/mixed; boundary=\"simple boundary\"\r\n" +
				            "\r\n" +
				            "This is the preamble.  It is to be ignored, though it is a handy place for mail composers to include an explanatory note to non-MIME compliant readers.\r\n" +
				            "--simple boundary\r\n" + "msg\r\n" + "--simple boundary\r\n" +
				            "Content-Type: "+Files.probeContentType( file.toPath() )+"\r\n" +
				            "Content-Transfer-Encoding: Base64\r\n" +
				            "Content-Disposition: attachment; filename="+file.getName()+"\r\n" +
				            img_code + "\r\n" +
				            "--simple boundary--\r\n\r\n" +
				            ".\r\n" );
		pr.flush();
		msg = in.readLine();
		System.out.println( msg );

		pr.println( "quit" );
		msg = in.readLine();
		System.out.println( msg );
		
	}
}
