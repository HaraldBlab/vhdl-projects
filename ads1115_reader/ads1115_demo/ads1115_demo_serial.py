import argparse, sys, os
import serial.tools.list_ports

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
        bytes_to_read = 2
        read_bytes = ser.read(bytes_to_read)
        if read_bytes == b'':
            print(f"Read timed out after {timeout_seconds} seconds")
            exit(1)
        
        MSB = read_bytes[0]
        LSB = read_bytes[1]

        DAC = (MSB << 8) + LSB
        # print(f"DAC: {DAC} raw value ")
        if (DAC < 0):
            DAC = (1<<15) + DAC
        else:
            if (DAC & (1<<15)) != 0:
                DAC = DAC - (1<<15)
        #DAC = (0x7FFF - DAC) + 1 # binary compliment
        #DAC = ~DAC + 1 # binary compliment
        if ((MSB & 0x80) == 0x80):
            DAC = DAC - 32768

        val = DAC
        
        # Print decimal number and a horizontal bar of #### chars
        max_cols = os.get_terminal_size().columns - 6
        bar_width_cols = val * (max_cols / (32767))
        print(f'{val:-5d} ' + '#' * round(bar_width_cols))

except KeyboardInterrupt:
    sys.exit()

