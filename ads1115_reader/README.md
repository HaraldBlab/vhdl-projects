# ads1115 reader on Lattice iCEstick FPGA Evaluation Kit
Interfaces ads1115 ADC using a generic i2c controller and a python script

## Hardware
Lattice iCEstick FPGA Evaluation Kit

## Software

### ads1115_demo

* Demo application that reads values from A0 in single shot mode.
* Values are read approximately 6 times a second.
* Values are published to the  UART.
* A python script reads the values and draws bars.

### ads1115_reader
Implementation of the single shot reader.
Uses the generic I2C controller to communicate with the target.

### i2c
Generic I2C controller to communicate with any target.

### i2cshell
Terminal commands and pyhton script to communcate with the ADS1115.

### reset_sync
Synchronized reset implementation provided by https://vhdlwhiz.com/.

### uart
UART implementation provided by https://vhdlwhiz.com/.


