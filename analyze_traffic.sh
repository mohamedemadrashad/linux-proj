#!/bin/bash

# Bash Script to Analyze Network Traffic

# Input: Path to the Wireshark pcap file
pcap_file="$1"

# Function to extract information from the pcap file
analyze_traffic() {
    # Check if the pcap file exists
    if [ ! -f "$pcap_file" ]; then
        echo "File not found: $pcap_file"
        exit 1
    fi

    # Use tshark or similar commands for packet analysis
    # Attempting two methods to get the total packet count
    total_packets=$(tshark -r "$pcap_file" -q -z io,stat,0 | grep "Packets:" | awk '{print $2}')
    if [ -z "$total_packets" ]; then
        total_packets=$(tshark -r "$pcap_file" -T fields -e frame.number | wc -l)
    fi

    http_packets=$(tshark -r "$pcap_file" -T fields -e frame.protocols | grep -c "http")
    https_packets=$(tshark -r "$pcap_file" -T fields -e frame.protocols | grep -c "tls")
    
    top_source_ips=$(tshark -r "$pcap_file" -T fields -e ip.src | sort | uniq -c | sort -nr | head -n 5)
    top_dest_ips=$(tshark -r "$pcap_file" -T fields -e ip.dst | sort | uniq -c | sort -nr | head -n 5)

    # Output analysis summary
    echo "----- Network Traffic Analysis Report -----"
    echo "1. Total Packets: $total_packets"
    echo "2. Protocols:"
    echo "   - HTTP: $http_packets packets"
    echo "   - HTTPS/TLS: $https_packets packets"
    echo ""
    echo "3. Top 5 Source IP Addresses:"
    echo "$top_source_ips"
    echo ""
    echo "4. Top 5 Destination IP Addresses:"
    echo "$top_dest_ips"
    echo ""
    echo "----- End of Report -----"
}

# Run the analysis function
analyze_traffic