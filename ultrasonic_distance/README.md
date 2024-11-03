# ultrasonic distance on Lattice iCEstick FPGA Evaluation Kit
Detects the distance to an object and shows the result on a led bar.

## Hardware
Lattice iCEstick FPGA Evaluation Kit

## Software

### icecube2_icestick
Project directory

### top
Top level implementation.

### ultrasonic_distance
Implementation of the ultra sonic interface.

* Performs the cylic triggering of a timed measurement.
* Translates the time measured to a distance value.
* Rounds the distance values to 5 cm.
* Shows runded values on led bar. The closer the object is, the more leds light.

### reset_sync
Synchronized reset implementation provided by https://vhdlwhiz.com/.


