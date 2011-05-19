import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.serial.*;
AudioPlayer playnow;
AudioPlayer a7;
AudioPlayer a13;
AudioPlayer a16;
AudioPlayer a18;
AudioPlayer a20;
AudioPlayer a24;
AudioPlayer a33;
AudioPlayer a43;
AudioPlayer a45;
AudioPlayer a47;
AudioPlayer a49;
AudioPlayer a52;
AudioPlayer a57;
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
int counter;

void setup(){

    println(Serial.list());

  myPort = new Serial(this, Serial.list()[1], 57600);
  buf = new byte[40];
  bufPos = 0;
  
  minim = new Minim(this);
    a45 = minim.loadFile("sound 45.mp3", 1024);
    a20 = minim.loadFile("sound 20.mp3", 1024);
    a7 = minim.loadFile("sound 7.mp3", 1024);
    a13 = minim.loadFile("sound 13.mp3", 1024);
    a16 = minim.loadFile("sound 16.mp3", 1024);
    a18 = minim.loadFile("sound 18.mp3", 1024);
    a24 = minim.loadFile("sound 24.mp3", 1024);
    a33 = minim.loadFile("sound 33.mp3", 1024);
    a43 = minim.loadFile("sound 43.mp3", 1024);
    a47 = minim.loadFile("sound 47.mp3", 1024);
    a49 = minim.loadFile("sound 49.mp3", 1024);
    a52 = minim.loadFile("sound 52.mp3", 1024);
    a57 = minim.loadFile("sound 57.mp3", 1024);
    a59 = minim.loadFile("sound 59.mp3", 1024);
    a65 = minim.loadFile("sound 65.mp3", 1024);
    a67 = minim.loadFile("sound 67.mp3", 1024);
    a68 = minim.loadFile("sound 68.mp3", 1024);
    a69 = minim.loadFile("sound 69.mp3", 1024);
    a0 = minim.loadFile("sound 0.mp3", 1024);
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
      firstSample = firstSample + firstValue;
     counter++;
     //now we have been accumulating some values of the sensor. If we have enough for a nice sample,
     //then jump into another if statement to decide what to play.
      
      if( counter == 8){
        firstSample = firstSample/8;
         println("firstSample at the beginning of the loop is " + firstSample);
      //start playing sounds   
        //sounds set through if gates
        if((firstSample>=72) && (firstSample <80)){
          playnow=a20;
          a13.play();
          println("got between 72 and 80");
        }

        if((firstSample>=64) && (firstSample <72)){
          playnow=a13;
          a13.play();
          println("got between 64 and bigger than 72 \n");
        }
        else if((firstSample>=56) && (firstSample <64)){
          playnow=a49;
          a49.play();
          println("got between 56 and 64 \n");
        }
        else if((firstSample>=48) && (firstSample <56)){
          playnow=a47;
          a47.play();
          println("got between 48 and 56 \n");
        }
        else if((firstSample>=40) && (firstSample <48)){
          playnow=a45;
          a45.play();
          println("got between 40 and 48");
        }
        else if((firstSample>=32) && (firstSample <40)){
          playnow=a43;
          a43.play();
          println("got between 32 and 40");
        }
        else if((firstSample>=24) && (firstSample <32)){
          playnow=a16;
          a16.play();
          println("got between 24 and 32");
        }
        else if((firstSample>=16) && (firstSample <24)){
          playnow=a18;
          a18.play();
          println("got between 16 and 24");
        }  
        else {
          playnow=a0;
    println("didn't get anything \n");   
        }
      
      println("got 4 things!");
     print(firstSample + "\n");
      playnow.play(); 
      playnow.rewind();
      
      
      
      firstSample = 0;
     counter = 0; 
     

    
    } 
      
     //for(int i = 0; i < 3; i++){
     //firstValue = (firstValue + fields[0]);
     //}
     //int firstSample = firstValue/3;
     
     
     
      
      
    } else {
      buf[bufPos++] = (byte)ch;
    }
    

   } 
    
  
}



  

   
  
 void stop(){
a7.close();
    a13.close();
    a16.close();
    a18.close();
    a20.close();
    a24.close();
    a33.close();
    a43.close();
    a45.close();
    a47.close();
    a49.close();
    a52.close();
    a57.close();
    a59.close();
    a65.close();
    a67.close();
    a68.close();
    a69.close();

   minim.stop();
   
   super.stop();
   
 }
