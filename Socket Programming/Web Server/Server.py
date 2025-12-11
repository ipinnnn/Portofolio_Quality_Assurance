import socket
import os

HOST = ''       # Kosong artinya menerima dari semua IP
PORT = 6789     # Port custom, bisa diganti sesuai kebutuhan
WEBROOT = '.'   # Direktori saat ini, tempat file HTML disimpan

def handle_request(client_socket):
    request = client_socket.recv(1024).decode()
    print("== REQUEST DITERIMA ==")
    print(request)
    
    lines = request.splitlines()
    if len(lines) == 0:
        client_socket.close()
        return

    method, path, _ = lines[0].split()
    if method != 'GET':
        client_socket.close()
        return

    filename = path.strip('/')
    filepath = os.path.join(WEBROOT, filename)

    if os.path.isfile(filepath):
        with open(filepath, 'rb') as f:
            content = f.read()
        response = b"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" + content
    else:
        response = b"HTTP/1.1 404 Not Found\r\n\r\n<h1>404 Not Found</h1>"

    client_socket.sendall(response)
    client_socket.close()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
    server_socket.bind((HOST, PORT))
    server_socket.listen()
    print(f"Server berjalan di port {PORT}. Menunggu koneksi...")

    while True:
        client_conn, client_addr = server_socket.accept()
        handle_request(client_conn)
