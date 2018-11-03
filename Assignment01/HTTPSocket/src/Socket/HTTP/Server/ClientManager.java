package Socket.HTTP.Server;

import IO.FileIOManager;
import IO.InputReader;
import IO.OutputWriter;

import java.io.IOException;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.nio.charset.StandardCharsets;

/**
 * Created by Subangkar on 03-Nov-18.
 */
public class ClientManager implements Runnable {
	
	private String name;
	private InputReader in;
	private OutputWriter out;
	private Socket client;
	
	
	public ClientManager( String name , Socket client ) throws IOException {
		this.name = name;
		this.client = client;
		in = new InputReader( this.client.getInputStream() );
		out = new OutputWriter( this.client.getOutputStream() );
		
	}
	
	ClientManager( Socket client ) throws IOException {
		this.client = client;
		name = "Client";
		
		in = new InputReader( this.client.getInputStream() );
		out = new OutputWriter( this.client.getOutputStream() );
		
		if (this.client.isClosed()) {
			System.out.println( ">>Closed" );
		}
	}
	
	public void start() {
		new Thread( this , name ).start();
	}
	
	@Override
	public void run() {
		try {
			if (this.client.isClosed()) {
				System.out.println( ">>>>Closed" );
			}
			String input = in.readNextLine();
			System.out.println( "Here Input : " + input );
			
			out.writeLine( "HTTP/1.1 200 OK" );
			out.writeLine( "Content-Type: text/html" );
			out.writeLine( "Connection: close" );
			out.writeLine();
			
			out.write( FileIOManager.readFileToCharString( "index.html" , StandardCharsets.UTF_8 ) );
			System.out.println( "Sent" );
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
