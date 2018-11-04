package Socket.HTTP.Server;

import IO.FileIOManager;
import IO.InputReader;
import IO.OutputWriter;

import java.io.File;
import java.io.IOException;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.StringTokenizer;

/**
 * Created by Subangkar on 03-Nov-18.
 */
public class ClientManager implements Runnable {
	
	private String name;
	private Socket client;
	
	private InputReader in;
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
			in = new InputReader( this.client.getInputStream() );
			out = new OutputWriter( this.client.getOutputStream() );
			String inp;
			var input = in.readNextLine();
			inp = input;
			writeLog( "New Request line: " + input );
			
			
			if (input == null || input.isEmpty() || input.isBlank()) {
				INVALID_Handler();
			} else {
//				while ((inp = in.readNextLine()) != null && !inp.isEmpty()) {
//					writeLog( "> " + inp );
//				}
				
				StringTokenizer stk;
				stk = new StringTokenizer( input , " " );
				String req, path, httpType;
				req = stk.nextToken();
				path = stk.nextToken();
				httpType = stk.nextToken();
				
				if (!httpType.equalsIgnoreCase( "HTTP/1.1" )) {
					INVALID_Handler();
				} else if (req.equalsIgnoreCase( "GET" )) {
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
		String logMsg = new SimpleDateFormat( "yyyy-MM-dd HH:mm:ss" ).format( Calendar.getInstance().getTime() ) + " >> " + client.getInetAddress().getHostAddress() + ":" + client.getPort() + " >> " + log;
		Main.logger += logMsg + "\r\n";
		Main.logFile.println( logMsg );
		System.out.println( logMsg );
		Main.logFile.flush();
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
			writeLog( "Sending File With MIME Type: " + Files.probeContentType( file.toPath() ) );
			
			
			out.writeLine( "HTTP/1.1 200 OK" );
			out.writeLine( "Content-Type: " + Files.probeContentType( file.toPath() ) );
			out.writeLine( "Connection: close" );
			out.writeLine();

//			out.write( FileIOManager.readFileToCharString( file.getPath() , StandardCharsets.UTF_8 ) );
			out.write( FileIOManager.readFileBytes( file.getPath() ) );
		}
		writeLog( "Terminating Connection" );
		client.close();
	}
	
	private void POST_Handler( String path ) throws IOException {
		while(true)
			writeLog( in.readNextLine() );
	}
	
	private void INVALID_Handler() throws IOException {
		writeLog( "Invalid request line without GET/POST" );
		out.writeLine( "HTTP/1.1 400 BAD REQUEST" );
		out.writeLine( "Connection: close" );
		out.writeLine();
		client.close();
	}
}
