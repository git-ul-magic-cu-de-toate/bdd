using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSSQLExample
{
    class Program
    {
        static void Main(string[] args)
        {
            MSSQLConnection mssqlconn = new MSSQLConnection("localhost", 1433, "hr", "sa", "123456");
            mssqlconn.exempluProcedura(10);
            mssqlconn.exempluFunctie(3);
            Console.Read();
        }
    }
}


