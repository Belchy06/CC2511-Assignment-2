# CC2511 Assignment 2 2020
CC2511 - Embedded Systems Design - Control System for a Computer Numerical Controlled (CNC) Mill


## Choose Branch according to which method of control you want
* GUI Control - Open Performance Analyzer.m, connect to the freedom board via the corresponding COM port, calibrate and then either manually control or engrave a file
* Terminal Control - Open the program PUTTY and connect to the freedom board via the corresponding COM port with baud rate 9600. Follow the terminals instructions to move the engraver


## Improvments
For those cheeky kiddos next year, here are some improvements that can be made:
* Add method for changing the stepping mode. The GPIOs are connected, just uncontrollable at the moment. Add a new command, eg. "Mx" with x being a value from 0 to 5 depending on the stepping mode required. Do:
```
Mode0pin_PutVal(((x >> 0) % 2 == 1) ? 1 : 0);
Mode1pin_PutVal(((x >> 0) % 2 == 1) ? 1 : 0);
Mode2pin_PutVal(((x >> 0) % 2 == 1) ? 1 : 0);
``` 
  to control the stepping mode from the output of the pin.

* Make emergency stop button in MATLAB GUI actually work, right now it attempts to disconnect the device but actually doesn't. Pretty poor bug
* Add the functionality for the mill to send a response to MATLAB after it has executed each command so matlab can send another one instead of with the periodic thing which is pretty terrible eg. 
```
MATLAB -> sends command and waits for response 
K22F -> execute command and sends "OK" response 
MATLAB -> receives response and sends next command
```
* Add an interrupt to the FAULT pin so if there is an error, stop code execution
