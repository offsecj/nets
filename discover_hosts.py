import os
import subprocess
import re

# This file will use tcpdump to listen on eth0 interface by default and extact IP addresses from the capture
# IP addresses are extracted to a text file; duplicates are checked


# Check if destination the file exists
if not os.path.exists('ip_addresses.txt'):
    # Create the file if it does not exist
    open('ip_addresses.txt', 'w').close()

# Create a set to store the IP addresses that have already been written to the file
ip_set = set()

# Open the file to write IP addresses to
with open('ip_addresses.txt', 'w') as f:
    # Start tcpdump to listen on interface 'eth0' and capture only IP packets
    p = subprocess.Popen(['tcpdump', '-i', 'eth0', '-nn', 'ip'], stdout=subprocess.PIPE)
    # Read output from tcpdump
    for line in iter(p.stdout.readline, b''):
        # Convert bytes to string
        line = line.decode()
        # Extract the IP address from the line (using regex)
        ip_address = re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', line)[0]
        # Check if the IP address has already been written to the file
        if ip_address not in ip_set:
            # Add the IP address to the set
            ip_set.add(ip_address)
            # Write the IP address to the file
            f.write(ip_address + '\n')
