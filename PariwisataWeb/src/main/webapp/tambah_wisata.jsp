<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="servlets.koneksi" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if ("post".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        try {
            conn = koneksi.getConnection();

            String nama = request.getParameter("nama");
            String deskripsi = request.getParameter("deskripsi");
            double biaya = Double.parseDouble(request.getParameter("biaya"));
            double jarak = Double.parseDouble(request.getParameter("jarak_km"));
            int kategoriId = Integer.parseInt(request.getParameter("kategori_id"));
            String[] fasilitas = request.getParameter("fasilitas").split(",");

            PreparedStatement pst = conn.prepareStatement(
                "INSERT INTO tempat_wisata (nama, deskripsi, biaya, jarak_km, kategori_id) VALUES (?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            pst.setString(1, nama);
            pst.setString(2, deskripsi);
            pst.setDouble(3, biaya);
            pst.setDouble(4, jarak);
            pst.setInt(5, kategoriId);
            pst.executeUpdate();

            ResultSet generatedKeys = pst.getGeneratedKeys();
            int tempatId = 0;
            if (generatedKeys.next()) {
                tempatId = generatedKeys.getInt(1);
            }
            pst.close();

            for (String f : fasilitas) {
                PreparedStatement pstF = conn.prepareStatement("INSERT INTO fasilitas (nama, tempat_wisata_id) VALUES (?, ?)");
                pstF.setString(1, f.trim());
                pstF.setInt(2, tempatId);
                pstF.executeUpdate();
                pstF.close();
            }

            conn.close();

            // 🔁 Redirect ke daftar wisata setelah berhasil
            response.sendRedirect("daftar_wisata.jsp");
            return;

        } catch (Exception e) {
            out.println("<p style='color:red;'>Terjadi kesalahan: " + e.getMessage() + "</p>");
            e.printStackTrace(new java.io.PrintWriter(out));
        }
    }
%>
<html>
<head>
    <title>Tambah Tempat Wisata</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
<div class="form-container">
    <h2>Tambah Tempat Wisata</h2>
    <form method="post" action="tambah_wisata.jsp">
        <label>Nama Tempat Wisata</label>
        <input type="text" name="nama" required />

        <label>Deskripsi</label>
        <textarea name="deskripsi" required></textarea>

        <label>Biaya</label>
        <input type="number" name="biaya" required />

        <label>Jarak (km)</label>
        <input type="number" step="any" name="jarak_km" required />

        <label>Kategori</label>
        <select name="kategori_id" required>
            <option value="">Pilih Kategori</option>
            <%
                Connection conn = koneksi.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM kategori");
                while (rs.next()) {
            %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("nama_kategori") %></option>
            <%
                }
                rs.close(); stmt.close(); conn.close();
            %>
        </select>

        <label>Fasilitas (pisahkan dengan koma)</label>
        <input type="text" name="fasilitas" placeholder="Contoh: Toilet, Parkir, Warung Makan" required />

        <button class="btn" type="submit">Simpan</button>
    </form>
</div>
</body>
</html>
