## joystick reader on Lattice iCEstick FPGA Evaluation Kit
Interfaces 2 channels of the ads1115 ADC using the generic i2c controller and a python script
The joystick is connected to channels A0 (X) and A1 (Y) of the ADS1115.

## Hardware
Lattice iCEstick FPGA Evaluation Kit

## Software

### ads1115

### i2c
Generic I2C controller to communicate with any target.

### i2cshell
Terminal commands and python script to communcate with the joystick connected to the ADS1115.
The joystick is connected to channels A0 and A1 of the ADS1115

### joystick_demo

* Demo application that reads values from A0 and A1 in single shot mode.
* Values are read approximately 6 times a second.
* Values are published to the UART.
* A python script reads the values and draws X and Y bars.

Pitfall: The python script reads 5 bytes from the UART. There should be onyl 4.

### joystick_reader
Implementation of the single shot reader with configurable channel.
Uses the generic I2C controller to communicate with the target.

### reset_sync
Synchronized reset implementation provided by https://vhdlwhiz.com/.

### uart
UART implementation provided by https://vhdlwhiz.com/.


