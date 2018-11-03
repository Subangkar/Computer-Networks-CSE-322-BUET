package Socket.HTTP.Server;


import IO.FileIOManager;
import IO.InputReader;
import IO.OutputWriter;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class Main {
		private static final int PORT = 420;

	public static void main( String[] args ) throws IOException {

		ServerSocket serverConnect = new ServerSocket( PORT );
		System.out.println( "Server started.\nListening for connections on port : " + PORT + " ...\n" );
		while (true) {
			try(Socket s = serverConnect.accept()) {
				InputReader in = new InputReader( s.getInputStream() );
				OutputWriter pr = new OutputWriter( s.getOutputStream() );
				String input = in.readNextLine();
				System.out.println( "Here Input : " + input );

				pr.writeLine( "HTTP/1.1 200 OK" );
				pr.writeLine( "Content-Type: text/html" );
				pr.writeLine();

				pr.write( FileIOManager.readFileToCharString( "index.html", StandardCharsets.UTF_8 ) );
//				pr.write( "<TITLE>Example</TITLE>" );
//				pr.write( "<P><b>An example.</b></P>" );
				System.out.println( "Sent" );
			}
		}
	}

//	public static void main( String args[] ) throws IOException {
//
//		ServerSocket serverConnect = new ServerSocket( PORT );
//		System.out.println( "Server started.\nListening for connections on port : " + PORT + " ...\n" );
//		while (true) {
//			try (Socket socket = serverConnect.accept()) {
//				Date today = new Date();
//				OutputWriter pr = new OutputWriter( socket.getOutputStream() );
//				String httpResponse = "HTTP/1.1 200 OK\r\n\r\n";// + today;
//				pr.write( httpResponse );
//				pr.write("<TITLE>Example</TITLE>");
//				pr.write("<P>Ceci est une page d'exemple.</P>");
//			}
//		}
//	}
}




