

package oracleexample;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;

public class OracleConnection {

    private Connection connection = null;
    private String username = null;
    private String password = null;
    private String host = null;
    private int port;
    private String schema = null;

    public OracleConnection(String host, int port, String schema, 
            String username, String password) {
        this.host = host;
        this.port = port;
        this.schema = schema;
        this.username = username;
        this.password = password;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            System.out.println("JDBC check: PASSED!");
        } catch (ClassNotFoundException CNFEx) {
            System.out.println("JDBC check: NOT PASSED!");
            CNFEx.printStackTrace();
        }
    }

    public void openConnection() {
        try {
            String connString = "jdbc:oracle:thin:@" + this.host + ":" + 
                    this.port + ":" + this.schema;
            this.connection = DriverManager.getConnection(connString, 
                    this.username, this.password);
            if (this.connection != null) {
                System.out.println("We are connected!");
            } else {
                System.out.println("Failed to make a connection!");
            }
        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
        }
    }

    public void closeConnection() {
        try {
            this.connection.close();
            System.out.println("Connection closed!");
        } catch (Exception e) {
            System.out.println("Connection NOT closed!");
            e.printStackTrace();
        }
    }

    public void exemplu_functie(int gradSal) {
        try {
            String call = "{? = call pck_example.exemplu_functie(?, ?, ?)}";
            CallableStatement cstmt = this.connection.prepareCall(call);
            // register parameters
            cstmt.registerOutParameter(1, oracle.jdbc.OracleTypes.NUMBER);            
            cstmt.setInt(2, gradSal);            
            cstmt.registerOutParameter(3, oracle.jdbc.OracleTypes.NUMBER);
            cstmt.registerOutParameter(4, oracle.jdbc.OracleTypes.NUMBER);
            cstmt.executeQuery();
            // get the department's name
            Float avgVenit = cstmt.getFloat(1);
            Float salLow = cstmt.getFloat(3);
            Float salHigh = cstmt.getFloat(4);
            
            System.out.println(avgVenit + "\t" + salLow + "\t" + salHigh);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void exemplu_procedura(int idDept) {
        try {
            String call = "{call pck_example.exemplu_procedura(?,?, ?)}";
            CallableStatement cstmt = this.connection.prepareCall(call);
            cstmt.setInt("idDept", idDept);
            // register the out paremeters
            cstmt.registerOutParameter("numeDept", oracle.jdbc.OracleTypes.VARCHAR);
            cstmt.registerOutParameter("angajati", oracle.jdbc.OracleTypes.CURSOR);
            cstmt.executeQuery();
            // get the department's name
            String numeDept = cstmt.getString("numeDept");
            // get the cursor
            ResultSet rs = (ResultSet) cstmt.getObject("angajati");
            while (rs.next()) {
                System.out.println(rs.getString("ename") + "\t" + rs.getString("hiredate") + "\t" + 
                        rs.getString("job") + "\t" + rs.getInt("venit") + "\t" + numeDept);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}


