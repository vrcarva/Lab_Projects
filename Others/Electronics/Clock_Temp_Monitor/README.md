# Clock, Humidity and Temperature Monitor 

Design based on the original "Arduino Digital Clock & Thermometer" project

http://www.ardumotive.com/digitalclockther-en.html

Adaptations were made in the 3D design to use the DHT22 Temperature and Humidity Sensor and to create a external USB port to program the Arduino Pro Mini.
 
HARDWARE :
- Arduino Pro Mini (5v version) or another board based in at Mega328p micro controller
- I2C LCD 16x2
- DHT-22 (or DHT series)
- RTC DS1307 (module with cell battery)
- 3 push buttons
- 1 on/off button
- USB plug
- Rechargeable battery (950mAh mobile phone battery) or DC jack and one 5V power adapter/converter

The i2c lcd and RTC module must be connected to the Arduino SDA and SCL pins. If you are using the Arduino uno or Arduino Pro Mini (or another board based in at Mega328p microcontroller), use the I2C interface at A4 (SDA) and A5(SCL) pins.

I2C LCD 16x2:
- Vcc to power source (max 5V)
- GND to GND
- SDA to pin A4
- SCL to pin A5

RTC DS1307 module:
- Vcc to power source (max 5V)
- GND to GND
- SDA to pin A4
- SCL to pin A5

DHT 22 sensor :
- Pin1 - VCC (3 - 5.5V Input)
- Pin2 - Data - Arduino AnalogPin 10
- Pin3 - Not Connect
- Pin4 - GND

Push buttons:
- Setup    button to pin 2 
- Set Up   button to pin 3
- Set Down button to pin 4
- The second pin of all buttons must be connected to ground (GND)

USB (Left to right)
- Pin1 —> VCC
- Pin2 —> RX
- Pin3 —> RESET
- Pin4 —> TX

References:

How to program arduino pro mini: 

https://www.instructables.com/id/Program-Arduino-Pro-Mini-Using-Arduino-Uno/
https://www.arduinoecia.com.br/2014/09/conversor-ftdi-ft232rl-arduino-pro-mini.html

Guides:

https://www.filipeflop.com/blog/relogio-rtc-ds1307-arduino/ https://learn.adafruit.com/ds1307-real-time-clock-breakout-board-kit/what-is-an-rtc http://www.ardumotive.com/how-to-use-dht-21-sensor-en.html https://github.com/fdebrabander/Arduino-LiquidCrystal-I2C-library https://www.arduinoecia.com.br/2014/12/modulo-i2c-display-16x2-arduino.html


https://howtomechatronics.com/tutorials/arduino/lcd-tutorial/ http://www.circuitbasics.com/how-to-set-up-an-lcd-display-on-an-arduino/ https://www.baldengineer.com/arduino-lcd-display-tips.html https://maxpromer.github.io/LCD-Character-Creator/

![https://github.com/fgmourao/Lab_Projects/blob/master/Electronics/Clock_Temp_Monitor/Images/Front_on2.jpg](https://github.com/fgmourao/Lab_Projects/blob/master/Electronics/Clock_Temp_Monitor/Images/Front_on2.jpg)
