import socket
import sys
import ipaddress
import threading

def banner():
    print("""
     _______ _______ _______ _______ _______ _______ _______ _______
    |__   __|  |       \     /  |       \     /  |       \     /
    |   ) (__|   _|_ _||   \_| |   _|_ _||   \_| |   _|_ _||   \_|
    |  | | | |  | |   |  | |  | |  | |   |  | |  | |   |  | |  | |
    |  |_| | |  | |___|  |_| |  | |___|  |_| |  | |___|  |_| |
    |_______| |_______|_______| |_______|_______| |_______|_______|
    |_______| |_______|_______| |_______|_______| |_______|_______|
    """)

def scan_network(network_address, start_port, end_port):
    network = ipaddress.ip_network(network_address)
    for address in network:
        host = address
        print(f"Scanning {host}...")
        for port in range(start_port, end_port + 1):
            threading.Thread(target=scan_port, args=(host, port)).start()

def scan_port(host, port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.5)
        s.connect((str(host), port))
        banner = s.recv(1024).decode()
        if banner:
            print(f"[+] {port} is open on {host}: {banner}")

        s.close()

    except KeyboardInterrupt:
        print("\n[-] Ctrl + C was pressed. Exiting...")
        sys.exit()

    except socket.gaierror:
        print(f"[!] Hostname {host} could not be resolved.")
        sys.exit()

    except socket.error:
        pass

def main():
    banner()
    if len(sys.argv) == 4:
        network_address = sys.argv[1]
        start_port = int(sys.argv[2])
        end_port = int(sys.argv[3])

        scan_network(network_address, start_port, end_port)

    else:
        print("""
        Usage: python port_scanner.py <network_address> <start_port> <end_port>
        Example: python port_scanner.py 192.168.0.0/24 1 100
        """)
        sys.exit()


if __name__ == "__main__":
    main()