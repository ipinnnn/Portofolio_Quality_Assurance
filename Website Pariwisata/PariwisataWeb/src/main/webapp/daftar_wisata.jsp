<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="servlets.koneksi" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Kelola Daftar Pariwisata</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
<div class="container">
    <h1>Kelola Daftar Pariwisata</h1>

    <!-- Tombol Arahkan ke halaman tambah -->
    <div style="margin-bottom: 20px;">
        <a href="tambah_wisata.jsp" class="btn btn-edit">+ Tambah Tempat Wisata</a>
    </div>

    <%
        Connection conn = null;
        try {
            conn = koneksi.getConnection();
    %>

    <!-- Form Filter & Pencarian -->
    <form method="get" class="search">
        <input type="text" name="keyword" placeholder="Cari tempat wisata..."
               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>" />

        <select name="kategori">
            <option value="">Semua Kategori</option>
            <%
                Statement stmtKategori = conn.createStatement();
                ResultSet rsKategori = stmtKategori.executeQuery("SELECT * FROM kategori");
                String selectedKategori = request.getParameter("kategori");
                while (rsKategori.next()) {
                    String idKat = rsKategori.getString("id");
                    String namaKat = rsKategori.getString("nama_kategori");
            %>
                <option value="<%= idKat %>" <%= idKat.equals(selectedKategori) ? "selected" : "" %>><%= namaKat %></option>
            <%
                }
                rsKategori.close();
                stmtKategori.close();
            %>
        </select>

        <select name="urut">
            <option value="">Urutkan</option>
            <option value="biaya">Biaya</option>
            <option value="jarak_km">Jarak</option>
            <option value="fasilitas">Jumlah Fasilitas</option>
        </select>

        <button type="submit" class="btn">Cari</button>
    </form>

    <!-- Tabel Daftar Tempat Wisata -->
    <table>
        <tr>
            <th>Nama</th>
            <th>Deskripsi</th>
            <th>Biaya</th>
            <th>Jarak (km)</th>
            <th>Kategori</th>
            <th>Fasilitas</th>
            <th>Aksi</th>
        </tr>
        <%
            String keyword = request.getParameter("keyword");
            String kategori = request.getParameter("kategori");
            String urut = request.getParameter("urut");

            StringBuilder sql = new StringBuilder(
                "SELECT tw.*, k.nama_kategori, " +
                "(SELECT COUNT(*) FROM fasilitas f WHERE f.tempat_wisata_id = tw.id) AS jumlah_fasilitas " +
                "FROM tempat_wisata tw " +
                "JOIN kategori k ON tw.kategori_id = k.id " +
                "WHERE 1=1 "
            );

            if (keyword != null && !keyword.isEmpty()) {
                sql.append(" AND (tw.nama LIKE '%").append(keyword).append("%' OR tw.deskripsi LIKE '%").append(keyword).append("%')");
            }

            if (kategori != null && !kategori.isEmpty()) {
                sql.append(" AND tw.kategori_id = ").append(kategori);
            }

            if (urut != null && !urut.isEmpty()) {
                if (urut.equals("fasilitas")) {
                    sql.append(" ORDER BY jumlah_fasilitas DESC");
                } else {
                    sql.append(" ORDER BY tw.").append(urut);
                }
            }

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql.toString());

            while (rs.next()) {
                int tempatId = rs.getInt("id");
        %>
        <tr>
            <td><%= rs.getString("nama") %></td>
            <td><%= rs.getString("deskripsi") %></td>
            <td>Rp <%= rs.getDouble("biaya") %></td>
            <td><%= rs.getDouble("jarak_km") %> km</td>
            <td><%= rs.getString("nama_kategori") %></td>
            <td>
                <ul>
                    <%
                        Statement stmtF = conn.createStatement();
                        ResultSet rsF = stmtF.executeQuery("SELECT nama FROM fasilitas WHERE tempat_wisata_id = " + tempatId);
                        while (rsF.next()) {
                    %>
                    <li><%= rsF.getString("nama") %></li>
                    <%
                        }
                        rsF.close();
                        stmtF.close();
                    %>
                </ul>
            </td>
            <td>
                <div class="action-buttons">
                    <a class="btn btn-edit" href="edit-wisata?id=<%= tempatId %>">Edit</a>
                    <a class="btn btn-delete" href="hapusWisata?id=<%= tempatId %>"
                       onclick="return confirm('Yakin ingin menghapus data ini?');">Hapus</a>
                </div>
            </td>
        </tr>
        <%
            }
            rs.close(); stmt.close(); conn.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Terjadi kesalahan: " + e.getMessage() + "</p>");
            e.printStackTrace(new java.io.PrintWriter(out));
        }
    %>
    </table>
</div>
</body>
</html>
