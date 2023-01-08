import argparse
import serial.tools.list_ports
import datetime

available_ports = serial.tools.list_ports.comports()
print("\nAvailable serial ports:")
print(' '.join([x.name for x in available_ports])+ '\n')

parser = argparse.ArgumentParser(description='Read, register in the ADS1115: 16bit ADC')
parser.add_argument('--com', metavar='COMX', type=str, required=True,
    help="Name a serial port from the list above")
parser.add_argument('--baud', metavar='BAUD_RATE', type=int, default=115200,
    help="Baud rate (default 115200)")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--A0', action='store_true',
    help="Read single value from A0")
group.add_argument('--scan', action='store_true',
    help="Scan the I2C bus for devices")

args = parser.parse_args()

# Open the serial port
timeout_seconds = 3
ser = serial.Serial(args.com, args.baud, timeout=timeout_seconds)

print(f"Opening {args.com} with baud rate {args.baud}\n")

# Interface commands (from i2c_controller.vhd)
CMD_BUS_RST          = 0x00
CMD_START_CONDITION  = 0x01
CMD_TX_BYTE          = 0x02
CMD_RX_BYTE_ACK      = 0x03
CMD_RX_BYTE_NACK     = 0x04
CMD_STOP_CONDITION   = 0x05

# first available address
ADDR_WRITE = 0x90
ADDR_READ = 0x91

addr_scan = 0x68

if args.scan:
    for addr_scan in range(0,128):
        bytes_to_send = bytearray([
            CMD_BUS_RST,
            CMD_START_CONDITION,
            CMD_TX_BYTE,
            2*addr_scan + 0,                # Chip address and WRITE command bit
            CMD_TX_BYTE,
            0x00,                              # Register address to start reading at
            CMD_STOP_CONDITION,
            CMD_START_CONDITION,
            CMD_TX_BYTE,
            2*addr_scan + 1,                # Chip address and READ command bit to
            CMD_RX_BYTE_NACK,                   # any value at register 0
            CMD_STOP_CONDITION,
        ])

        # print(f"Sending commands to {addr_scan} over UART")
        ser.write(bytes_to_send)

        bytes_to_read = 1
        read_bytes = ser.read(bytes_to_read)
        if read_bytes != b'' and read_bytes[0] != 255:
            print("Found device at 0x" + format(addr_scan, "02x") + " over UART")

# Programmable gain amplifier configuration - defines full scale range
PGA = 0b000 # 010= += 2.048V (default) 000=+- 6.144V
# Input multiplexer configuration (ADS1115 only)
MUX = 0b100 # A0 to GND

# MSB=C4 8=start a single conversion 100=A0 only, 4=FSR += 0.512V,
CONFIG_MSB = 0x80 | (MUX << 5) | PGA 

# Device operating mode
MODE = 0b1 # 0=continous conversion model, 1=Single-shot mode or power-down state (default)
# Data rate
DR = 0b111 # 000 = 8 SPS, 010 = 32 SPS, 111=860 SPS
# Comparator queue and disable (ADS1114 and ADS1115 only)
COMP_QUEUE = 0b11 #  11=Disable comparator and set ALERT/RDY pin to high-impedance (default)

# LSB=83 8=continuous, 000=8 SPS,3=disable comparator):
CONFIG_LSB = (MODE << 7) | (DR << 4) | COMP_QUEUE

if args.A0:
    bytes_to_send = bytearray([
        CMD_BUS_RST,
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,          # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x01,                # Configuration register
        CMD_TX_BYTE,
        CONFIG_MSB,          # MSB=C4 8=start a single conversion 100=A0 only, 4=FSR += 0.512V,
        CMD_TX_BYTE,
        CONFIG_LSB,          # LSB=83 8=continuous, 000=8 SPS,3=disable comparator):
        CMD_STOP_CONDITION,
        # Write to address pointer (0=conversion register):
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,          # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x00,                # Conversion register
        CMD_STOP_CONDITION,
        # read value (2 compliment)
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_READ,           # Chip address and READ command bit to
        CMD_RX_BYTE_ACK,     # MSB
        CMD_RX_BYTE_NACK,    # LSB
        CMD_STOP_CONDITION,
    ])


    print("Sending commands over UART")
    ser.write(bytes_to_send)

    bytes_to_read = 2
    print(f"Reading {bytes_to_read} bytes from the UART")
    read_bytes = ser.read(bytes_to_read)
    if read_bytes == b'':
        print(f"Read timed out after {timeout_seconds} seconds")
        exit(1)

    MSB = read_bytes[0]
    LSB = read_bytes[1]

#    DAC = ((MSB & 0x7F) << 8) + LSB
    DAC = (MSB << 8) + LSB
    print(f"DAC: {DAC} raw value {PGA}")
    if (DAC < 0):
        DAC = (1<<15) + DAC
    else:
        if (DAC & (1<<15)) != 0:
            DAC = DAC - (1<<15)
    #DAC = (0x7FFF - DAC) + 1 # binary compliment
    #DAC = ~DAC + 1 # binary compliment
    if ((MSB & 0x80) == 0x80):
        DAC = DAC - 32768

    print(f"\n* Read values:\n")
    print("MSB: 0x" + format(MSB, "02x"))
    print("LSB: 0x" + format(LSB, "02x"))
    print(f"DAC: {DAC} in Range (20362 to -5761) with PGA {PGA}")
