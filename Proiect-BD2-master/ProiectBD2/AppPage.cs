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
    public partial class AppPage : Form
    {
        public string User { get; set; }

        public AppPage()
        {
            InitializeComponent();
        }

        private void AppPage_Load(object sender, EventArgs e)
        {
            // columns
            listView1.View = View.Details;
            listView2.View = View.Details;

            using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
            {

                conn.Open();

                // albums
                using (SqlCommand cmd = new SqlCommand("selectAlbums", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    // cmd.Parameters.Add(new SqlParameter("@pass", textBox2.Text));

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

                // songs
                using (SqlCommand cmd = new SqlCommand("selectSongs", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    // cmd.Parameters.Add(new SqlParameter("@pass", textBox2.Text));

                    SqlDataReader rdr = null;
                    rdr = cmd.ExecuteReader();

                    while (rdr.Read())
                    {
                        string album;
                        if (rdr[6] == null)
                        {
                            album = "non-album single";
                        } 
                        else
                        {
                            album = rdr[6].ToString();
                        }
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

        /// <summary> 
        /// Opens window with bought items
        /// </summary>
        private void button5_Click(object sender, EventArgs e)
        {
            var page = new ItemsCollection();
            page.User = User;
            page.Show();
        }

        /// <summary> 
        /// Opens window with items from wishlist
        /// </summary>
        private void button6_Click(object sender, EventArgs e)
        {
            var page = new WishlistCollection();
            page.User = User;
            page.Show();
        }

        /// <summary> 
        /// Adds song in cart and updates client's budget
        /// </summary>
        private void button1_Click(object sender, EventArgs e)
        {
            if (listView2.SelectedItems.Count == 1)
            {
                var item = listView2.SelectedItems[0];

                var name = item.SubItems[0].Text;
                var artist = item.SubItems[1].Text;
                var album = item.SubItems[2].Text;
                var genre = item.SubItems[3].Text;
                var year = item.SubItems[4].Text;
                var price = Int32.Parse(item.SubItems[5].Text);
                var id = long.Parse(item.SubItems[6].Text);

                using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
                {

                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("addCart", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@username", User));
                        cmd.Parameters.Add(new SqlParameter("@id_product", id));

                        try
                        {
                            var rdr = cmd.ExecuteNonQuery();
                        }
                        catch (SqlException ex)
                        {
                            MessageBox.Show("Song cannot be added in wishlist");
                        }
                    }

                    int userBudget = -1;

                    using (SqlCommand cmd = new SqlCommand("findUserBudget", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@user", User));

                        SqlDataReader rdr = null;
                        rdr = cmd.ExecuteReader();

                        while (rdr.Read())
                        {
                            userBudget = int.Parse(rdr[0].ToString());
                        }

                        rdr.Close();

                    }

                    userBudget -= price;

                    if (userBudget >= 0)
                    {
                        using (SqlCommand cmd = new SqlCommand("updateBudget", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add(new SqlParameter("@username", User));
                            cmd.Parameters.Add(new SqlParameter("@budget", userBudget));

                            try
                            {
                                var rdr = cmd.ExecuteNonQuery();
                            }
                            catch (SqlException ex)
                            {
                                MessageBox.Show("Budget cannot be updated");
                            }
                        }
                    }
                    else
                    {
                        MessageBox.Show("Insufficient budget for this product!");
                    }
                }

            }
            else if (listView2.SelectedItems.Count == 0)
            {
                MessageBox.Show("You must select a song!");
            }
            else if (listView2.SelectedItems.Count > 1)
            {
                MessageBox.Show("You must select just one song!");
            }
            // add song in cart - update in data base
        }

        /// <summary> 
        /// Adds song in client's wishlist
        /// </summary>
        private void button2_Click(object sender, EventArgs e)
        {
            // add song in wishlist
            if (listView2.SelectedItems.Count == 1)
            {
                var item = listView2.SelectedItems[0];

                var name = item.SubItems[0].Text;
                var artist = item.SubItems[1].Text;
                var album = item.SubItems[2].Text;
                var genre = item.SubItems[3].Text;
                var year = item.SubItems[4].Text;
                var price = Int32.Parse(item.SubItems[5].Text);
                var id = long.Parse(item.SubItems[6].Text);

                using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
                {

                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("addWishlist", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@username", User));
                        cmd.Parameters.Add(new SqlParameter("@id_product", id));

                        try
                        {
                            var rdr = cmd.ExecuteNonQuery();
                        }
                        catch (SqlException ex)
                        {
                            MessageBox.Show("Song cannot be added in wishlist");
                        }
                    }
                }

            }
            else if (listView2.SelectedItems.Count == 0)
            {
                MessageBox.Show("You must select a song!");
            }
            else if (listView2.SelectedItems.Count > 1)
            {
                MessageBox.Show("You must select just one song!");
            }
        }

        /// <summary> 
        /// Adds album in cart and updates client's budget
        /// </summary>
        private void button3_Click(object sender, EventArgs e)
        {
            // add album in cart
            if (listView1.SelectedItems.Count == 1)
            {
                var item = listView1.SelectedItems[0];

                var artist = item.SubItems[0].Text;
                var album = item.SubItems[1].Text;
                var year = item.SubItems[2].Text;
                var genre = item.SubItems[3].Text;
                var price = Int32.Parse(item.SubItems[4].Text);
                var id = long.Parse(item.SubItems[5].Text);

                using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
                {

                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("addCart", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@username", User));
                        cmd.Parameters.Add(new SqlParameter("@id_product", id));

                        try
                        {
                            var rdr = cmd.ExecuteNonQuery();
                        }
                        catch (SqlException ex)
                        {
                            MessageBox.Show("Album cannot be added in wishlist");
                        }
                    }

                    int userBudget = -1;

                    using (SqlCommand cmd = new SqlCommand("findUserBudget", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@user", User));

                        SqlDataReader rdr = null;
                        rdr = cmd.ExecuteReader();

                        while (rdr.Read())
                        {
                            userBudget = int.Parse(rdr[0].ToString());
                        }

                        rdr.Close();

                    }

                    userBudget -= price;

                    if (userBudget >= 0)
                    {
                        using (SqlCommand cmd = new SqlCommand("updateBudget", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add(new SqlParameter("@username", User));
                            cmd.Parameters.Add(new SqlParameter("@budget", userBudget));

                            try
                            {
                                var rdr = cmd.ExecuteNonQuery();
                            }
                            catch (SqlException)
                            {
                                MessageBox.Show("Budget cannot be updated");
                            }
                        }
                    }
                    else
                    {
                        MessageBox.Show("Insufficient budget for this product!");
                    }
                }
            }
            else if (listView1.SelectedItems.Count == 0)
            {
                MessageBox.Show("You must select an album!");
            }
            else if (listView1.SelectedItems.Count > 1)
            {
                MessageBox.Show("You must select just one album!");
            }
        }

        /// <summary> 
        /// Adds album in client's wishlist
        /// </summary>
        private void button4_Click(object sender, EventArgs e)
        {
            // add album in wishlist
            if (listView1.SelectedItems.Count == 1)
            {
                var item = listView1.SelectedItems[0];

                var artist = item.SubItems[0].Text;
                var album = item.SubItems[1].Text;
                var year = item.SubItems[2].Text;
                var genre = item.SubItems[3].Text;
                var price = int.Parse(item.SubItems[4].Text);
                var id = long.Parse(item.SubItems[5].Text);

                using (var conn =
                new SqlConnection("Data Source=(local);Initial Catalog=BD2;Integrated Security=SSPI"))
                {

                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("addWishlist", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@username", User));
                        cmd.Parameters.Add(new SqlParameter("@id_product", id));

                        try
                        {
                            var rdr = cmd.ExecuteNonQuery();
                        }
                        catch (SqlException ex)
                        {
                            MessageBox.Show("Album cannot be added in wishlist");
                        }
                    }
                }
            }
            else if (listView1.SelectedItems.Count == 0)
            {
                MessageBox.Show("You must select an album!");
            }
            else if (listView1.SelectedItems.Count > 1)
            {
                MessageBox.Show("You must select just one album!");
            }
        }
    }
}
