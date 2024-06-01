#include <Wire.h>
#include "SparkFun_STTS22H.h"

const int PWMPin = 3; // Set Peltier pin

SparkFun_STTS22H mySTTS;
float temperature; // Temperature read from sensor
int distance;

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
    if (Serial.available() > 0) {
        distance = Serial.parseInt(); // Read distance value from Serial input
        // Ensure distance is within expected range
        if (distance < 0) distance = 0;
        if (distance > 32) distance = 32;

        // Map distance (0-32) to temperature range (75-105)
        float targetTemp = map(distance, 0, 32, 75, 105);

        // Adjust PWM based on target temperature
        // Assuming PWM needs to be adjusted from 0 to 255
        int pwmValue = map(targetTemp, 75, 105, 0, 255);
        analogWrite(PWMPin, pwmValue); // Write PWM value to Peltier

        Serial.print("Distance: ");
        Serial.print(distance);
        Serial.print(", Target Temp: ");
        Serial.print(targetTemp);
        Serial.print("F, PWM Value: ");
        Serial.println(pwmValue);
    }

    // Check if new temperature data is ready
    if (mySTTS.dataReady()) {
        mySTTS.getTemperatureF(&temperature);

        Serial.print("Temp: ");
        Serial.print(temperature);
        Serial.println("F");
    }

    delay(1000);
}
