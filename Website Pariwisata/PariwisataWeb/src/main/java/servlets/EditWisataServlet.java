package servlets;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import servlets.koneksi;

@WebServlet("/edit-wisata")
public class EditWisataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("daftar_wisata.jsp");
            return;
        }

        try (Connection conn = koneksi.getConnection()) {
            int id = Integer.parseInt(idParam);

            // Ambil data tempat_wisata
            PreparedStatement pst = conn.prepareStatement("SELECT * FROM tempat_wisata WHERE id = ?");
            pst.setInt(1, id);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                Map<String, Object> wisata = new HashMap<>();
                wisata.put("id", rs.getInt("id"));
                wisata.put("nama", rs.getString("nama"));
                wisata.put("deskripsi", rs.getString("deskripsi"));
                wisata.put("biaya", rs.getDouble("biaya"));
                wisata.put("jarak_km", rs.getDouble("jarak_km"));
                wisata.put("kategori_id", rs.getInt("kategori_id"));
                request.setAttribute("wisata", wisata);
            } else {
                request.setAttribute("error", "Data tidak ditemukan atau tidak valid.");
                request.getRequestDispatcher("edit_wisata.jsp").forward(request, response);
                return;
            }

            rs.close();
            pst.close();

            // Ambil daftar kategori
            Statement stmtKat = conn.createStatement();
            ResultSet rsKategori = stmtKat.executeQuery("SELECT * FROM kategori");
            request.setAttribute("kategoriList", rsKategori); // ditutup di JSP

            // Ambil daftar fasilitas
            List<String> fasilitasList = new ArrayList<>();
            PreparedStatement pstF = conn.prepareStatement("SELECT nama FROM fasilitas WHERE tempat_wisata_id = ?");
            pstF.setInt(1, id);
            ResultSet rsF = pstF.executeQuery();
            while (rsF.next()) {
                fasilitasList.add(rsF.getString("nama"));
            }
            rsF.close();
            pstF.close();
            request.setAttribute("fasilitasList", fasilitasList);

            request.getRequestDispatcher("edit_wisata.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Gagal memuat data", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = koneksi.getConnection()) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("daftar_wisata.jsp");
                return;
            }

            int id = Integer.parseInt(idStr.trim());
            String nama = request.getParameter("nama").trim();
            String deskripsi = request.getParameter("deskripsi").trim();
            double biaya = Double.parseDouble(request.getParameter("biaya"));
            double jarak = Double.parseDouble(request.getParameter("jarak_km"));
            int kategoriId = Integer.parseInt(request.getParameter("kategori_id"));
            String fasilitasRaw = request.getParameter("fasilitas");

            // Update tempat_wisata
            PreparedStatement pst = conn.prepareStatement(
                    "UPDATE tempat_wisata SET nama=?, deskripsi=?, biaya=?, jarak_km=?, kategori_id=? WHERE id=?");
            pst.setString(1, nama);
            pst.setString(2, deskripsi);
            pst.setDouble(3, biaya);
            pst.setDouble(4, jarak);
            pst.setInt(5, kategoriId);
            pst.setInt(6, id);
            pst.executeUpdate();
            pst.close();

            // Hapus fasilitas lama
            PreparedStatement deleteF = conn.prepareStatement("DELETE FROM fasilitas WHERE tempat_wisata_id = ?");
            deleteF.setInt(1, id);
            deleteF.executeUpdate();
            deleteF.close();

            // Tambahkan fasilitas baru jika ada
            if (fasilitasRaw != null && !fasilitasRaw.trim().isEmpty()) {
                String[] fasilitasArr = fasilitasRaw.split(",");
                PreparedStatement insertF = conn.prepareStatement(
                        "INSERT INTO fasilitas (nama, tempat_wisata_id) VALUES (?, ?)");
                for (String fas : fasilitasArr) {
                    String clean = fas.trim();
                    if (!clean.isEmpty()) {
                        insertF.setString(1, clean);
                        insertF.setInt(2, id);
                        insertF.addBatch();
                    }
                }
                insertF.executeBatch();
                insertF.close();
            }

            response.sendRedirect("daftar_wisata.jsp");

        } catch (Exception e) {
            throw new ServletException("Gagal mengubah data", e);
        }
    }
}
