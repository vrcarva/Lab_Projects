/*
Flavio Mourao
NNC / UFMG - 6th November 2018

Biphasic square waves for periodic electrical stimulation

The digital signal is generated through an Arduino with programmable attributes such as wavelengths and interpulse intervals. 
This signal from Arduino is decoupled through a simple circuit formed by a Optocoupler and then the output amplitude (0 - 9 V) can be modulated by a potentiometer.

Extra digital outputs are used to reproduce the generated time events and to allow visual feedback through an LED.

*/


const byte TriggerIndicator = 9;                       // output to record events
int delay_pulse_trigger = 1;                           // delay between the real pulse and the digital signal for the recording system
const byte LEDIndicator = 10;                          // LED connected to the digital pin 10 to identify the the programmed frequency
int square_length_LED = 9;                             // square length in milliseconds to trigger the LED. Attention: This delay will be added to the delay of the pin 9,                                                   


const byte pulse1       = 11;                          // output signal 1
const byte pulse2       = 12;                          // output signal 2
int square_length = 100;                               // square pulse length in microseconds
int delay_pulses = 35;                                 // delay between pulses in microseconds
float frequency = 1;                                   // frequency
const unsigned long f = (1000000/(frequency*1000));

unsigned long pulseLEDtimer = 0;

void setup()
{
  pinMode(LEDIndicator,OUTPUT);
  pinMode(TriggerIndicator,OUTPUT);
  pinMode(pulse1, OUTPUT);
  pinMode(pulse2, OUTPUT);

  digitalWrite(LEDIndicator, LOW);
  digitalWrite(TriggerIndicator, LOW);
  digitalWrite(pulse1, LOW);  
  digitalWrite(pulse2, LOW);    
    
  
  unsigned long pulseLEDtimer = millis () ;

}

void loop()
{
 
  if ((millis () - pulseLEDtimer) >= f) {
    pulseLEDtimer = millis();

    digitalWrite(LEDIndicator, HIGH);   
    digitalWrite(TriggerIndicator, HIGH);
    digitalWrite(pulse1, HIGH); 
    delayMicroseconds(square_length);   
    digitalWrite(pulse1, LOW);    
    delayMicroseconds(delay_pulses);

    digitalWrite(pulse2, HIGH);
    delayMicroseconds(square_length);
    digitalWrite(pulse2, LOW);

    delay(delay_pulse_trigger); 
    digitalWrite(TriggerIndicator, LOW);    
    delay(square_length_LED);
    digitalWrite(LEDIndicator, LOW);
 
            
  }
}
