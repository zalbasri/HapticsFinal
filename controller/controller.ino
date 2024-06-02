#include <Wire.h>
#include "SparkFun_STTS22H.h"

const int PWMPin = 3; // Set Peltier pin
const int ledPin = 6; // LED pin for testing

SparkFun_STTS22H mySTTS;
float temperature; // Temperature read from sensor
float targetTemp = 75.0;
int distance = 32;

void setup() {
    Wire.begin();
    pinMode(PWMPin, OUTPUT);
    Serial.begin(115200);

    while (!mySTTS.begin()) {
    }

    // Set the data rate to 1Hz
    mySTTS.setDataRate(STTS22H_POWER_DOWN);
    delay(10);
    mySTTS.setDataRate(STTS22H_1Hz);

    // Enable auto-incrementing register behavior for the IC
    mySTTS.enableAutoIncrement();
    delay(100);
}

void loop() {
    // Check if new temperature data is ready
    if (mySTTS.dataReady()) {
        mySTTS.getTemperatureF(&temperature);
    }
    
    // Check if there is any input from the Serial Monitor
    if (Serial.available() > 0) {
        String input = Serial.readStringUntil('\n'); // Read user input until newline
        distance = input.toInt(); // Convert input to integer

        // Ensure distance is within expected range
        if (distance < 0) distance = 0;
        if (distance > 28) distance = 28;

        // Map distance (0-28) to temperature range (75-108)
        targetTemp = map(distance, 0, 28, 108, 75);
        // digitalWrite(ledPin, HIGH);
    }

    if (temperature < targetTemp) {
      analogWrite(PWMPin, 255); 
    } else {
      analogWrite(PWMPin, 0);
    }
}
