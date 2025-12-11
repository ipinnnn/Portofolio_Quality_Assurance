package servlets;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class koneksi {
    private static Connection conn;

    public static Connection getConnection() {
        try {
            if (conn == null || conn.isClosed()) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/pariwisata",  // Ganti jika DB bukan 'pariwisata'
                    "root",    // Username
                    ""         // Password MySQL
                );
                System.out.println("Koneksi ke database berhasil.");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Driver MySQL tidak ditemukan.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Gagal koneksi ke database.");
            e.printStackTrace();
        }
        return conn;
    }
}
