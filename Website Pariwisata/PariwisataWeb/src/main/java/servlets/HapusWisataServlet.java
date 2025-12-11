package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import servlets.koneksi;

@WebServlet("/hapusWisata")
public class HapusWisataServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        try {
            int id = Integer.parseInt(idParam);
            Connection conn = koneksi.getConnection();

            // Hapus fasilitas dulu (jika ada foreign key)
            String deleteFasilitas = "DELETE FROM fasilitas WHERE tempat_wisata_id = ?";
            PreparedStatement stmtFasilitas = conn.prepareStatement(deleteFasilitas);
            stmtFasilitas.setInt(1, id);
            stmtFasilitas.executeUpdate();
            stmtFasilitas.close();

            // Hapus data wisata
            String sql = "DELETE FROM tempat_wisata WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            stmt.executeUpdate();

            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect kembali ke halaman daftar
        response.sendRedirect("daftar_wisata.jsp");
    }
}
