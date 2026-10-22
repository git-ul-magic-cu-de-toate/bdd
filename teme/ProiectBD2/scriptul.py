import pyodbc 
import matplotlib.pyplot as plt

class MSSQLConnection:
    def __init__(self):
        self.host = 'localhost\SQLEXPRESS'
        self.port = '1433'
        self.database = 'parc_eco_db'
        self.username = 'vladv'
        self.password = '8722'

    def openConnection(self):
        try:
            self.db = pyodbc.connect('DRIVER={ODBC Driver 18 for SQL Server};SERVER='+self.host+';DATABASE='+self.database+';ENCRYPT=yes;TrustServerCertificate=yes;UID='+self.username+';PWD='+ self.password + ';Trusted_Connection=yes')
            self.cursor = self.db.cursor()
            print("Connection open!")
        except Exception as e:
            print("Connection not open!")
            print(e)
 
    def closeConnection(self):
        try:
            self.cursor.close()
            self.db.close()
            print("Connection close!")
        except Exception as e:
            print("Connection not closed!")
            print(e)

    def GetHabitatPlantSum1(self):
        try:
            cmd = "EXEC dbo.GetHabitatPlantSum1 @minTotalPlantCount = 1;"
            self.cursor.execute(cmd) 
            return self.cursor.fetchall()
        except Exception as e:
            print(e)

    def GetHabitatAnimalSum1(self):
        try:
            cmd = "EXEC dbo.GetHabitatAnimalSum1 @minTotalAnimalCount = 1;"
            self.cursor.execute(cmd) 
            return self.cursor.fetchall()
        except Exception as e:
            print(e)

def HabitatGraph(arr, type):
    labels, values = zip(*arr)
    plt.bar(labels, values)

    plt.xlabel('Location')
    plt.ylabel('Count')
    title = 'Count of ' + type + ' per Habitat'
    plt.title(title)

    plt.show()

if __name__ == "__main__":
    oc = MSSQLConnection()
    oc.openConnection()
    HabitatGraph(oc.GetHabitatPlantSum1(), "plants")
    HabitatGraph(oc.GetHabitatAnimalSum1(), "animals")
    oc.closeConnection()