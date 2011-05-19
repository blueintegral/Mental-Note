import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.serial.*;
AudioPlayer playnow;
AudioPlayer a58;
AudioPlayer a59;
AudioPlayer a65;
AudioPlayer a67;
AudioPlayer a68;
AudioPlayer a69;
AudioPlayer a0;

Minim minim;
Serial myPort;
Serial keyboard;
byte[] buf;
int bufPos;
int firstValue;
int firstSample;
int secondSample;
int counter;

void setup(){

    println("Here's the list of availible ports: ");
    println(Serial.list());

  myPort = new Serial(this, Serial.list()[0], 57600);
  buf = new byte[40];
  bufPos = 0;
  
  minim = new Minim(this);
    a58 = minim.loadFile("nothing.wav", 1024);
    a59 = minim.loadFile("Am chord.wav", 1024);
    a65 = minim.loadFile("c chord.wav", 1024);
    a67 = minim.loadFile("Cm chord.wav", 1024);
    a68 = minim.loadFile("d chord.wav", 1024);
    a69 = minim.loadFile("Em chord.wav", 1024);
    a0 = minim.loadFile("g chord.wav", 1024);
    playnow=a0;
}

void draw()
{

  while (myPort.available() > 0)
  {
    
    int ch = myPort.read();
    if (ch == 10)
    {
      String str = new String(buf, 0, bufPos);
      bufPos = 0;
      int[] fields = int(split(trim(str), ' '));
      println(fields);
      int firstValue = fields[0];
      int secondValue = fields[1];
      firstSample = firstSample + firstValue;
      secondSample = secondSample + secondValue;
     counter++;
     //now we have been accumulating some values of the sensor. If we have enough for a nice sample,
     //then jump into another if statement to decide what to play.
      
      if( counter == 8){
        firstSample = firstSample/8;
        secondSample = secondSample/8;
        
         println("firstSample at the beginning of the loop is " + firstSample);
      //start playing sounds   
        //sounds set through if statements
        if(secondValue<50){
        if((firstSample>=72) && (firstSample <80)){
          playnow=a0;
          a0.play();
          println("got between 72 and 80");
        }

        if((firstSample>=64) && (firstSample <72)){
          playnow=a68;
          a68.play();
          println("got between 64 and bigger than 72 \n");
        }
        else if((firstSample>=56) && (firstSample <64)){
          playnow=a65;
          a65.play();
          println("got between 56 and 64 \n");
        }
        else if((firstSample>=48) && (firstSample <56)){
          playnow=a59;
          a59.play();
          println("got between 48 and 56 \n");
        }
        else if((firstSample>=40) && (firstSample <48)){
          playnow=a69;
          a69.play();
          println("got between 40 and 48");
        }
        else if((firstSample>=32) && (firstSample <40)){
          playnow=a68;
          a68.play();
          println("got between 32 and 40");
        }
        else if((firstSample>=24) && (firstSample <32)){
          playnow=a65;
          a65.play();
          println("got between 24 and 32");
        }
        else if((firstSample>=16) && (firstSample <24)){
          playnow=a67;
          a67.play();
          println("got between 16 and 24");
        }  
        else {
          playnow=a0;
    println("didn't get anything \n");   
        }
      
      println("got eveything in this set, taking the average");
     print(firstSample + "\n");
     println(secondSample);
      playnow.play(); 
      playnow.rewind();
      
      
      
      firstSample = 0;
     secondSample = 0;
     counter = 0; 
     
        }
        
        //////////////////////////////////////////////////////////////////////
        
        else{
        if((firstSample>=72) && (firstSample <80)){
          playnow=a65;
          a65.play();
          println("got between 72 and 80");
        }

        if((firstSample>=64) && (firstSample <72)){
          playnow=a65;
          a65.play();
          println("got between 64 and bigger than 72 \n");
        }
        else if((firstSample>=56) && (firstSample <64)){
          playnow=a65;
          a65.play();
          println("got between 56 and 64 \n");
        }
        else if((firstSample>=48) && (firstSample <56)){
          playnow=a65;
          a65.play();
          println("got between 48 and 56 \n");
        }
        else if((firstSample>=40) && (firstSample <48)){
          playnow=a65;
          a65.play();
          println("got between 40 and 48");
        }
        else if((firstSample>=32) && (firstSample <40)){
          playnow=a65;
          a65.play();
          println("got between 32 and 40");
        }
        else if((firstSample>=24) && (firstSample <32)){
          playnow=a65;
          a65.play();
          println("got between 24 and 32");
        }
        else if((firstSample>=16) && (firstSample <24)){
          playnow=a65;
          a65.play();
          println("got between 16 and 24");
        }  
        else {
          playnow=a65;
    println("didn't get anything \n");   
        }
      
      println("got eveything in this set, taking the average");
     print(firstSample + "\n");
     println(secondSample);
      playnow.play(); 
      playnow.rewind();
      
  
      firstSample = 0;
     secondSample = 0;
     counter = 0; 
     
        }
    
    }  
    } else {
      buf[bufPos++] = (byte)ch;
    }
   }   
}

 void stop(){
    a58.close();
    a59.close();
    a65.close();
    a67.close();
    a68.close();
    a69.close();

   minim.stop();
   
   super.stop();
   
 }
