<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Edit Tempat Wisata</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
<div class="form-container">
<%
    Map wisata = (Map) request.getAttribute("wisata");
    ResultSet rsKat = (ResultSet) request.getAttribute("kategoriList");
    List<String> fasilitasList = (List<String>) request.getAttribute("fasilitasList");

    if (wisata != null && rsKat != null) {
        int selectedKategori = (int) wisata.get("kategori_id");
        String fasilitasGabung = fasilitasList != null ? String.join(", ", fasilitasList) : "";
%>
    <h2>Edit Tempat Wisata</h2>
    <form method="post" action="edit-wisata?id=<%= wisata.get("id") %>">
        <label>Nama</label>
        <input type="text" name="nama" value="<%= wisata.get("nama") %>" required />

        <label>Deskripsi</label>
        <textarea name="deskripsi" required><%= wisata.get("deskripsi") %></textarea>

        <label>Biaya</label>
        <input type="number" step="any" name="biaya" value="<%= wisata.get("biaya") %>" required />

        <label>Jarak (km)</label>
        <input type="number" step="any" name="jarak_km" value="<%= wisata.get("jarak_km") %>" required />

        <label>Kategori</label>
        <select name="kategori_id" required>
            <%
                while (rsKat.next()) {
                    int kid = rsKat.getInt("id");
                    String namaKat = rsKat.getString("nama_kategori");
            %>
                <option value="<%= kid %>" <%= (kid == selectedKategori ? "selected" : "") %>>
                    <%= namaKat %>
                </option>
            <% } rsKat.close(); %>
        </select>

        <label>Fasilitas</label>
        <textarea name="fasilitas" placeholder="Contoh: Toilet, Mushola, Spot Foto"><%= fasilitasGabung %></textarea>
        <small>Pisahkan dengan koma jika lebih dari satu.</small>

        <button class="btn" type="submit">Simpan Perubahan</button>
    </form>
<%
    } else {
%>
    <p style="color:red; text-align:center;">Data tidak ditemukan atau tidak valid.</p>
<%
    }
%>
</div>
</body>
</html>
