import threading
import socket
import sys
import itertools

# This script will loop through contents of a file containing ip addresses and scan all ports on them


def port_scan(ip, port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.5)
        result = sock.connect_ex((ip, port))
        if result == 0:
            print(f"Port {port} is open on IP {ip}")
        sock.close()
    except Exception as e:
        print(f"Error occurred: {e}")

def scan_ports(ip, port_range):
    for port in port_range:
        port_scan(ip, port)

try:
    with open(sys.argv[1], "r") as f:
        ip_list = f.readlines()
    ip_list = [ip.strip() for ip in ip_list]
except:
    print("Usage: python port_scanner.py <IP list file>")
    sys.exit()

# Set the number of threads to use
num_threads = 10

# Divide the port range into chunks for each thread
port_range = list(range(1, 65535))
chunk_size = len(port_range) // num_threads
port_chunks = [port_range[i:i+chunk_size] for i in range(0, len(port_range), chunk_size)]

# Create a list of threads
threads = []

i = 0

# Iterate through all the IP addresses in the list
for ip, port_chunk in zip(ip_list, itertools.cycle(port_chunks)):
    t = threading.Thread(target=scan_ports, args=(ip, port_chunk))
    threads.append(t)

# Start all the threads
for t in threads:
    t.start()

# Wait for all the threads to complete
for t in threads:
    t.join()
