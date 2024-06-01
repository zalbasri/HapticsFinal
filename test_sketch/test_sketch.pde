import processing.serial.*;

Serial myPort;

void setup() {
  // Replace "COM4" with your actual port name and ensure it matches the port where Arduino is connected
  println(Serial.list());
  String portName = Serial.list()[6]; //change the 0 to a 1 or 2 etc. to match your port
  println(portName);
  myPort = new Serial(this, portName, 115200); //make sure baud rate matches Arduino
}

void draw() {
  if (mousePressed == true) {
    int val = 1;
    myPort.write(val);         //send a 1
    println("1");   
  } else {                           //otherwise
    int val = 0;
    myPort.write(val);          //send a 0
  }   
}
