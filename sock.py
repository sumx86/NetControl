import socket

socket_initialized = False
sock = None
SERVER_PORT = 3000
IP_ADDR = "127.0.0.1"

def init_sock(port, addr):
    global sock
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(((addr, port)))
    socket_initialized = True

def send_tcp_data(data):
    global sock
    global socket_initialized
    if not socket_initialized:
        init_sock(SERVER_PORT, IP_ADDR)
    sock.send(data.encode())