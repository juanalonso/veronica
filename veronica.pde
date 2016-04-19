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
final int eyeRadius = 150;
final int eyeXPos = 280;
final int eyeYPos = 300;
final int mouthXPos = 225;
final int mouthYPos = 650;

//Animation parameters
final float fMemory = 0.2;

//Folder parameters
final int numFolders = 10;
final int filesPerFolder = 1588;

//Finite-state machine parameters
int delayBetweenNames = 5000; //in ms
int delayBetweenUtterances = 1500; //in ms
int numRepetitions = 4;

float currFFTMax = 0;
float FFTMax;
float noiseOffset = 0.0;

int currRepetition;
States currState = States.WAITING_FOR_DELAY;
int startTime = millis();

void setup() {

  minim = new Minim(this);
  fft = new FFT(1024, 22050);
  //fft.window(FFT.HAMMING);

  size(800, 900); 
  stroke(0);
  strokeJoin(ROUND);
  fill(255, 255, 255);
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
  float pupilaOffsetX = -60+noise(noiseOffset)*120.0;
  float pupilaOffsetY = -20+noise(2+noiseOffset)*40.0;

  if (currFFTMax > 50) {
    pupilaOffsetX = 0;
  } else if (currFFTMax > 10) {
    pupilaOffsetX *= map (currFFTMax, 10, 50, 1, 0);
  }
  noiseOffset += 0.005;

  //Draw elements
  background(250, 201, 169);  

  strokeWeight(12);
  fill(125, 0, 0);
  rect(mouthXPos+currFFTMax/10, mouthYPos-currFFTMax/7, (width-mouthXPos)-currFFTMax/10, mouthYPos+currFFTMax/7);

  fill(255);
  ellipse(eyeXPos, eyeYPos, eyeRadius, eyeRadius);
  ellipse(width-eyeXPos, eyeYPos, eyeRadius, eyeRadius);

  strokeWeight(20);
  ellipse(eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 20, 20);
  ellipse(width-eyeXPos+pupilaOffsetX, eyeYPos+pupilaOffsetY, 20, 20);
}

void stop() {

  minim.stop();
  super.stop();
}