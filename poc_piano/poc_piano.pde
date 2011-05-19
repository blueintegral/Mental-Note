import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.serial.*;

AudioPlayer playnow;
AudioPlayer progression;
AudioPlayer chord1;
AudioPlayer chord2;
AudioPlayer chord3;
AudioPlayer chord4;
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
int secondSample;
int counter;
int justPlayed;
int initial = 1;
boolean temp;
int possibleNotes;
int measure1FirstSample, measure1SecondSample, measure2FirstSample, measure2SecondSample, measure3FirstSample, measure3SecondSample, measure4FirstSample, measure4SecondSample;
int packetCount;
int currentNote;
int noteLength;
boolean firstChunk;
float beatsLeft;
int[] noteSequence = new int[8];
int sequenceCount;
int currentPitch;
int[] pitchSequence = new int[8];
int numberNotes;

void setup(){

    println("Here's the list of availible ports: ");
    println(Serial.list());

  myPort = new Serial(this, Serial.list()[1], 57600);
  buf = new byte[40];
  bufPos = 0;
  
  minim = new Minim(this);
    progression = minim.loadFile("progression.mp3", 1024);
    chord1 = minim.loadFile("chord1.mp3", 1024);
    chord2 = minim.loadFile("chord2.mp3", 1024);
    chord3 = minim.loadFile("chord3.mp3", 1024);
    chord4 = minim.loadFile("chord4.mp3", 1024);
    a45 = minim.loadFile("high_f.mp3", 1024);
    a20 = minim.loadFile("high_e.mp3", 1024);
    a13 = minim.loadFile("high_d.mp3", 1024);
    a16 = minim.loadFile("high_c_sharp.mp3", 1024);
    a18 = minim.loadFile("high_c.mp3", 1024);
    a24 = minim.loadFile("g_sharp.mp3", 1024);
    a33 = minim.loadFile("g.mp3", 1024);
    a43 = minim.loadFile("f_sharp.mp3", 1024);
    a47 = minim.loadFile("f.mp3", 1024);
    a49 = minim.loadFile("e.mp3", 1024);
    a52 = minim.loadFile("d_sharp.mp3", 1024);
    a57 = minim.loadFile("d.mp3", 1024);
    a59 = minim.loadFile("c_sharp.mp3", 1024);
    a65 = minim.loadFile("c.mp3", 1024);
    a67 = minim.loadFile("b_flat.mp3", 1024);
    a68 = minim.loadFile("b.mp3", 1024);
    a69 = minim.loadFile("a.mp3", 1024);
    a0 = minim.loadFile("high_d_sharp.mp3", 1024);
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
     
      //ok, so now we have the first 2 instantaneous values from the headset. Let's do something with them.
      
      //so how this thing works is we play a chord progression. Based on what chord we're on, we allow
      //a certain range of notes to be played. So let's first restrict the note pool to make sure they
      //will all sound good.
        
   //start playing the loop
  
  if(initial == 1){ //first time
    playnow = progression;
   progression.rewind();
   progression.play();
   initial = 0;
  }
  
   if(progression.position() >= 16161){ //yeah, yeah, I know there's a blip between loops. I don't know how to fix that yet.
    playnow = progression;
   progression.rewind();
   progression.play();
  }
     println("current position is " + progression.position()); //position gives back time in milliseconds that has elapsed in the current track playing
   
  //ok, lets constrain what notes can be played based on the current chord 
   
   if((progression.position() >= 0) && (progression.position() <= 3600 )){
    println("possible notes are everything in a c minor scale");
    possibleNotes = 1;
    
    //First, let's figure out how long the note(s) will be. We have 4 beats, so based on the 1st number from the Force Trainer, it'll either be a whole note,
    //half notes, quarter, or 8th note. We'll take an average and that will choose which of those we are playing. If it picks a note value less than a whole note, we'll
    //take an average over only a few numbers to generate enough notes to fill the measure. Since it takes 15 "packets" per measure, shorter notes are representitive of a 
    //more instantaneous brainwave. So since there needs to be at least 1 packet per 8th note, 2 per quarter, 3 per half and 4 per whole note. 
    
     measure1FirstSample = measure1FirstSample + firstValue;
     packetCount++;
     
     if(packetCount == 3){ 
       currentNote = measure1FirstSample/3;
       firstChunk = true;
     }
     
     if(firstChunk){
     sequenceCount = 0;
     for(int i=0; i<8; i=i++){ //fill the note sequence with 0's.
     noteSequence[i] = 0;
     }
     
     if((currentNote >= 0) && (currentNote < 20)){
       noteLength = 1; //whole note
       beatsLeft = 0;
       noteSequence[sequenceCount] = 1;
       sequenceCount++;
     }
     
     if((currentNote >= 20) && (currentNote < 40)){
       noteLength = 2; //half note
       beatsLeft = 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
     
     if((currentNote >= 40) && (currentNote < 60)){
       noteLength = 4; //quarter note
       beatsLeft = 3;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((currentNote >= 60) && (currentNote < 80)){
       noteLength = 8; //8th note
       beatsLeft = 3.5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
   currentNote = 0;
 }
 
    if(packetCount > 4){ //now we're done with the first note, let's figure out the others
     
     //no matter what, a whole note won't fit.
     
     //at the moment, all of these values are only using the instantaneous output from the
     //force trainer. Eventually, make them averages over the largest possible data set given the time
     //constraint.
     
    if(beatsLeft == .5){
      noteLength = 8;
      beatsLeft = beatsLeft - .5;
      noteSequence[sequenceCount] = 1;
       sequenceCount++;
    }
    
    if((beatsLeft == 1) || (beatsLeft == 1.5)){
      if((firstSample >=0) && (firstSample <=40)){
        noteLength = 4;
        beatsLeft = beatsLeft - 1;
        noteSequence[sequenceCount] = 4;
       sequenceCount++;
      }
      if((firstSample > 40) && (firstSample <=80)){
        noteLength = 8;
        beatsLeft = beatsLeft - .5;
        noteSequence[sequenceCount] = 8;
       sequenceCount++;
      }
    }
    
    if((beatsLeft < 4) && (beatsLeft > 1.5)){
     if((firstSample >= 0) && (firstSample < 26)){
       noteLength = 8; 
       beatsLeft  = beatsLeft - .5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
     if((firstSample >= 27) && (firstSample < 52)){
       noteLength = 4; 
       beatsLeft = beatsLeft - 1;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((firstSample >= 53) && (firstSample < 78 )){
       noteLength = 2; 
       beatsLeft = beatsLeft - 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
    }
   currentNote = 0;
 }
     
     
       
    
    //Next, we figure out what the note actually is. This is done by looking at the number of notes there are going to be in this measure and then 
    //generating their pitch. We can do this by dividing the number of notes to be played by the number of samples we get in and taking an average over the result.
    //So if there were going to be 4 notes in a particular measure and I know that in the amount of time it takes to play a measure the Force Trainer will
    //send over about 10 values, then 10/4 = 2.5, so take an average over every 2 samples to get the numbers for figuring out pitch.
    
    //now seperate each note and get the pitch for it, then store it in an array to be decoded and played back next. 
    
   //in the pitch array, 1=C, 2 = B flat, 3 = E flat, 4 = high C, 5 = G
    
  if(beatsLeft == 0){
      numberNotes = 0;
    for(int j=0; j<pitchSequence.length; j++){
      if(pitchSequence[j] == 0){
         pitchSequence[j] = 0;
        } else{
       
      numberNotes++;
       
       if((secondSample >= 0) && (secondSample <=20)){
         pitchSequence[j] = 1; //play a C
       }
       if((secondSample >20) && (secondSample <= 40)){
         pitchSequence[j] = 2; //play a B flat
       }
       if((secondSample >40) && (secondSample <=60)){
         pitchSequence[j] = 3;// play an E flat
       }
       if((secondSample >60) && (secondSample <=80)){
         pitchSequence[j] = 4; //play a high C
       }
       if((secondSample >80) && (secondSample <=100)){
         pitchSequence[j] = 5; //play a G
       }  
      }
        
      }
    } 
    
    //Finally, play the note sequence we just generated.
    
     //first let's make sure that there weren't any errors up to this point encoding the notes. the noteSequence and pitchSequence arrays should be the same length  
    if((noteSequence.length) != (pitchSequence.length)){
      println("Oh no! The pitch and length arrays aren't the same size. Halp.");
    }
    
    for(int k=0; k<noteSequence.length; k++){ //traverse through the pitch and length arrays, decode the correct note sequence, then play it.
    //first we'll narrow down by length and then by pitch
    //possible values in the noteSequence are 1,2,4, and 8
    if((noteSequence[k]) == 1){
      //so it's a whole note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 2){
      //got a half note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 4){
      //Quarter note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 8){
      //8th note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
    }
   }
    
    
    
         

    
    
    
    
    
    
    //now do that whole thing all over again for each chord change!
    
   if((progression.position() > 3600) && (progression.position() <= 7800 )){
    println("possible notes are everything in a c minor augmented scale");
    possibleNotes = 2;
    
     measure1FirstSample = measure1FirstSample + firstValue;
     packetCount++;
     
     if(packetCount == 3){ 
       currentNote = measure1FirstSample/3;
       firstChunk = true;
     }
     
     if(firstChunk){
     sequenceCount = 0;
     for(int i=0; i<8; i=i++){ //fill the note sequence with 0's.
     noteSequence[i] = 0;
     }
     
     if((currentNote >= 0) && (currentNote < 20)){
       noteLength = 1; //whole note
       beatsLeft = 0;
       noteSequence[sequenceCount] = 1;
       sequenceCount++;
     }
     
     if((currentNote >= 20) && (currentNote < 40)){
       noteLength = 2; //half note
       beatsLeft = 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
     
     if((currentNote >= 40) && (currentNote < 60)){
       noteLength = 4; //quarter note
       beatsLeft = 3;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((currentNote >= 60) && (currentNote < 80)){
       noteLength = 8; //8th note
       beatsLeft = 3.5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
   currentNote = 0;
 }
 
    if(packetCount > 4){ 
     
    if(beatsLeft == .5){
      noteLength = 8;
      beatsLeft = beatsLeft - .5;
      noteSequence[sequenceCount] = 1;
       sequenceCount++;
    }
    
    if((beatsLeft == 1) || (beatsLeft == 1.5)){
      if((firstSample >=0) && (firstSample <=40)){
        noteLength = 4;
        beatsLeft = beatsLeft - 1;
        noteSequence[sequenceCount] = 4;
       sequenceCount++;
      }
      if((firstSample > 40) && (firstSample <=80)){
        noteLength = 8;
        beatsLeft = beatsLeft - .5;
        noteSequence[sequenceCount] = 8;
       sequenceCount++;
      }
    }
    
    if((beatsLeft < 4) && (beatsLeft > 1.5)){
     if((firstSample >= 0) && (firstSample < 26)){
       noteLength = 8; 
       beatsLeft  = beatsLeft - .5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
     if((firstSample >= 27) && (firstSample < 52)){
       noteLength = 4; 
       beatsLeft = beatsLeft - 1;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((firstSample >= 53) && (firstSample < 78 )){
       noteLength = 2; 
       beatsLeft = beatsLeft - 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
    }
   currentNote = 0;
 }
     
    
   //in the pitch array, 1=C, 2 = A flat, 3 = F sharp, 4 = E flat, 5 = C
    
  if(beatsLeft == 0){
      numberNotes = 0;
    for(int j=0; j<=8; j++){
      if(pitchSequence[j] != 0){
        numberNotes++;
       
       if((secondSample >= 0) && (secondSample <=20)){
         pitchSequence[j] = 1; //play a C
       }
       if((secondSample >20) && (secondSample <= 40)){
         pitchSequence[j] = 2; //play an A flat
       }
       if((secondSample >40) && (secondSample <=60)){
         pitchSequence[j] = 3;// play an F shart
       }
       if((secondSample >60) && (secondSample <=80)){
         pitchSequence[j] = 4; //play an E flat
       }
       if((secondSample >80) && (secondSample <=100)){
         pitchSequence[j] = 5; //play a C
       }
        } else{
        pitchSequence[j] = 0;
        }
        
      }
    } 
    
    
    if((noteSequence.length) != (pitchSequence.length)){
      println("Oh no! The pitch and length arrays aren't the same size. Halp.");
    }
    
    for(int k=0; k<=noteSequence.length; k++){ //traverse through the pitch and length arrays, decode the correct note sequence, then play it.
    //first we'll narrow down by length and then by pitch
    //possible values in the noteSequence are 1,2,4, and 8
    if(noteSequence[k] == 1){
      //so it's a whole note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play an A flat
         playnow=a24;
         a24.play();
       }
       if(pitchSequence[k] == 3){
         //play an F sharp
         playnow = a43;
         a43.play();
       }
       if(pitchSequence[k] == 4){
         //play an e flat
         playnow= a52;
         a52.play();
       }
       if(pitchSequence[k] == 5){
         //play a C
         playnow= a18;
         a18.play();
       }
    }
     if(noteSequence[k] == 2){
      //got a half note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
      if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play an A flat
         playnow=a24;
         a24.play();
       }
       if(pitchSequence[k] == 3){
         //play an F sharp
         playnow = a43;
         a43.play();
       }
       if(pitchSequence[k] == 4){
         //play an e flat
         playnow= a52;
         a52.play();
       }
       if(pitchSequence[k] == 5){
         //play a C
         playnow= a18;
         a18.play();
       }
    }
     if(noteSequence[k] == 4){
      //Quarter note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
      if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play an A flat
         playnow=a24;
         a24.play();
       }
       if(pitchSequence[k] == 3){
         //play an F sharp
         playnow = a43;
         a43.play();
       }
       if(pitchSequence[k] == 4){
         //play an e flat
         playnow= a52;
         a52.play();
       }
       if(pitchSequence[k] == 5){
         //play a C
         playnow= a18;
         a18.play();
       }
    }
     if(noteSequence[k] == 8){
      //8th note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
      if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play an A flat
         playnow=a24;
         a24.play();
       }
       if(pitchSequence[k] == 3){
         //play an F sharp
         playnow = a43;
         a43.play();
       }
       if(pitchSequence[k] == 4){
         //play an e flat
         playnow= a52;
         a52.play();
       }
       if(pitchSequence[k] == 5){
         //play a C
         playnow= a18;
         a18.play();
       }
    }
    }
    
    

   }  
      
   if((progression.position() > 7800) && (progression.position() <= 12000 )){
    println("possible notes are everything in a c minor scale");
    possibleNotes = 3;

     measure1FirstSample = measure1FirstSample + firstValue;
     packetCount++;
     
     if(packetCount == 3){ 
       currentNote = measure1FirstSample/3;
       firstChunk = true;
     }
     
     if(firstChunk){
     sequenceCount = 0;
     for(int i=0; i<8; i=i++){ //fill the note sequence with 0's.
     noteSequence[i] = 0;
     }
     
     if((currentNote >= 0) && (currentNote < 20)){
       noteLength = 1; //whole note
       beatsLeft = 0;
       noteSequence[sequenceCount] = 1;
       sequenceCount++;
     }
     
     if((currentNote >= 20) && (currentNote < 40)){
       noteLength = 2; //half note
       beatsLeft = 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
     
     if((currentNote >= 40) && (currentNote < 60)){
       noteLength = 4; //quarter note
       beatsLeft = 3;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((currentNote >= 60) && (currentNote < 80)){
       noteLength = 8; //8th note
       beatsLeft = 3.5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
   currentNote = 0;
 }
 
    if(packetCount > 4){ 
     
    if(beatsLeft == .5){
      noteLength = 8;
      beatsLeft = beatsLeft - .5;
      noteSequence[sequenceCount] = 1;
       sequenceCount++;
    }
    
    if((beatsLeft == 1) || (beatsLeft == 1.5)){
      if((firstSample >=0) && (firstSample <=40)){
        noteLength = 4;
        beatsLeft = beatsLeft - 1;
        noteSequence[sequenceCount] = 4;
       sequenceCount++;
      }
      if((firstSample > 40) && (firstSample <=80)){
        noteLength = 8;
        beatsLeft = beatsLeft - .5;
        noteSequence[sequenceCount] = 8;
       sequenceCount++;
      }
    }
    
    if((beatsLeft < 4) && (beatsLeft > 1.5)){
     if((firstSample >= 0) && (firstSample < 26)){
       noteLength = 8; 
       beatsLeft  = beatsLeft - .5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
     if((firstSample >= 27) && (firstSample < 52)){
       noteLength = 4; 
       beatsLeft = beatsLeft - 1;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((firstSample >= 53) && (firstSample < 78 )){
       noteLength = 2; 
       beatsLeft = beatsLeft - 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
    }
   currentNote = 0;
 }
     
    
   //in the pitch array, 1=C, 2 = B flat, 3 = E flat, 4 = high C, 5 = G
    
  if(beatsLeft == 0){
      numberNotes = 0;
    for(int j=0; j<=8; j++){
      if(pitchSequence[j] != 0){
        numberNotes++;
       
       if((secondSample >= 0) && (secondSample <=20)){
         pitchSequence[j] = 1; //play a C
       }
       if((secondSample >20) && (secondSample <= 40)){
         pitchSequence[j] = 2; //play a B flat
       }
       if((secondSample >40) && (secondSample <=60)){
         pitchSequence[j] = 3;// play an E flat
       }
       if((secondSample >60) && (secondSample <=80)){
         pitchSequence[j] = 4; //play a high C
       }
       if((secondSample >80) && (secondSample <=100)){
         pitchSequence[j] = 5; //play a G
       }
        } else{
        pitchSequence[j] = 0;
        }
        
      }
    } 
    
    //Finally, play the note sequence we just generated.
    
     //first let's make sure that there weren't any errors up to this point encoding the notes. the noteSequence and pitchSequence arrays should be the same length  
    if((noteSequence.length) != (pitchSequence.length)){
      println("Oh no! The pitch and length arrays aren't the same size. Halp.");
    }
    
    for(int k=0; k<=noteSequence.length; k++){ //traverse through the pitch and length arrays, decode the correct note sequence, then play it.
    //first we'll narrow down by length and then by pitch
    //possible values in the noteSequence are 1,2,4, and 8
    if(noteSequence[k] == 1){
      //so it's a whole note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 2){
      //got a half note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 4){
      //Quarter note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
     if(noteSequence[k] == 8){
      //8th note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 2){
         //play a B flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 3){
         //play an E flat
         playnow = a52;
         a52.play();
       }
       if(pitchSequence[k] == 4){
         //play a high c
         playnow= a18;
         a18.play();
       }
       if(pitchSequence[k] == 5){
         //play a G
         playnow= a33;
         a33.play();
       }
    }
    }

   }    
   
   if((progression.position() > 12000) && (progression.position() <= 16161 )){
    println("possible notes are everything in a b flat major scale");
    possibleNotes = 4;
    //beginning of paste
      measure1FirstSample = measure1FirstSample + firstValue;
     packetCount++;
     
     if(packetCount == 3){ 
       currentNote = measure1FirstSample/3;
       firstChunk = true;
     }
     
     if(firstChunk){
     sequenceCount = 0;
     for(int i=0; i<8; i=i++){ //fill the note sequence with 0's.
     noteSequence[i] = 0;
     }
     
     if((currentNote >= 0) && (currentNote < 20)){
       noteLength = 1; //whole note
       beatsLeft = 0;
       noteSequence[sequenceCount] = 1;
       sequenceCount++;
     }
     
     if((currentNote >= 20) && (currentNote < 40)){
       noteLength = 2; //half note
       beatsLeft = 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
     
     if((currentNote >= 40) && (currentNote < 60)){
       noteLength = 4; //quarter note
       beatsLeft = 3;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((currentNote >= 60) && (currentNote < 80)){
       noteLength = 8; //8th note
       beatsLeft = 3.5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
   currentNote = 0;
 }
 
    if(packetCount > 4){ 
     
    if(beatsLeft == .5){
      noteLength = 8;
      beatsLeft = beatsLeft - .5;
      noteSequence[sequenceCount] = 1;
       sequenceCount++;
    }
    
    if((beatsLeft == 1) || (beatsLeft == 1.5)){
      if((firstSample >=0) && (firstSample <=40)){
        noteLength = 4;
        beatsLeft = beatsLeft - 1;
        noteSequence[sequenceCount] = 4;
       sequenceCount++;
      }
      if((firstSample > 40) && (firstSample <=80)){
        noteLength = 8;
        beatsLeft = beatsLeft - .5;
        noteSequence[sequenceCount] = 8;
       sequenceCount++;
      }
    }
    
    if((beatsLeft < 4) && (beatsLeft > 1.5)){
     if((firstSample >= 0) && (firstSample < 26)){
       noteLength = 8; 
       beatsLeft  = beatsLeft - .5;
       noteSequence[sequenceCount] = 8;
       sequenceCount++;
     }
     if((firstSample >= 27) && (firstSample < 52)){
       noteLength = 4; 
       beatsLeft = beatsLeft - 1;
       noteSequence[sequenceCount] = 4;
       sequenceCount++;
     }
     
     if((firstSample >= 53) && (firstSample < 78 )){
       noteLength = 2; 
       beatsLeft = beatsLeft - 2;
       noteSequence[sequenceCount] = 2;
       sequenceCount++;
     }
    }
   currentNote = 0;
 }
     
    
   //in the pitch array, 1=b flat, 2 = C, 3 = D, 4 = F, 5 = E flat
    
  if(beatsLeft == 0){
      numberNotes = 0;
    for(int j=0; j<=8; j++){
      if(pitchSequence[j] != 0){
        numberNotes++;
       
       if((secondSample >= 0) && (secondSample <=20)){
         pitchSequence[j] = 1; //play a b flat
       }
       if((secondSample >20) && (secondSample <= 40)){
         pitchSequence[j] = 2; //play an C
       }
       if((secondSample >40) && (secondSample <=60)){
         pitchSequence[j] = 3;// play an D
       }
       if((secondSample >60) && (secondSample <=80)){
         pitchSequence[j] = 4; //play an F
       }
       if((secondSample >80) && (secondSample <=100)){
         pitchSequence[j] = 5; //play a E flat
       }
        } else{
        pitchSequence[j] = 0;
        }
        
      }
    } 
    
    
    if((noteSequence.length) != (pitchSequence.length)){
      println("Oh no! The pitch and length arrays aren't the same size. Halp.");
    }
    
    for(int k=0; k<=noteSequence.length; k++){ //traverse through the pitch and length arrays, decode the correct note sequence, then play it.
    //first we'll narrow down by length and then by pitch
    //possible values in the noteSequence are 1,2,4, and 8
    if(noteSequence[k] == 1){
      //so it's a whole note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a b flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 2){
         //play an C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 3){
         //play an d
         playnow = a57;
         a57.play();
       }
       if(pitchSequence[k] == 4){
         //play an f
         playnow= a47;
         a47.play();
       }
       if(pitchSequence[k] == 5){
         //play an e flat
         playnow= a52;
         a52.play();
       }
    }
     if(noteSequence[k] == 2){
      //got a half note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a b flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 2){
         //play an C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 3){
         //play an d
         playnow = a57;
         a57.play();
       }
       if(pitchSequence[k] == 4){
         //play an f
         playnow= a47;
         a47.play();
       }
       if(pitchSequence[k] == 5){
         //play an e flat
         playnow= a52;
         a52.play();
       }
    }
     if(noteSequence[k] == 4){
      //Quarter note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
   if(pitchSequence[k] == 1){
         //play a b flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 2){
         //play an C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 3){
         //play an d
         playnow = a57;
         a57.play();
       }
       if(pitchSequence[k] == 4){
         //play an f
         playnow= a47;
         a47.play();
       }
       if(pitchSequence[k] == 5){
         //play an e flat
         playnow= a52;
         a52.play();
       }
    }
     if(noteSequence[k] == 8){
      //8th note. Now decode pitch.
      //possible pitch values are 1,2,3,4,5
       if(pitchSequence[k] == 1){
         //play a b flat
         playnow=a67;
         a67.play();
       }
       if(pitchSequence[k] == 2){
         //play an C
         playnow=a65;
         a65.play();
       }
       if(pitchSequence[k] == 3){
         //play an d
         playnow = a57;
         a57.play();
       }
       if(pitchSequence[k] == 4){
         //play an f
         playnow= a47;
         a47.play();
       }
       if(pitchSequence[k] == 5){
         //play an e flat
         playnow= a52;
         a52.play();
       }
    }
    }
    
    //end of paste
    
   }    
      
      firstSample = firstSample + firstValue;
      secondSample = secondSample + secondValue;
     counter++;
     //now we have been accumulating some values of the sensor. If we have enough for a nice sample,
     //then jump into another if statement to decide what to play.
      



    } else {
      buf[bufPos++] = (byte)ch;
    }
   }   
}


 void stop(){

   progression.close();
   chord1.close();
   chord2.close();
   chord3.close();
   chord4.close();
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
 
