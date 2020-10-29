device = serialport("COM5",9600);
configureTerminator(device,"CR");
writeline(device,"X100");
writeline(device,"X0");
clear device;