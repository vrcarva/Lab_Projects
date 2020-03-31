/* Núcleo de Neurociências - UFMG/Brazil (Universidade Federal de Minas Gerais)
 *  
 * FRAMES COUNTER TO SYNCHRONIZE VIDEOS WITH ELECTROPHYSIOLOGICAL RECORDS

* Through BONSAI software (https://bonsai-rx.org/) we receive a "FRAME" number in a 10-digit "string" (without \ r \ n) in a 9600 BaudRate.
* (Bonsai does not appear to be able to program the "SerialStringWrite" function with another BaudRate).
*
* A digital output (PWM) must be chosen to "FLIP" at each nFrames transition. That is, the pin is nFrames
* high and nFrames low, oscillating at each frame collected and saved.

* Authors: Flávio Afonso Gonçalves Mourão - mourao.fg@gmail.com
*          Márcio Flávio Dutra Moraes     - mfdm@icb.ufmg.br
*          
*          24/04/2019
*/

int nFrames=10;   // Defines the number of frames to be saved
int iCount=0;    // Will store the collected frame
char Buffer[20]; // Buffer for the "string". You only need ten, but I added more just to make sure

void setup()
{
  pinMode(10,OUTPUT); // Sets the digital pin
  Serial.begin(9600); // BaudRate
}

void loop()
{
if (Serial.available()>0)                                        // Condition: check only if the signal is coming
  {
    Serial.readBytes(Buffer,10);                                 // The system always assembles 10 characters: saida = saida+ " "*(10-len(saida));
    iCount=String(Buffer).toInt();                               // Convert the collected "string" into an integer -> "iCount" variable
    if((iCount%nFrames)==0) digitalWrite(10,(iCount/nFrames)%2); // Condition: only integer multiple of nFrames
                                                                 // (in this case, the  remainder of "integer multiple" by 2 will be equal 1 or 0, which defines the state of the pin ("High" or "Low")
  }

  //
}
