package Socket.HTTP.Server;


import java.io.*;
import java.net.ServerSocket;

public class Main {
	private static final int PORT = 420;
	
	public static void main( String[] args ) throws IOException {
		
		ServerSocket serverConnect = new ServerSocket( PORT );
		System.out.println( "Server started.\nListening for connections on port : " + PORT + " ...\n" );
		while (true) new ClientManager( serverConnect.accept() ).start();
	}
	
	
}




