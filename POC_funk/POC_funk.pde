import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.serial.*;
AudioPlayer playnow;
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

  myPort = new Serial(this, Serial.list()[1], 57600);
  buf = new byte[40];
  bufPos = 0;
  
  minim = new Minim(this);
    a59 = minim.loadFile("nothing.wav", 1024);
    a65 = minim.loadFile("1.mp3", 1024);
    a67 = minim.loadFile("2.mp3", 1024);
    a68 = minim.loadFile("3.mp3", 1024);
    a69 = minim.loadFile("4.mp3", 1024);
    a0 = minim.loadFile("5.mp3", 1024);
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
     //now we have been accumulating some values of the sensor. If we have enough (8) for a nice sample,
     //then jump into another if statement to decide what to play.
      
      if( counter == 8){
        firstSample = firstSample/8;
        secondSample = secondSample/8;
        
         println("firstSample at the beginning of the loop is " + firstSample);
      //start playing sounds   
        //sounds set through if statements
    
        if((firstSample>=67) && (firstSample <80)){
          playnow=a0;
          a0.play();
          println("got between 80 and 101 \n");
         delay(9000);
        }
        else if((firstSample>=50) && (firstSample <66)){
          playnow=a69;
          a69.play();
          println("got between 60 and 79");
          delay(9000);
        }
        else if((firstSample>=33) && (firstSample <49)){
          playnow=a68;
          a68.play();
          println("got between 40 and 59");
          delay(9000);
        }
        else if((firstSample>=17) && (firstSample <32)){
          playnow=a67;
          a67.play();
          println("got between 21 and 39");
          delay(9000);
        }
        else if((firstSample>=0) && (firstSample <16)){
          playnow=a65;
          a65.play();
          println("got between 20 and 0");
          delay(9000);
        }  
        else {
          playnow=a0;
    println("didn't get anything \n");   
        }
      
      println("got eveything in this set, taking the average");
     print(firstSample + "\n");
     println(secondSample);
     // playnow.play(); 
        playnow.rewind();
      
      
      
      firstSample = 0;
     secondSample = 0;
     counter = 0; 
     

        
        //////////////////////////////////////////////////////////////////////
        
       
        
    
    }  
    } else {
      buf[bufPos++] = (byte)ch;
    }
   }   
}

 void stop(){
    a59.close();
    a65.close();
    a67.close();
    a68.close();
    a69.close();

   minim.stop();
   
   super.stop();
   
 }
