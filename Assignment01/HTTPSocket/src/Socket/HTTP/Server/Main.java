package Socket.HTTP.Server;


import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;

public class Main {
		private static final int PORT = 420;

	public static void main( String[] args ) throws IOException {

		ServerSocket serverConnect = new ServerSocket( PORT );
		serverConnect.setSoTimeout( 60000 );
		System.out.println( "Server started.\nListening for connections on port : " + PORT + " ...\n" );
		while (true) {
			try(Socket s = serverConnect.accept()) {
				ClientManager cl = new ClientManager( s );
				cl.start();
//				cl.run();
			}catch (SocketTimeoutException s) {
				System.out.println( "Socket timed out!" );
				break;
			}
		}
	}


}




