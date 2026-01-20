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
    public partial class WishlistCollection : Form
    {
        public string User
        {
            get; set;
        }

        public WishlistCollection()
        {
            InitializeComponent();
        }

        private void WishlistCollection_Load(object sender, EventArgs e)
        {
            listView1.View = View.Details;
            listView2.View = View.Details;
            List<long> productIds = new List<long>();

            using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
            {

                conn.Open();
                
                // getting the product ids
                using (SqlCommand cmd = new SqlCommand("selectIdsFromWishlistByUser", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@user", User));

                    SqlDataReader rdr = null;
                    rdr = cmd.ExecuteReader();

                    while (rdr.Read())
                    {
                        long id = long.Parse(rdr[0].ToString());
                        productIds.Add(id);
                    }

                    rdr.Close();
                }

                productIds = productIds.Distinct().ToList(); // eliminate duplicates

                // gotta select the albums
                foreach (var id in productIds)
                {
                    using (SqlCommand cmd = new SqlCommand("selectAlbumsById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add(new SqlParameter("@product_id", id));

                        SqlDataReader rdr = null;
                        rdr = cmd.ExecuteReader();

                        while (rdr.Read())
                        {
                            listView1.Items.Add(new ListViewItem(new string[] { rdr[1].ToString(), // artist
                                                                            rdr[0].ToString(), // album
                                                                            rdr[5].ToString(), // year
                                                                            rdr[3].ToString(), // genre
                                                                            rdr[4].ToString(), // price
                                                                            rdr[2].ToString() })); // ID
                        }

                        rdr.Close();
                    }
                }

                // gotta select the songs
                foreach (var id in productIds)
                {
                    using (SqlCommand cmd = new SqlCommand("selectSongsById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add(new SqlParameter("@product_id", id));

                        SqlDataReader rdr = null;
                        rdr = cmd.ExecuteReader();

                        while (rdr.Read())
                        {
                            listView2.Items.Add(new ListViewItem(new string[] { rdr[2].ToString(), // name
                                                                            rdr[1].ToString(), // artist
                                                                            rdr[0].ToString(), // album
                                                                            rdr[4].ToString(), // genre
                                                                            rdr[3].ToString(), // year
                                                                            rdr[6].ToString(), // price
                                                                            rdr[5].ToString()})); // id
                        }

                        rdr.Close();
                    }
                }
            }
        }
    }
}
