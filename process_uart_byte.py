#!/usr/bin/env python3
"""
//UART Data Processor for FPGA Data Acquisition System
Parses hexadecimal bytes from Verilog testbench ($display)
 Validates against expected patterns
Generates timestamped reports
"""

import sys
import re
from datetime import datetime

# Configuration
EXPECTED_HEADER = 0xAA  # Start-of-frame marker
LOG_FILE = "uart_log.csv"

def parse_uart_data(hex_byte):
    """Decode 8-bit UART messages with error checking"""
    try:
        byte_val = int(hex_byte, 16) & 0xFF
        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        
        # Frame validation
        if byte_val == EXPECTED_HEADER:
            return f"{timestamp},START,0x{byte_val:02X}\n"
        elif 0x20 <= byte_val <= 0x7E:  # ASCII printable
            return f"{timestamp},DATA,0x{byte_val:02X},'{chr(byte_val)}'\n"
        else:
            return f"{timestamp},DATA,0x{byte_val:02X}\n"
    
    except ValueError:
        return f"{timestamp},ERROR,Invalid hex: {hex_byte}\n"

def main():
    # Initialize log file
    with open(LOG_FILE, "a") as f:
        f.write("Timestamp,Type,Value,Note\n")
    
    # Process command-line input or stdin
    if len(sys.argv) > 1:
        data = sys.argv[1]
        result = parse_uart_data(data)
        with open(LOG_FILE, "a") as f:
            f.write(result)
        print(result.strip())  # Echo to console
    else:
        # Continuous mode for testbench piping
        for line in sys.stdin:
            if matches := re.findall(r"[0-9A-F]{2}", line.upper()):
                for byte in matches:
                    result = parse_uart_data(byte)
                    with open(LOG_FILE, "a") as f:
                        f.write(result)
                    print(result.strip())

if __name__ == "__main__":
    main()
