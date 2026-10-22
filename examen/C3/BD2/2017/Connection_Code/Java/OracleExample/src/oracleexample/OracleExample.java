/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package oracleexample;

public class OracleExample {
    public static void main(String[] args) {
        OracleConnection oc = new OracleConnection("localhost", 1521, 
                "ORCL", "student", "student");
        oc.openConnection();
        oc.exemplu_procedura(10);
        oc.exemplu_functie(3);
        oc.closeConnection();
    }
}

