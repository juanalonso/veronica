//110 - 7040Hz

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer barbiephonic;
FFT fft;

float fCurrentMax = -1000;
float fMax;
float fMemory = 0.2;
float noiseOffset = 0.0;

int eyeRadius = 150;
int eyeXPos = 280;
int eyeYPos = 300;

int mouthXPos = 225;
int mouthYPos = 650;

void setup() {

  minim = new Minim(this);
  barbiephonic = minim.loadFile("Barbiephonic - Blarg.wav", 1024);
  barbiephonic.loop();
  
  fft = new FFT(barbiephonic.bufferSize(), barbiephonic.sampleRate());
  fft.window(FFT.HAMMING);

  size(800, 900); 

  stroke(0);
  strokeJoin(ROUND);
  fill(255, 255, 255);
  rectMode(CORNERS);
}

void draw() {

  fft.forward(barbiephonic.mix);

  int iFreq = 220;
  fMax = 0;  

  for (int i = 0; i<5; i++) {
    fMax += fft.calcAvg(iFreq, iFreq<<1);
    iFreq <<= 1;
  }

  fMax = fMax * 11;
  fCurrentMax = fCurrentMax * fMemory + fMax * (1 - fMemory);

  float pupilaOffsetX = -60+noise(noiseOffset)*120.0;
  float pupilaOffsetY = -10+noise(2+noiseOffset)*20.0;

  if (fCurrentMax > 50) {
    pupilaOffsetX = 0;
  } else if (fCurrentMax > 10) {
    pupilaOffsetX *= map (fCurrentMax, 10, 50, 1, 0);
  }


  background(250, 201, 169);  

  strokeWeight(12);
  fill(125, 0, 0);
  rect(mouthXPos+fCurrentMax/10, mouthYPos-fCurrentMax/7, (width-mouthXPos)-fCurrentMax/10, mouthYPos+fCurrentMax/7);

  fill(255);
  ellipse(eyeXPos, eyeYPos, eyeRadius, eyeRadius);
  ellipse(width-eyeXPos, eyeYPos, eyeRadius, eyeRadius);

  strokeWeight(20);
  ellipse(eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 20, 20);
  ellipse(width-eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 20, 20);

  noiseOffset += 0.005;
}

void stop() {

  minim.stop();
  super.stop();
}