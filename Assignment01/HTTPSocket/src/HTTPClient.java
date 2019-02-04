import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.Scanner;

/**
 * Created by Subangkar on 12-Nov-18.
 */
public class HTTPClient {
	
	public static void main(String[] args) throws Exception {
		
		Scanner sc=new Scanner( System.in );
		
		InetAddress addr = InetAddress.getLocalHost();
		Socket socket = new Socket (addr, 8080);
		PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
		BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		
		System.out.print("Enter url: ");
		String url=sc.nextLine();
		out.println("GET "+url+" HTTP/1.1");
		out.println();
		String s = in.readLine();
		System.out.println(">> "+url);
		
		while(true)
		{
			if(s==null) break;
			System.out.println(s);
			if(s.equals( "HTTP/1.1 401 Unauthorized" )){
				socket = new Socket( addr , 8080 );
				out = new PrintWriter( socket.getOutputStream() , true );
				in = new BufferedReader( new InputStreamReader( socket.getInputStream() ) );
				
				System.out.print("name: ");
				String username=sc.nextLine().trim();
				System.out.print("pass: ");
				String pass=sc.nextLine().trim();
//				out.println("GET / HTTP/1.1");
				out.println( "GET "+url+" HTTP/1.1" );
				out.println("Xauth:"+username+"+"+pass);
				char[] buf = new char[10000];
				in.read( buf );
				String rep = new String( buf );
				if(rep.startsWith( "HTTP/1.1 200 OK" )){
					System.out.println(">> Reply from Server:\n"+rep);
					in.read( buf );
					System.out.println(new String( buf ));
//					System.out.println(new String( buf ));
					break;
				}
				else{
					socket.close();
				}
			}
		}
//		socket.close();
	}
}