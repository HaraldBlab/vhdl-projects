import argparse
import serial.tools.list_ports
import datetime

available_ports = serial.tools.list_ports.comports()
print("\nAvailable serial ports:")
print(' '.join([x.name for x in available_ports])+ '\n')

parser = argparse.ArgumentParser(description='Read, set, or clear register in the Pmod RTCC: Real-time Clock / Calendar module')
parser.add_argument('--com', metavar='COMX', type=str, required=True,
    help="Name a serial port from the list above")
parser.add_argument('--baud', metavar='BAUD_RATE', type=int, default=115200,
    help="Baud rate (default 115200)")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--read', action='store_true',
    help="Read the time and date registers")
group.add_argument('--set', action='store_true',
    help="Set the time and date registers from the computer's clock,"
    " enable the on-board oscillator (ST bit) and the external battery (VBATEN)")
group.add_argument('--clear', action='store_true',
    help="Set the first 7 register bytes to all zero's")
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

ADDR_WRITE = 0xd0
ADDR_READ = 0xd1

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
            print(f"Found device at {addr_scan} over UART ({read_bytes[0]})")

if args.read:
    bytes_to_send = bytearray([
        CMD_BUS_RST,
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,          # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x00,                # Register address to start reading at
        CMD_STOP_CONDITION,
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_READ,           # Chip address and READ command bit to
        CMD_RX_BYTE_ACK,     # 00h: CH bit, seconds
        CMD_RX_BYTE_ACK,     # 01h: Minutes
        CMD_RX_BYTE_ACK,     # 02h: 12/24, hours
        CMD_RX_BYTE_ACK,     # 03h: Day of the week
        CMD_RX_BYTE_ACK,     # 04h: Date
        CMD_RX_BYTE_ACK,     # 05h: Month
        CMD_RX_BYTE_NACK,    # 06h: Year
        CMD_STOP_CONDITION,
    ])


    print("Sending commands over UART")
    ser.write(bytes_to_send)

    bytes_to_read = 7
    print(f"Reading {bytes_to_read} bytes from the UART")
    read_bytes = ser.read(bytes_to_read)
    if read_bytes == b'':
        print(f"Read timed out after {timeout_seconds} seconds")
        exit(1)

    ch_bit = not ((read_bytes[0] & 0x80) >> 7)
    seconds_10s = (read_bytes[0] & 0x70) >> 4
    seconds_1s = (read_bytes[0] & 0x0F)
    seconds = (seconds_10s * 10) + seconds_1s

    minutes_10s = (read_bytes[1] & 0x70) >> 4
    minutes_1s = (read_bytes[1] & 0x0F)
    minutes = (minutes_10s * 10) + minutes_1s

    hours_12_24 = (read_bytes[2] & 0x40) >> 6
    hours_10s = (read_bytes[2] & 0x30) >> 4
    hours_1s = (read_bytes[2] & 0x0F)
    hours = (hours_10s * 10) + hours_1s

    weekday = (read_bytes[3] & 0x07)
    weekday_table = {0: 'Undefined', 1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
        4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday'}

    date_10s = (read_bytes[4] & 0x30) >> 4
    date_1s = (read_bytes[4] & 0x0F)
    date = (date_10s * 10) + date_1s

    month_10s = (read_bytes[5] & 0x10) >> 4
    month_1s = (read_bytes[5] & 0x0F)
    month = (month_10s * 10) + month_1s
    month_table = {0: 'Undefined', 1: 'January', 2: 'February', 3: 'March', 4: 'April',
        5: 'May', 6: 'June', 7: 'July', 8: 'August', 9: 'September', 10: 'October',
        11: 'November', 12: 'December'}

    year_10s = (read_bytes[6] & 0xF0) >> 4
    year_1s = (read_bytes[6] & 0x0F)
    year = (year_10s * 10) + year_1s

    format_able = {0: '24-hour', 1: '12-hour'}

    print(f"\n* Read values:\n")
    print(f"Oscillator enable:   {ch_bit}")
    if (ch_bit):
        print(f"Hours 12/24 clock:   {hours_12_24} ({format_able[hours_12_24]} format)")
        print(f"Time and date:       {hours}:{minutes}:{seconds}, "
            f"{weekday_table[weekday]}, {month_table[month]} {date}, 20{year:02}\n")

if args.set:

    print("Setting today's time and date")

    ts = datetime.datetime.today()
    seconds = ts.second
    minutes = ts.minute
    hours = ts.hour
    weekday = ts.weekday() + 1
    date = ts.day
    month = ts.month
    year = ts.year - 2000

    ch_bit = 0 # enable oscillator
    sel_12_14_bit = 0 # 0 = 24 bit format

    seconds_10s = int(seconds / 10)
    seconds_1s = seconds - (seconds_10s * 10)
    byte_0 = (ch_bit << 7) | (seconds_10s << 4) | (seconds_1s)

    minutes_10s = int(minutes / 10)
    minutes_1s = minutes - (minutes_10s * 10)
    byte_1 = (minutes_10s << 4) | (minutes_1s)

    hours_10s = int(hours / 10)
    hours_1s = hours - (hours_10s * 10)
    byte_2 = (sel_12_14_bit << 6) | (hours_10s << 4) | (hours_1s)

    byte_3 = weekday

    date_10s = int(date / 10)
    date_1s = date - (date_10s * 10)
    byte_4 = (date_10s << 4) | (date_1s)

    month_10s = int(month / 10)
    month_1s = month - (month_10s * 10)
    byte_5 = (month_10s << 4) | (month_1s)

    year_10s = int(year / 10)
    year_1s = year - (year_10s * 10)
    byte_6 = (year_10s << 4) | (year_1s)

    bytes_to_send = bytearray([
        CMD_BUS_RST,
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,        # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x00,              # Register address to start writing to
        CMD_TX_BYTE,
        byte_0,            # 00h: ST bit, seconds
        CMD_TX_BYTE,
        byte_1,            # 01h: Minutes
        CMD_TX_BYTE,
        byte_2,            # 02h: 12/24, hours
        CMD_TX_BYTE,
        byte_3,            # 03h: OSCON, VBAT, VBATEN, day of the week
        CMD_TX_BYTE,
        byte_4,            # 04h: Date
        CMD_TX_BYTE,
        byte_5,            # 05h: leap year, month
        CMD_TX_BYTE,
        byte_6,            # 06h: Year
        CMD_STOP_CONDITION,
    ])

    print("Sending commands over UART")
    ser.write(bytes_to_send)
    
    print("Done. Use the --read argument to check the result\n")

if args.clear:
    print("Setting the 7 first register bytes to 0's")

    bytes_to_send = bytearray([
        CMD_BUS_RST,
        CMD_START_CONDITION,
        CMD_TX_BYTE,
        ADDR_WRITE,      # Chip address and WRITE command bit
        CMD_TX_BYTE,
        0x00,            # Register address to start writing to
        CMD_TX_BYTE,
        0x80,            # 00h: CH bit, seconds
        CMD_TX_BYTE,
        0x00,            # 01h: Minutes
        CMD_TX_BYTE,
        0x00,            # 02h: 12/24, hours
        CMD_TX_BYTE,
        0x00,            # 03h: Day of the week
        CMD_TX_BYTE,
        0x00,            # 04h: Date
        CMD_TX_BYTE,
        0x00,            # 05h: Month
        CMD_TX_BYTE,
        0x00,            # 06h: Year
        CMD_STOP_CONDITION,
    ])

    print("Sending commands over UART")
    ser.write(bytes_to_send)

    print("Done. Use the --read argument to check the result\n")