import processing.serial.*;

Serial myPort;
int orb_distance = 25; // example distance value

void setup() {
  // Replace "COM4" with your actual port name and ensure it matches the port where Arduino is connected
  println(Serial.list());
  String portName = Serial.list()[7]; //change the 0 to a 1 or 2 etc. to match your port
  println(portName);
  myPort = new Serial(this, portName, 115200); //make sure baud rate matches Arduino
}

void draw() {
  myPort.write(orb_distance);
  delay(1000); // Send the value every second
}
