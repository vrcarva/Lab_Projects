
/* Modified by Flavio Mourão
   NNC / UFMG - since November 2018 
   
 Project for monitoring heart rate and rectal temperature during surgery. 
 In addition, the rectal temperature will be used as a control for the thermal blanket heating.
 
   Building Circuit e changing variables - early December 
   
   Add temperature code - 18/12/18 - 22:45
  
   Fixed interrupt for Temperature / Pulse measurement timer - 28/12/18 - 10:40
  
   Add 5V RELAY for temperature control - 18/01/19 - 7:00
  
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
THERMISTOR NTC from TR-200 Temperaturregler Fine Science Tools - resistence 2252 ohm (25 C)
THERMISTOR NTC 100K (25 C) from Filipe Flop store: https://www.filipeflop.com/produto/termistor-ntc-100k-com-cabo/

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

Display:  SDA pin   -> Arduino Analog 4 or the dedicated SDA pin
          SCL pin   -> Arduino Analog 5 or the dedicated SCL pin
       
*/

//--------------------------------------------------------------------------------

// SET HOW TO VISUALIZER

#define PROCESSING_VISUALIZER 1

#define SERIAL_PLOTTER  2

#define OLED_MONITOR 3
#include <Adafruit_SSD1306.h>     // Remember to set the oled resolution in the library in our case 128x64
#define OLED_Address 0x3C         // Try 0x3D if not working
Adafruit_SSD1306 oled(128, 64);   // create our screen object setting resolution to 128x64

// Variables for OLED MONITOR
int x=0;
int lastx=0;
int lasty=0;
int LastTime=0;

// SET THE SERIAL OUTPUT TYPE TO YOUR NEEDS, just uncomment the line:

// PROCESSING_VISUALIZER works with Pulse Sensor Processing Visualizer
// https://github.com/WorldFamousElectronics/PulseSensor_Amped_Processing_Visualizer
//const int outputType = PROCESSING_VISUALIZER;

// SERIAL_PLOTTER outputs sensor data for viewing with the Arduino Serial Plotter
// run the Serial Plotter at 115200 baud: Tools/Serial Plotter or Command+L
// static int outputType = SERIAL_PLOTTER;

// OLED SSD1306 MONITOR
static int outputType = OLED_MONITOR;


//--------------------------------------------------------------------------------

// PULSE MONITOR

//  Variables for pulse measure
int pulsePin = 0;                   // Pulse Sensor connected to analog pin 0
int blinkPin = 13;                  // pin to blink led at each beat
int fadePin = 5;                    // pin to do fancy classy fading blink at each beat
int fadeRate = 0;                   // used to fade LED on with PWM on fadePin

// Volatile Variables, used in the interrupt service routine!
volatile int BPM;                   // int that holds raw Analog in 0. updated every 2mS
volatile int Signal;                // holds the incoming raw data
volatile int IBI = 600;             // int that holds the time interval between beats! Must be seeded!
volatile boolean Pulse = false;     // "True" when User's live heartbeat is detected. "False" when not a "live beat".
volatile boolean QS = false;        // becomes true when Arduoino finds a beat.

//--------------------------------------------------------------------------------

// TEMPERATURE

#include <math.h>

// which analog pin to connect
#define THERMISTORPIN A1 

// Change here accordingly the Thermistor resistence
#define THERMISTORNOMINAL 100000  // ohm

// temp. for nominal resistance (almost always 25 C)
#define TEMPERATURENOMINAL 25

// The beta coefficient of the thermistor (usually 3000-4000)
// https://www.ametherm.com/thermistor/ntc-thermistor-beta
#define BCOEFFICIENT 3950

// Resistor value  
#define SERIESRESISTOR 10000

// how many samples to take and average, more takes longer (maily for pulse measurement)
// but the temperature is more 'smooth'. 
#define NUMSAMPLES 20


// Temperature variables

uint16_t samples[NUMSAMPLES];   // samples to mean
float steinhart;                // Steinhart-Hart equation result (from resistence to temperature)
int temp;                       // Output temperature

int relayPin = 2;               // RELAY Control

//--------------------------------------------------------------------------------

void setup(){
  pinMode(blinkPin,OUTPUT);         // pin that will blink to your heartbeat
  pinMode(fadePin,OUTPUT);          // pin that will fade to your heartbeat  
  
  pinMode(relayPin, OUTPUT);        // pin that will control the RELAY to the temperature
  
  Serial.begin(115200);             
  interruptSetup();                 // sets up to read Pulse Sensor signal every 2mS
  
// IF YOU ARE POWERING The Pulse Sensor AT VOLTAGE LESS THAN THE BOARD VOLTAGE,
// UN-COMMENT THE NEXT LINE AND APPLY THAT VOLTAGE TO THE A-REF PIN
//analogReference(EXTERNAL);

  
  // initialize and clear OLED MONITOR
  oled.begin(SSD1306_SWITCHCAPVCC, OLED_Address);
  oled.clearDisplay();
}

void loop(){
  
  pulse();
  temperature();

}

void pulse() {
    serialOutput() ;

  if (QS == true){                          // A Heartbeat Was Found
                                            // BPM and IBI have been Determined
                                            // Quantified Self "QS" true when arduino finds a heartbeat
        fadeRate = 255;                     // Makes the LED Fade Effect Happen
                                            // Set 'fadeRate' Variable to 255 to fade LED with pulse
        serialOutputWhenBeatHappens();      // A Beat Happened, Output that to serial.
        QS = false;                         // Reset the Quantified Self flag for next time
  }

  ledFadeToBeat();                          // Makes the LED Fade Effect Happen
  delay(20);                                // Take a break
}


void ledFadeToBeat(){
    fadeRate -= 15;                         //  Set LED fade value
    fadeRate = constrain(fadeRate,0,255);   //  Keep LED fade value from going into negative numbers!
    analogWrite(fadePin,fadeRate);          //  Fade LED
  }


// Temperature

unsigned long timer = millis () ;

void temperature() {
      uint8_t i;
      float average;                         // Variable for simple average
      
      
  if ((millis () - timer) >= 2000) {         // Ran out of the pulse time to hit the temperature . 1 value per 2 seconds
      timer = millis();

      // Averaging
      // Take N samples in a row, with a slight delay
      for (i=0; i< NUMSAMPLES; i++) {
      samples[i] = temp;
      delay(1);
   
      }
 
      // Average all the samples out
      average = 0;
      for (i=0; i< NUMSAMPLES; i++) {
        average += samples[i];
      }
      average /= NUMSAMPLES;
 
 
      // Convert the value to resistance 
      average = 1023 / average - 1;
      average = SERIESRESISTOR / average;

      
      // Steinhart-Hart equation
      
      steinhart = 0;
      steinhart = average / THERMISTORNOMINAL;            // (R/Ro)
      steinhart = log(steinhart);                         // ln(R/Ro)
      steinhart /= BCOEFFICIENT;                          // 1/B * ln(R/Ro)
      steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15);   // + (1/To)
      steinhart = 1.0 / steinhart;                        // Invert
      steinhart -= 273.15;                                // Convert to C
 
      }

}
