import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;


FFT fft;

void setup()
{
 size(800, 600, P3D);

 minim = new Minim(this);
 minim.debugOn();

 // get a line in from Minim, default bit depth is 16
 in = minim.getLineIn(Minim.STEREO, 1024);

 fft = new FFT(in.bufferSize(), in.sampleRate());


}

void draw()
{
 background(0);
 stroke(255);

 // draw the waveforms
 pushMatrix();
 translate((width-in.bufferSize()),0);
 for(int i = 0; i < in.bufferSize() -1; i++)
 {
   line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
   line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
 }
 popMatrix();


 // Calculate & draw FFT spectrum

 stroke(255,0,0);
 fft.forward(in.mix);

// println(fft.specSize());
 for(int i = 0; i < width; i++)
 {
   line(i, 450 + fft.getBand(i)*-2, i+1, 450 + fft.getBand(i+1)*-2);

 }

}


void stop()
{
 // always close Minim audio classes when you are done with them
 in.close();
 minim.stop();

 super.stop();
}

