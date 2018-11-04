package Socket.HTTP.Server;

import IO.FileIOManager;
import IO.InputReader;
import IO.OutputWriter;

import java.io.File;
import java.io.IOException;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.StringTokenizer;

/**
 * Created by Subangkar on 03-Nov-18.
 */
public class ClientManager implements Runnable {
	
	private String name;
	private Socket client;
	
	private OutputWriter out;
	
	private final String NOT_FOUND = "<html>\n" + "<head><title>404 Not Found</title></head>\n" +
			                                 "<body bgcolor=\"white\">\n" +
			                                 "<center><h1>404 Not Found</h1></center>\n" +
			                                 "<hr><center>:/</center>\n" +
			                                 "</body>\n" +
			                                 "</html>";
	
	public ClientManager( String name , Socket client ) {
		this.name = name;
		this.client = client;
	}
	
	ClientManager( Socket client ) {
		this.client = client;
		name = "Client";
	}
	
	void start() {
		writeLog( "Accepting Connection" );
		new Thread( this , name ).start();
	}
	
	@Override
	public void run() {
		try {
			InputReader in = new InputReader( this.client.getInputStream() );
			out = new OutputWriter( this.client.getOutputStream() );
			var input = in.readNextLine();
			writeLog( "New Request line: " + input );
			
			if (input.isEmpty() || input.isBlank()) {
				INVALID_Handler();
			} else {
				StringTokenizer stk;
				stk = new StringTokenizer( input , " " );
				String req, path, httpType;
				req = stk.nextToken();
				path = stk.nextToken();
				httpType = stk.nextToken();
				
				if (!httpType.equalsIgnoreCase( "HTTP/1.1" )) {
					INVALID_Handler();
				}
				else if (req.equalsIgnoreCase( "GET" )) {
					GET_Handler( path );
				} else if (req.equalsIgnoreCase( "POST" )) {
					POST_Handler( path );
				} else {
					INVALID_Handler();
				}
			}
			
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
	private void writeLog( String log ) {
		System.out.println( new SimpleDateFormat( "yyyy-MM-dd HH:mm:ss" ).format( Calendar.getInstance().getTime() ) + " >> " + client.getInetAddress().getHostAddress() + ":" + client.getPort() + " >> " + log );
	}
	
	
	private void GET_Handler( String path ) throws IOException {
		
		if (path.equalsIgnoreCase( "/" )) path = "/index.html";
		
		File file = new File( path.substring( 1 ) );
		
		if (!file.exists()) {
			writeLog( path + " File Not Found in Directory" );
			out.writeLine( "HTTP/1.1 404 NOT FOUND" );
			out.writeLine();
			out.writeLine( NOT_FOUND );
		} else {
			writeLog( "Requested file: " + file.getPath() );
			
			out.writeLine( "HTTP/1.1 200 OK" );
			out.writeLine( "Content-Type: text/html" );
			out.writeLine( "Connection: close" );
			out.writeLine();
			
			out.write( FileIOManager.readFileToCharString( file.getPath() , StandardCharsets.UTF_8 ) );
		}
		writeLog( "Terminating Connection" );
		client.close();
	}
	
	private void POST_Handler( String path ) {
	
	}
	
	private void INVALID_Handler() throws IOException {
		writeLog( "Invalid request line without GET/POST" );
		out.writeLine( "HTTP/1.1 400 BAD REQUEST" );
		out.writeLine( "Connection: close" );
		out.writeLine();
		client.close();
	}
}
