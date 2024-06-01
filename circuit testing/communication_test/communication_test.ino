void setup() {
    Serial.begin(115200);
    Serial.println("Ready");
}

void loop() {
    if (Serial.available() > 0) {
        int distance = Serial.parseInt(); // Read distance value from Serial input
        Serial.print("Received: ");
        Serial.println(distance);
    } else {
        Serial.println("No data available.");
    }
    delay(1000);
}
