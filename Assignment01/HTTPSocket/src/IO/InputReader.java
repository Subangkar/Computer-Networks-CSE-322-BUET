package IO;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * Created by Subangkar on 03-Nov-18.
 */
public class InputReader {
	
	private BufferedReader bufferedReader;
	
	public InputReader( InputStream in ){
		bufferedReader = new BufferedReader( new InputStreamReader( in ) );
	}
	
	public String readNextLine() throws IOException {
		return bufferedReader.readLine();
	}
	
}
