/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package small.utilities;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import jolie.runtime.FaultException;
import jolie.runtime.JavaService;
import jolie.runtime.Value;

/**
 *
 * @author claudio
 */
public class CSVImport extends JavaService {

    public Value importFile(Value request) throws FaultException {
        String filename = request.getFirstChild("filename").strValue();
        String separator = request.getFirstChild("separator").strValue();
        boolean verbose = false;
        if ( request.getFirstChild("verbose").isDefined() ) {
            verbose = request.getFirstChild("verbose").boolValue();
        }
        Value response = Value.create();
        try {
            CSVScanner scanner = new CSVScanner(separator.charAt(0), filename);
            ArrayList<String> columns = scanner.getLine();
            ArrayList<String> values = scanner.getLine();
            int l = 0;
            while (values != null) {
                if ( verbose ) {
                    System.out.println( "read line " + l + ", " + values.toString() );
                }
                Value currentLine = response.getChildren("line").get(l);
                for (int i = 0; i < columns.size(); i++) {
                    currentLine.getFirstChild(columns.get(i)).setValue(values.get(i));
                }
                values = scanner.getLine();
                l++;
                
            }
        } catch (FileNotFoundException ex) {
            throw new FaultException("FileNotFound");
        } catch (IOException ex) {
            throw new FaultException("IOException");
        }
        return response;
    }
}