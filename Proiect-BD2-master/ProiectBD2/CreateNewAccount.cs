using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ProiectBD2
{
    public partial class CreateNewAccount : Form
    {
        public CreateNewAccount()
        {
            InitializeComponent();
        }

        private void CreateNewAccount_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            bool hasCreated = false;

            using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
            {

                conn.Open();
                using (SqlCommand cmd = new SqlCommand("addUser", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@user", textBox1.Text));
                    cmd.Parameters.Add(new SqlParameter("@pass", textBox2.Text));
                    cmd.Parameters.Add(new SqlParameter("@budget", 8000));

                    try
                    {
                        var rdr = cmd.ExecuteNonQuery();

                        if (rdr == 1)
                        {
                            hasCreated = true;
                        }
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 2601 || ex.Number == 2627)
                        {
                            hasCreated = false;
                        }
                    }
                }
            }

            if (!hasCreated)
            {
                label3.Text = "Account already exists!";
                label3.ForeColor = Color.Red;
            }
            else
            {
                label3.ForeColor = Color.Black;
                label3.Text = "Account created successfully!";
            }
        }
    }
}
