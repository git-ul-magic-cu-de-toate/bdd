using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace MSSQLExample
{
    class MSSQLConnection
    {
        private string host;
        private int port;
        private string dbname;
        private string username;
        private string password;
        private SqlConnection conn;
        private SqlCommand com;
        
        public MSSQLConnection(string host, int port, string dbname,
                string username, string password)
        {
            this.host = host;
            this.port = port;
            this.dbname = dbname;
            this.username = username;
            this.password = password;
            string connString = "Data Source=" + this.host +
                ", " + this.port + ";Initial Catalog=" + this.dbname +
                ";User ID=" + this.username + ";Password=" + this.password;
            this.conn = new SqlConnection(connString);
        }

        public void exempluProcedura(int idDept)
        {
            try
            {
                this.conn.Open();
                this.com = new SqlCommand("exemplu_procedura", this.conn);
                this.com.CommandType = CommandType.StoredProcedure;

                SqlParameter idDeptParam = new SqlParameter("@idDept", SqlDbType.Int);
                idDeptParam.Direction = ParameterDirection.Input;
                idDeptParam.Value = idDept;

                SqlParameter numeDeptParam = new SqlParameter("@numeDept", SqlDbType.VarChar, 10);
                numeDeptParam.Direction = ParameterDirection.Output;

                this.com.Parameters.Add(idDeptParam);
                this.com.Parameters.Add(numeDeptParam);
                SqlDataAdapter adapter = new SqlDataAdapter(this.com);

                DataTable dt = new DataTable();
                adapter.Fill(dt);

                string numeDept = Convert.ToString(com.Parameters["@numeDept"].Value);
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        Console.WriteLine(dr["ename"] + "\t" + dr["hiredate"] 
                            + "\t" + dr["job"] + "\t" + dr["venit"] + "\t" + numeDept);
                    }
                }
            }
            catch (Exception exp)
            {
                Console.WriteLine("Eroare Procedura!\r\n" + exp.ToString());
            }
            finally
            {
                this.com.Parameters.Clear();
                this.com.Dispose();
                this.conn.Close();
            }
        }

        public void exempluFunctie(int grad)
        {
            try
            {
                this.conn.Open();
                this.com = new SqlCommand("exemplu_functie", this.conn);
                this.com.CommandType = CommandType.StoredProcedure;

                SqlParameter gradSalParam = new SqlParameter("@gradSal", SqlDbType.Int);
                gradSalParam.Direction = ParameterDirection.Input;
                gradSalParam.Value = grad;

                SqlParameter avgVenitParam = new SqlParameter("@Result", SqlDbType.Real);
                avgVenitParam.Direction = ParameterDirection.ReturnValue;

                this.com.Parameters.Add(gradSalParam);
                this.com.Parameters.Add(avgVenitParam);

                this.com.ExecuteNonQuery();

                if (avgVenitParam.Value != DBNull.Value)
                {
                    Console.WriteLine("Venit mediu:" + avgVenitParam.Value);
                }
            }
            catch (Exception exp)
            {
                Console.WriteLine("Eroare Functie!\r\n" + exp.ToString());
            }
            finally
            {
                this.com.Parameters.Clear();
                this.com.Dispose();
                this.conn.Close();
            }
        }
    }
}


