/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package small.utilities;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/**
 *
 * @author claudio
 */
public class CSVScanner {

    private final char separator;
    private final BufferedReader reader;
    private final FileInputStream istream;

    public CSVScanner(char separator, String filename) throws FileNotFoundException {
        this.separator = separator;
        File csvFile = new File(filename);
        istream = new FileInputStream(csvFile);
        reader = new BufferedReader(new InputStreamReader(istream));
    }

    public ArrayList<String> getLine() throws IOException {
        ArrayList<String> result = null;

        String line = reader.readLine();
        if (line != null) {
            result = new ArrayList<>();
            String token = "";
            boolean isString = false;
            boolean currentLine = true;
            while (currentLine) {
                for (int i = 0; i < line.length(); i++) {
                    if (line.charAt(i) == separator && !isString) {
                        result.add(new String(token.getBytes(), "UTF-8"));
                        token = "";
                    } else if (line.charAt(i) == '"' && !isString) {
                        isString = true;
                    } else if (line.charAt(i) == '"' && isString) {
                        isString = false;
                    } else {
                        token = token + line.charAt(i);
                    }
                }
                if (isString) {
                    line = reader.readLine();
                } else {
                    currentLine = false;
                }
            }

            // last token
            result.add(new String(token.getBytes(), "UTF-8"));
        }

        return result;
    }

    public void close() throws IOException {
        reader.close();
        istream.close();
    }

}
