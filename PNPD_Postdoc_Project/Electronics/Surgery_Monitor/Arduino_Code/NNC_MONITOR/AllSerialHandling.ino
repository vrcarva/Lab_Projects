
/*
All Serial Handling Code, It's Changeable with the 'outputType' variable
It's declared at start of code.
*/

void serialOutput(){   // Decide How To Output Serial.

  switch(outputType){
    case PROCESSING_VISUALIZER:
      sendDataToSerial('S', Signal);     // Goes to sendDataToSerial function
      break;
    
    case SERIAL_PLOTTER:                 // Open the Arduino Serial Plotter to visualize these data
      Serial.print(BPM);
      Serial.print(",");
      Serial.print(IBI);
      Serial.print(",");
      Serial.println(Signal);

      //Serial.print("Temperature "); 
      //Serial.print(steinhart);
      //Serial.println(" *C");
      
      //delay(2000);                    // For 'Serial Plotter' comment this line
      
      break;

    case OLED_MONITOR:
       {
       if(x>127)  
       {
         oled.clearDisplay();
         x=0;
         lastx=x;
       }
      int value = Signal;
      oled.setTextColor(WHITE);     
      int y=60-(value/16);
      oled.writeLine(lastx,lasty,x,y,WHITE);
      lasty=y;
      lastx=x;
      
      oled.setCursor(8,0);
      oled.setTextSize(1);
      oled.print("NNC SURGERY MONITOR");
      oled.writeFillRect(0,50,128,16,BLACK);
      oled.setCursor(10,55);
      oled.setTextSize(1.5);
      oled.print("HR:");
      oled.print(BPM);
      oled.print("bpm");
      
      x++;

      oled.setCursor(73,55);
      oled.setTextSize(1.5);
      oled.print("T:"); 
      oled.print(steinhart,1); // plot with decimal value 
      oled.println("C");
      oled.display();

       }
       
      break;
    default:
      break;
  }

}

//  Decides How To OutPut BPM and IBI Data to PROCESSING_VISUALIZER:

void serialOutputWhenBeatHappens(){
  switch(outputType){
    case PROCESSING_VISUALIZER:    // find it here https://github.com/WorldFamousElectronics/PulseSensor_Amped_Processing_Visualizer
      sendDataToSerial('B',BPM);   // send heart rate with a 'B' prefix
      sendDataToSerial('Q',IBI);   // send time between beats with a 'Q' prefix
      break;

    default:
      break;
  }
}

//  Sends Data to Pulse Sensor Processing App, Native Mac App, or Third-party Serial Readers.
void sendDataToSerial(char symbol, int data ){
    Serial.print(symbol);
    Serial.println(data);
  }
