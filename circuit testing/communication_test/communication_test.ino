int val; // Data received from the serial port
int ledPin = 6; // Set the pin to digital I/O 13

void setup() {
    Serial.begin(115200);
    Serial.println("Ready");
}


void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n'); 
    val = input.toInt();
  }
  
  if (val == 32) { 
    digitalWrite(ledPin, HIGH); // turn the LED on
  } else {
    digitalWrite(ledPin, LOW); // otherwise turn it off
  }
  
}
