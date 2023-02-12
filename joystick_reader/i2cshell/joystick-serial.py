import argparse
import serial.tools.list_ports
import datetime
import time

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

parser = argparse.ArgumentParser(description='Read Joystick connected to ADS1115: 16bit ADC')
parser.add_argument('--com', metavar='COMX', type=str, required=True,
    help="Name a serial port from the list above")
parser.add_argument('--baud', metavar='BAUD_RATE', type=int, default=115200,
    help="Baud rate (default 115200)")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--X', action='store_true',
    help="Read single value from A0")
group.add_argument('--Y', action='store_true',
    help="Read single value from A1")
group.add_argument('--XY', action='store_true',
    help="Read single value from A0 and A1")
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

# Configuration value MSB
# Input multiplexer configuration [14:12] = [6:4] (ADS1115 only)
MUX_A0_GND = 0b100 # A0 to GND
MUX_A1_GND = 0b101 # A1 to GND
# Programmable gain amplifier configuration  [11:9] = [3:1] - defines full scale range
PGA = 0b000 # 010= += 2.048V (default) 000=+- 6.144V
# Device operating mode
MODE_SINGLE = 0b1 # [0] 0=continous conversion model, 1=Single-shot mode or power-down state (default)

# Configuration value LSB
# Data rate [7:5]
DR = 0b100 # 000 = 8 SPS, 010 = 32 SPS, 100 = 128 SPS, 111=860 SPS
# Comparator mode [4] (ADS1114 and ADS1115 only)
COMP_MODE = 0b0 #  0=traditional comperator, 1=window comperator
# Comparator polarity [3] (ADS1114 and ADS1115 only)
COMP_POL = 0b0  # 0=active low, 1=active high
# Latching comparator [2] (ADS1114 and ADS1115 only)
COMP_LAT = 0b0  # 0=Nonlatching comparator, 1=Latching comparator 
# Comparator queue and disable [1:0] (ADS1114 and ADS1115 only)
COMP_QUEUE = 0b11 #  11=Disable comparator and set ALERT/RDY pin to high-impedance (default)

def writeCONFIG(MSB, LSB):
    bytes_to_write = bytearray([
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,          # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x01,                # Configuration register
        CMD_TX_BYTE,
        MSB,                 # MSB=C4 8=start a single conversion 100=A0 only, 4=FSR += 0.512V,
        CMD_TX_BYTE,
        LSB,                 # LSB=83 8=continuous, 000=8 SPS,3=disable comparator):
        CMD_STOP_CONDITION])
    return bytes_to_write

def readCONFIG():
    bytes_to_send = setREG(0x01)
    bytes_to_send += readVALUE()
    return bytes_to_send

def setREG(REG):
    bytes_to_write = bytearray([
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,          # Chip address and WRITE command bit
        CMD_TX_BYTE,
        REG,                 # Control register / Conversion register
        CMD_STOP_CONDITION,
    ])
    return bytes_to_write

def readVALUE():
    bytes_to_write = bytearray([
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_READ,           # Chip address and READ command bit to
        CMD_RX_BYTE_ACK,     # MSB
        CMD_RX_BYTE_NACK,    # LSB
        CMD_STOP_CONDITION
    ])
    return bytes_to_write

def readCHANNEL(CONFIG_MSB, CONFIG_LSB):
    # bytes_to_send = bytearray([CMD_BUS_RST])
    # configure device to read from channel
    bytes_to_send = writeCONFIG(CONFIG_MSB, CONFIG_LSB)

    print("Sending commands over UART")
    print(f"MSB=0x{CONFIG_MSB:02x}, LSB=0x{CONFIG_LSB:02x}")
    ser.write(bytes_to_send)

    # Set mode (set single mode)
    bytes_to_send = writeCONFIG(CONFIG_MSB|0x01, CONFIG_LSB)
    print(f"MSB=0x{CONFIG_MSB|0x01:02x}, LSB=0x{CONFIG_LSB:02x}")
    ser.write(bytes_to_send)

    # Request ADC (start single mode)
    bytes_to_send = writeCONFIG(CONFIG_MSB|0x81, CONFIG_LSB)
    print(f"MSB=0x{CONFIG_MSB|0x81:02x}, LSB=0x{CONFIG_LSB:02x}")
    ser.write(bytes_to_send)

    while True:
        # read configuration ready status
        bytes_to_send = readCONFIG()
        ser.write(bytes_to_send)

        bytes_to_read = 2   # read 32 bit register
        # print(f"Reading {bytes_to_read} bytes from the UART")
        read_bytes = ser.read(bytes_to_read)
        if read_bytes == b'':
            print(f"Read timed out after {timeout_seconds} seconds")
            exit(1)

        ready = (read_bytes[1] & 0x80) == 0x80 
        if ready:
            print(f"Conversion ready 0x{read_bytes[0]:02x}{read_bytes[1]:02x}")
            break

    if not ready:
        print(f"Conversion not ready 0x{read_bytes[0]:02x}")
        exit(1)

    # read a value from the conversion register
    bytes_to_send = setREG(0x00)   # conversion register 
    bytes_to_send += readVALUE()      # tows compliment 
    ser.write(bytes_to_send)

    bytes_to_read = 2
    print(f"Reading {bytes_to_read} bytes from the UART")
    read_bytes = ser.read(bytes_to_read)
    if read_bytes == b'':
        print(f"Read timed out after {timeout_seconds} seconds")
        exit(1)

    return read_bytes;

X_CONFIG_MSB = 0x00 | (MUX_A0_GND << 4) | (PGA << 1)| 0b0 # single not turned on
X_CONFIG_LSB = (DR << 5) | COMP_QUEUE

if args.X:
    read_bytes = readCHANNEL(X_CONFIG_MSB, X_CONFIG_LSB)

    DAC = compliment15(read_bytes[0], read_bytes[1])
    print(f"\n* Read values X:")
    print(f"DAC: {DAC} in Range (26830 to 0)")

Y_CONFIG_MSB = 0x00 | (MUX_A1_GND << 4) | (PGA << 1)| 0b0 # single not turned on
Y_CONFIG_LSB = (DR << 5) | COMP_QUEUE

if args.Y:
    read_bytes = readCHANNEL(Y_CONFIG_MSB, Y_CONFIG_LSB)

    DAC = compliment15(read_bytes[0], read_bytes[1])
    print(f"\n* Read values Y:")
    print(f"DAC: {DAC} in Range (26830 to 0)")

if args.XY:
    read_bytes = readCHANNEL(X_CONFIG_MSB, X_CONFIG_LSB)

    DAC_X = compliment15(read_bytes[0], read_bytes[1])

    read_bytes = readCHANNEL(Y_CONFIG_MSB, Y_CONFIG_LSB)

    DAC_Y = compliment15(read_bytes[0], read_bytes[1])

    # get Y value
    print(f"\nRead values XY:")
    print(f"X: {DAC_X} in Range (26830 to 0)")
    print(f"Y: {DAC_Y} in Range (26830 to 0)")
