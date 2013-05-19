import java.io.BufferedReader;
import java.io.Closeable;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;


public class SliceHtml {
	
		static String [] formatArguments(String [] rawArgs) {
			int max = rawArgs.length -1;
			int start = 0;
			for(int i=0; i <= max ; i++) {
				if(rawArgs[i].contains("SliceHtml")) {
					start = i+1;
					break;
				}
			}
			if((max - start + 1) >= 3) {
				String [] r = new String[max - start + 1];
				for(int i=start;i<= max;i++) {
					r[i-start] = rawArgs[i];
				}
				return r;
			} else {
				return new String[0];
			}
		} 

		public static void main(String [] args) throws IOException {
			String ending="</html>";
			String targetFileName="/tmp/dd.tmp.html";
			String cmd="ls";
			
			args = formatArguments(args);
			if(args.length >= 1) ending = args[0];
			if(args.length >= 2) targetFileName= args[1]; 
			if(args.length >= 3) cmd = args[2];
			

			
			
			int endingSize=ending.length();
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in, "UTF-8"));
			PrintStream out = createOut(targetFileName);
			String line = null;
				try {
					while( null != (line=br.readLine()) ) {
						out.println(line);
						if(line.length() == endingSize && ending.equals(line)) {
							out.close();
							runCommand(cmd);
							out = createOut(targetFileName);
						}
					}
				} finally {
					finallyClose(br);
					finallyClose(out);
				}
		}
		
		static PrintStream createOut(String targetFileName) throws FileNotFoundException, UnsupportedEncodingException {
			return new PrintStream(new File(targetFileName), "UTF-8");
		}
		
		static String runCommand(String cmd) throws IOException {
			ProcessBuilder pb = new ProcessBuilder(cmd);
			InputStream in = pb.start().getInputStream();
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			StringBuffer sb = new StringBuffer();
			
			String line = null;
			try {
				while(null != (line= br.readLine())) {
					sb.append(line).append("\n");
				}
			} finally {
				finallyClose(br);
			}
			return sb.toString();
		}
		
		static void finallyClose(Closeable stream) {
			if(null != stream) {
				try {
					stream.close();
				} catch (IOException e) {
				}
			}
		}
}
