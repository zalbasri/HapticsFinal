#include <Wire.h>
#include "SparkFun_STTS22H.h"

const int PWMPin = 3; // Set Peltier pin

SparkFun_STTS22H mySTTS;
float temperature; // Temperature read from sensor
float targetTemp = 75.0;
int distance = 32;

void setup() {
    Wire.begin();
    pinMode(PWMPin, OUTPUT);
    Serial.begin(115200);

    if (!mySTTS.begin()) {
        Serial.println("Did not begin.");
        while (1);
    }

    Serial.println("Ready");

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
        if (distance > 32) distance = 32;

        // Map distance (0-32) to temperature range (75-105)
        targetTemp = map(distance, 0, 32, 105, 75);
    }

    if (temperature < targetTemp) {
      analogWrite(PWMPin, 255); 
    } else {
      analogWrite(PWMPin, 0);
    }
    
    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.print(", Target Temp: ");
    Serial.print(targetTemp);
    Serial.print("F, Current Temp: ");
    Serial.println(temperature);
}
