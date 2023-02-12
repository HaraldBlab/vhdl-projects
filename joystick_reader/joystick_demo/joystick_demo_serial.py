import argparse, sys, os
import serial.tools.list_ports

def compliment15(p_MSB, p_LSB):
    l_DAC = (p_MSB << 8) + p_LSB
    if (l_DAC < 0):
        l_DAC = (1<<15) + l_DAC
    else:
        if (l_DAC & (1<<15)) != 0:
            l_DAC = l_DAC - (1<<15)
        if ((p_MSB & 0x80) == 0x80):
            l_DAC = l_DAC - 32768
    return l_DAC

available_ports = serial.tools.list_ports.comports()
print("\nAvailable serial ports:")
print(' '.join([x.name for x in available_ports])+ '\n')

parser = argparse.ArgumentParser(description='Read byte values from UART')
parser.add_argument('com', metavar='COMX', type=str,
    help="Name the serial port from the list above")
parser.add_argument('--baud', metavar='BAUD_RATE', type=int, default=115200,
    help="Baud rate (default 115200)")
args = parser.parse_args()

# Open the serial port
timeout_seconds = 1
ser = serial.Serial(args.com, args.baud, timeout=timeout_seconds)

print(f"Opening {args.com} with baud rate {args.baud}. Press Ctrl+C to break.\n")

try:
    while True:
        bytes_to_read = 5   # I get an extra byte from the read check
        read_bytes = ser.read(bytes_to_read)
        if read_bytes == b'':
            print(f"Read timed out after {timeout_seconds} seconds")
            exit(1)
        
        x_val = compliment15(read_bytes[0], read_bytes[1])
        # TODO: Remove from UART: I get an extra byte from the read check
        check_byte = read_bytes[2] 
        y_val = compliment15(read_bytes[3], read_bytes[4])

        # Print decimal number and a horizontal bar of #### chars
        max_cols = os.get_terminal_size().columns - 6
        bar_width_cols = x_val * (max_cols / (32767))
        print(f'{x_val:-5d} ' + 'X' * round(bar_width_cols))
        # Print decimal number and a horizontal bar of #### chars
        max_cols = os.get_terminal_size().columns - 6
        bar_width_cols = y_val * (max_cols / (32767))
        print(f'{y_val:-5d} ' + 'Y' * round(bar_width_cols))

except KeyboardInterrupt:
    sys.exit()

