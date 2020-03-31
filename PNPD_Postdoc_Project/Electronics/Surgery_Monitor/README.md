# Surgery Monitor
   
Project for monitoring heart rate and rectal temperature during surgery. In addition, the rectal temperature will be used as a control for the thermal blanket heating.
   
NNC / UFMG - since November 2018   

UPDATES:   

-----   

Add temperature code - 18/12/18 - 22:45

-----

Fixed interrupt for Temperature / Pulse measurement timer - 28/12/18 - 10:40 . 

-----

Add 5V RELAY for temperature control - 18/01/19 - 7:00 . 

--------------------------------------------------------------------------------

PULSE SENSOR:

References:

Guides:

   https://www.hackster.io/104829/detecting-heart-rate-with-a-photoresistor-680b58
   https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino 
   https://makezine.com/projects/ir-pulse-sensor/
   https://www.instructables.com/id/Heart-rate-measuring-device-using-arduino/

Guide for default code:
Pulse Sensor Amped 1.5    by Joel Murphy and Yury Gitman  
  
   http://www.pulsesensor.com
   https://github.com/WorldFamousElectronics/PulseSensor_Amped_Arduino

Notes:
This code:
1) INPUT SIGNAL ANALOG PIN 0
2) Blinks an LED to User's Live Heartbeat   PIN 13
2) Fades an LED to User's Live HeartBeat    PIN 5
3) Determines BPM
4) Prints All of the Above to Serial

-----------------------------------------------------------------------------------------------------------

TEMPERATURE:

Original Articles:

   https://learn.adafruit.com/thermistor/using-a-thermistor

Other Guides:

   http://www.resistorguide.com/ntc-thermistor/
   https://en.wikipedia.org/wiki/Thermistor

Resistance at 25 degrees C --> // https://www.ametherm.com/blog/thermistor/arduino-and-thermistors

I have 2 kinds of Thermistors: 

- THERMISTOR NTC from TR-200 Temperaturregler Fine Science Tools - resistence 2252 ohm (25 C)
- THERMISTOR NTC 100K (25 C) from Filipe Flop store (Im using this one): 

   https://www.filipeflop.com/produto/termistor-ntc-100k-com-cabo/

Notes:
This code:
1) INPUT SIGNAL ANALOG PIN 1

--------------------------------------------------------------------------------

5V RELAY for temperature control

References:

Guides:
        
   http://www.circuitbasics.com/setting-up-a-5v-relay-on-the-arduino/
        
Notes:
This code:
1) OUTPUT SIGNAL DIGITAL PIN 2

--------------------------------------------------------------------------------
OLED DISPLAY:

Guides:
     
   https://startingelectronics.org/tutorials/arduino/modules/OLED-128x64-I2C-display/
   http://www.xtronical.com/pulseheartsensor/
   https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf
   http://www.solomon-systech.com/files/ck/files/catalog/SSLcatalog_AD_OLED_Driver_IC_201604.pdf
   https://learn.adafruit.com/adafruit-gfx-graphics-library

Notes:
This code:

Arduino Uno/2009:

Display:  
SDA pin   -> Arduino Analog 4 or the dedicated SDA pin .     
SCL pin   -> Arduino Analog 5 or the dedicated SCL pin . 


![https://github.com/fgmourao/Lab_Projects/blob/master/PNPD_Postdoc_Project/Electronics/Surgery_Monitor/Images/Monitor_protoOLED.png](https://github.com/fgmourao/Lab_Projects/blob/master/PNPD_Postdoc_Project/Electronics/Surgery_Monitor/Images/Monitor_protoOLED.png)
