<%@ page import="java.sql.*, java.util.*, servlets.koneksi" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Daftar Tempat Wisata Purwokerto</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <h1>Daftar Tempat Wisata Purwokerto</h1>
    <form method="get" class="search">
        <input type="text" name="keyword" placeholder="Cari tempat wisata..." 
               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>" />
        <input type="text" name="fasilitas" placeholder="Cari fasilitas..." 
               value="<%= request.getParameter("fasilitas") != null ? request.getParameter("fasilitas") : "" %>" />
        <select name="kategori">
            <option value="">Semua Kategori</option>
            <%
                Connection conn = null;
                try {
                    conn = koneksi.getConnection();
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
                    rsKategori.close(); stmtKategori.close();
            %>
        </select>
        <select name="urut">
            <option value="">Urutkan</option>
            <option value="biaya">Biaya</option>
            <option value="jarak_km">Jarak</option>
            <option value="jumlah_fasilitas">Jumlah Fasilitas</option>
        </select>
        <button type="submit" class="btn">Cari</button>
    </form>

    <table>
        <tr>
            <th>Nama</th>
            <th>Deskripsi</th>
            <th>Biaya</th>
            <th>Jarak (km)</th>
            <th>Kategori</th>
            <th>Fasilitas</th>
        </tr>
        <%
            String keyword = request.getParameter("keyword");
            String kategori = request.getParameter("kategori");
            String urut = request.getParameter("urut");
            String fasilitas = request.getParameter("fasilitas");

            StringBuilder sql = new StringBuilder(
                "SELECT tw.*, k.nama_kategori, " +
                "COUNT(f.id) AS jumlah_fasilitas, " +
                "GROUP_CONCAT(f.nama SEPARATOR ', ') AS fasilitas_list " +
                "FROM tempat_wisata tw " +
                "JOIN kategori k ON tw.kategori_id = k.id " +
                "LEFT JOIN fasilitas f ON f.tempat_wisata_id = tw.id " +
                "WHERE 1=1"
            );

            if (keyword != null && !keyword.isEmpty()) {
                sql.append(" AND (tw.nama LIKE '%").append(keyword).append("%' OR tw.deskripsi LIKE '%").append(keyword).append("%')");
            }

            if (kategori != null && !kategori.isEmpty()) {
                sql.append(" AND tw.kategori_id = ").append(kategori);
            }

            if (fasilitas != null && !fasilitas.isEmpty()) {
                sql.append(" AND tw.id IN (SELECT tempat_wisata_id FROM fasilitas WHERE nama LIKE '%").append(fasilitas).append("%')");
            }

            sql.append(" GROUP BY tw.id");

            if (urut != null && !urut.isEmpty()) {
                if (urut.equals("jumlah_fasilitas")) {
                    sql.append(" ORDER BY jumlah_fasilitas DESC");
                } else {
                    sql.append(" ORDER BY tw.").append(urut);
                }
            }

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql.toString());

            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("nama") %></td>
            <td><%= rs.getString("deskripsi") %></td>
            <td>Rp <%= rs.getDouble("biaya") %></td>
            <td><%= rs.getDouble("jarak_km") %> km</td>
            <td><%= rs.getString("nama_kategori") %></td>
            <td>
                <%
                    String fasilitasList = rs.getString("fasilitas_list");
                    if (fasilitasList != null && !fasilitasList.isEmpty()) {
                        String[] list = fasilitasList.split(",\\s*");
                %>
                <ul style="margin:0; padding-left: 15px;">
                    <% for (String item : list) { %>
                    <li><%= item %></li>
                    <% } %>
                </ul>
                <%
                    } else {
                        out.print("-");
                    }
                %>
            </td>
        </tr>
        <%
            }
            rs.close(); stmt.close(); if (conn != null) conn.close();
        } catch (Exception e) {
            out.println("<tr><td colspan='6'>Terjadi kesalahan: " + e.getMessage() + "</td></tr>");
            e.printStackTrace();
        }
        %>
    </table>
</div>
</body>
</html>
