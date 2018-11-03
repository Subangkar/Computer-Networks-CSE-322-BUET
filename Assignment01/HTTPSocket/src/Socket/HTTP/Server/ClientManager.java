package Socket.HTTP.Server;

import IO.FileIOManager;
import IO.InputReader;
import IO.OutputWriter;

import java.io.IOException;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * Created by Subangkar on 03-Nov-18.
 */
public class ClientManager implements Runnable {
	
	private String name;
	private Socket client;
	
	
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
			OutputWriter out = new OutputWriter( this.client.getOutputStream() );
			String input = in.readNextLine();
			writeLog( "Here Input : " + input );
			
			out.writeLine( "HTTP/1.1 200 OK" );
			out.writeLine( "Content-Type: text/html" );
			out.writeLine( "Connection: close" );
			out.writeLine();
			
			out.write( FileIOManager.readFileToCharString( "index.html" , StandardCharsets.UTF_8 ) );
			writeLog( "Terminating Connection" );
			client.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
	private void writeLog( String log ) {
		System.out.println(  new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(Calendar.getInstance().getTime()) + " >> " + client.getInetAddress().getHostAddress() + ":" + client.getPort() + " >> " + log );
	}
}
