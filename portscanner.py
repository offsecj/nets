import threading
import socket
import sys
import ipaddress

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

if len(sys.argv) < 2:
    print("Usage: python port_scanner.py <network>")
    sys.exit()

network = sys.argv[1]

# Get the network address and mask from the input
network_address = ipaddress.IPv4Network(network, strict=False)

# Set the number of threads to use
num_threads = 10

# Divide the port range into chunks for each thread
port_range = list(range(1, 65535))
chunk_size = len(port_range) // num_threads
port_chunks = [port_range[i:i+chunk_size] for i in range(0, len(port_range), chunk_size)]

# Create a list of threads
threads = []

i = 0

# Iterate through all the IP addresses in the network
for ip in network_address:
    # Convert the IP address to a string
    ip_str = str(ip)

    # Create a new thread for the current IP address
    t = threading.Thread(target=scan_ports, args=(ip_str, port_chunks[i]))
    threads.append(t)
    #i += 1

# Start all the threads
for t in threads:
    t.start()
    i += 1

# Wait for all the threads to complete
for t in threads:
    t.join()
