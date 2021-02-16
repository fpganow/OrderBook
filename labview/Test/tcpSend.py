#!/usr/bin/python3

ip = '192.168.1.60'
port = 7

print(f'Sending a TCP Packet to: {ip}:{port}')

import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = (ip, port)

try:
    sock.connect(server_address)
    message = b'This is the message. It will be repeated.  To Genesys or Arty.'
    sock.sendall(message)

    amount_received = 0
    amount_expected = len(message)

    while amount_received < amount_expected:
        data = sock.recv(16)
        amount_received += len(data)
        print(f'Received {data}')
finally:
    sock.close()
