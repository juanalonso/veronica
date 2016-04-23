import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer barbiephonic;
FFT fft;

public enum States {
  WAITING_FOR_DELAY, 
    PLAYING_WAV, 
    WAITING_FOR_UTTERANCE,
}

//Face parameters
final int eyeRadiusX = 180;
final int eyeRadiusY = 140;
final int eyeXPos = 260;
final int eyeYPos = 400;
final int mouthXPos = 225;
final int mouthYPos = 650;

//Animation parameters
final float fMemory = 0.3;

//Folder parameters
final int numFolders = 10;
final int filesPerFolder = 1588;

//Finite-state machine parameters
int delayBetweenNames = 50000; //in ms
int delayBetweenUtterances = 1250; //in ms
int numRepetitions = 3;

float currFFTMax = 0;
float FFTMax;
float noiseOffset = 0.0;

int currRepetition;
States currState = States.WAITING_FOR_DELAY;
int startTime = millis();

void setup() {

  minim = new Minim(this);
  fft = new FFT(1024, 22050);

  size(800, 900); 
  background(0);
  strokeJoin(ROUND);
  rectMode(CORNERS);

}

void draw() {

  //Finite-state machine
  switch(currState) {
  case WAITING_FOR_DELAY:
    if (startTime + delayBetweenNames < millis()) {
      String randomName = (int)random(numFolders) + "/barbie_"+nf((int)random(filesPerFolder), 5)+".wav";
      barbiephonic = minim.loadFile(randomName, 1024);
      currState = States.PLAYING_WAV;
      currRepetition = 0;
      barbiephonic.play();
    }
    break;
  case PLAYING_WAV:
    if (barbiephonic.isPlaying()) {
      fft.forward(barbiephonic.mix);
      int iFreq = 220;
      FFTMax = 0;  
      for (int i = 0; i<5; i++) {
        FFTMax += fft.calcAvg(iFreq, iFreq<<1);
        iFreq <<= 1;
      }
      FFTMax = FFTMax * 11;
      currFFTMax = currFFTMax * fMemory + FFTMax * (1 - fMemory);
    } else {
      currRepetition++;
      if (currRepetition<numRepetitions) {
        currState = States.WAITING_FOR_UTTERANCE;
      } else {
        currState = States.WAITING_FOR_DELAY;
      }
      currFFTMax = 0;
      startTime = millis();
    }
    break;
  case WAITING_FOR_UTTERANCE:
    if (startTime + delayBetweenUtterances < millis()) {
      currState = States.PLAYING_WAV;
      barbiephonic.rewind();
      barbiephonic.play();
    }
    break;
  }

  //Eye movement
  float pupilaOffsetX = (-eyeRadiusX+noise(noiseOffset)*eyeRadiusX*2)*0.45;
  float pupilaOffsetY = (-eyeRadiusY+noise(2+noiseOffset)*eyeRadiusY*2)*0.45;

  if (currFFTMax > 50) {
    pupilaOffsetX = 0;
  } else if (currFFTMax > 10) {
    pupilaOffsetX *= map (currFFTMax, 10, 50, 1, 0);
  }
  noiseOffset += 0.01;

  //Draw face
  //stroke(200);

  fill(250, 201, 169);
  rect(0,0,width,700); 
  //rect(150,0,width-150,900); 
  //ellipse(150,700,300,300);
  //ellipse(width-150,700,300,300);
  ellipse(width/2,700,800,400);

  //Mouth
  stroke(0);
  strokeWeight(12);
  fill(125, 0, 0);
  rect(mouthXPos+currFFTMax/10, mouthYPos-currFFTMax/7, (width-mouthXPos)-currFFTMax/10, mouthYPos+currFFTMax/7);

  //White part of the eye
  noStroke();
  fill(255);
  ellipse(eyeXPos, eyeYPos, eyeRadiusX, eyeRadiusY);
  ellipse(width-eyeXPos, eyeYPos, eyeRadiusX, eyeRadiusY);

  //Pupils
  fill(0);
  ellipse(eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 50, 50);
  ellipse(width-eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 50, 50);
}

void stop() {

  minim.stop();
  super.stop();
}