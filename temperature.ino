#include <Wire.h>
#include "SparkFun_STTS22H.h"
 
SparkFun_STTS22H mySTTS; 
 
float temp; 
 
void setup()
{
 
    Wire.begin();
 
    Serial.begin(115200);
 
    if( !mySTTS.begin() )
    {
        Serial.println("Did not begin.");
        while(1);
    }
 
    Serial.println("Ready");
 
    // Other output data rates can be found in the description
    // above. To change the ODR or mode, the device must first be
    // powered down.
    mySTTS.setDataRate(STTS22H_POWER_DOWN);
    delay(10);
    mySTTS.setDataRate(STTS22H_1Hz);
 
    // Enables incrementing register behavior for the IC.
    // It is not enabled by default as the datsheet states and
    // is vital for reading the two temperature registers.
    mySTTS.enableAutoIncrement();
 
    delay(100);
}
 
void loop()
{
 
    // Only use data ready for one-shot mode or 1Hz output. 
    if( mySTTS.dataReady() ) 
    {
 
        mySTTS.getTemperatureF(&temp);
 
        Serial.print("Temp: "); 
        Serial.print(temp);
        Serial.println("F"); 
 
    } 
 
    delay(1000);
 
}
