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

namespace ProiectBD2 {
    public partial class FirstPage : Form {
        public FirstPage() {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e) {
            
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string user = null;
            bool doesExist = false;
            // check if user exists in data base
            using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
            {

                conn.Open();
                using (SqlCommand cmd = new SqlCommand("loginUser", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@user", textBox1.Text));
                    cmd.Parameters.Add(new SqlParameter("@pass", textBox2.Text));

                    SqlDataReader rdr = null;
                    rdr = cmd.ExecuteReader();

                    if (rdr.Read())
                    {
                        user = rdr[0].ToString();
                        var pass = rdr[1].ToString();

                        if (user.Equals(textBox1.Text) && pass.Equals(textBox2.Text))
                        {
                            doesExist = true;
                        }
                    }
                }
            }

            if (doesExist)
            {
                var page = new AppPage();
                page.User = user;
                page.Show();
            } else
            {
                label3.Text = "Invalid credentials";
            }
        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            new CreateNewAccount().Show();
        }
    }
}
