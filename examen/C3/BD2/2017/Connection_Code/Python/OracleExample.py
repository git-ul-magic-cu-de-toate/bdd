import cx_Oracle

class OracleConnection:

    def __init__(self, host, port, schema, username, password):
        self.host = host
        self.port = port
        self.schema = schema
        self.username = username
        self.password = password

    def openConnection(self):
        try:
            connString = self.username + "/" + self.password 
            connString += "@//" + self.host + ":" + str(self.port) 
            connString += "/" + self.schema
            self.db = cx_Oracle.Connection(connString)
            self.cursor = self.db.cursor()
            print "Connection open!"
        except Exception, e:
            print "Connection not open!"
            print e

    def closeConnection(self):
        try:
            self.cursor.close()
            self.db.close()
            print "Connection close!"
        except Exception, e:
            print "Connection not closed!"
            print e

    def exempluProcedura(self, idDept):
        try:
            numeDept = self.cursor.var(cx_Oracle.STRING)
            angajati = self.cursor.var(cx_Oracle.CURSOR)
            self.cursor.callproc("pck_example.exemplu_procedura", [idDept, numeDept, angajati]) 
            for elem in angajati.getvalue():
                print elem[0], elem[1].strftime("%Y-%m-%d"), elem[2], elem[3], numeDept.getvalue()
        except Exception, e:
            print e

    def exempluFunctie(self, salGrad):
        try:
            salLow = self.cursor.var(cx_Oracle.NUMBER)
            salHigh = self.cursor.var(cx_Oracle.NUMBER)
            avgVenit = self.cursor.callfunc("pck_example.exemplu_functie", cx_Oracle.NUMBER, [salGrad, salLow, salHigh])
            print avgVenit, salLow.getvalue(), salHigh.getvalue()
        except Exception, e:
            print e

if __name__ == "__main__":
    oc = OracleConnection('localhost', 1521, 'orcl', 'student', 'student')
    oc.openConnection()
    oc.exempluProcedura(10)
    oc.exempluFunctie(2)
    oc.closeConnection()