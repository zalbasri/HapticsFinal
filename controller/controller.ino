#include <Wire.h>
#include "SparkFun_STTS22H.h"

const int PWMPin = 3; // Set Peltier pin

SparkFun_STTS22H mySTTS;
float temperature;

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
    digitalWrite(PWMPin, HIGH); // Write to Peltier

    // Check if new temperature data is ready
    if (mySTTS.dataReady()) {
        mySTTS.getTemperatureF(&temperature);

        Serial.print("Temp: ");
        Serial.print(temperature);
        Serial.println("F");
    }

    delay(1000);
}
