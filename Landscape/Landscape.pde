import animata.*;

import animata.model.Skeleton.*;
import animata.model.Layer;

import processing.opengl.*;

import java.util.Iterator;
import java.util.Map;

import java.util.Collections;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Arrays;



int animationLoop    = 1;
int ANIMATE_ON_COUNT = 3;

int animationCounter = 0;
int maxAnimationLoop = 5;

HashMap sceneTable = new HashMap();
HashMap mainCharacterScenes = new HashMap();

String mainSceneName = "Landscape";

AnimataP5 mainScene;

// Adding this, and having it return true, makes your sketch fullscree, no window borders.
// It's set to false for demo purposes
boolean sketchFullScreen() {
  //  return true;
  return false;
}

PImage leftFilter;
PImage rightFilter;

PImage leftFilterTemp;
PImage rightFilterTemp;

int tone1 = 0;
int tone2 = 0;

int minTone1 = 40;
int maxTone1 = 52;

int buildings1X = 0;
int buildings2X  = 0;
int buildingsInc = 2;


int minTone2 = 62;
int maxTone2 = 74;


//-----------------------------------------------------------
void setup() {
  size(1200, 480, OPENGL);
  frameRate(60);
  loadScene(mainSceneName);
  buildings2X  = width;

  mainScene = (AnimataP5) sceneTable.get(mainSceneName);
  loadData();
  setupOsc();

  leftFilter      = loadImage("leftFilter.png");
  leftFilterTemp  = loadImage("leftFilterTest.png");
  rightFilter     = loadImage("rightFilter.png");
  rightFilterTemp = loadImage("rightFilter.png");
}


//-----------------------------------------------------------
void draw() {
  background(0);
  if (tone1 > 0 && tone2 > 0 ) {
    println("\tRENDER LEAD TONES with " + tone1 + ", " + tone2 );
    loadTintedOverlayRight(tone2); 
    loadTintedOverlayLeft(tone1);

    tone1 = 0;
    tone2 = 0;
  }

  shiftBuildings();
  mainScene.draw(0,0);
}

void shiftBuildings() {
  buildings1X -= buildingsInc;
  buildings2X -= buildingsInc;
  
  if (buildings1X < (width *-1) ) {
    buildings1X = width-buildingsInc;
  }

  if (buildings2X < (width *-1) ) {
    buildings2X = width-buildingsInc;
  }


  float x1 = buildings1X * 1.0;
  float x2 = buildings2X * 1.0;

  moveLayerAbsolute(mainSceneName, "buildings1", x1, 0.0);
  moveLayerAbsolute(mainSceneName, "buildings2", x2, 0.0);

  
}

void dynojames(String s) {
  println("   DYNO! ");

}
// Override this in you primary sketch pde file to process
// any OSC messages not already handled in this file
void processWithCustomHandlers(OscMessage oscMsg){

  String addrPattern = (String)oscMsg.addrPattern();

  // print("\t\t\t### received an osc message.");
  //print(" addrpattern: "+oscMsg.addrPattern());
  //println(" typetag: "+oscMsg.typetag());
  //  println(" arguments: "+oscMsg.arguments()[0].toString());

  if (addrPattern.equals("/landscape/renderDualTones") ) {
    renderDualTones(oscMsg.arguments()[0].toString(), oscMsg.arguments()[1].toString() );
  }

}


void loadTintedOverlayLeft(int c) {
  println("loadTintedOverlayLeft("+c+")" );
  leftFilterTemp.copy(leftFilter, 0, 0, leftFilter.width, leftFilter.height, 0, 0, leftFilter.width, leftFilter.height);
  leftFilterTemp =  leftTinter(leftFilter, leftFilterTemp, c);
  println("mainScene.setNewMeshPImage( leftFilterTemp,  'leftFilter'); " );
  mainScene.setNewMeshPImage( leftFilterTemp,  "leftFilter"); 
}


void loadTintedOverlayRight(int c) {
  println("loadTintedOverlayRight("+c+")" );
  rightFilterTemp.copy(rightFilter, 0, 0, rightFilter.width, rightFilter.height, 0, 0, rightFilter.width, rightFilter.height);
  rightFilterTemp =  rightTinter(rightFilter, rightFilterTemp, c);
  println("mainScene.setNewMeshPImage( rightFilterTemp,  'rightFilter'); " );
  mainScene.setNewMeshPImage( rightFilterTemp,  "rightFilter"); 
}



// Can we do something like this for RGB so that 
// a sngle value can be used to calcualate the R,G,B 
// floats needed for a spectrum gradient?
// a low C gives you44
float leftFilterNewR(int c){
  return map(c, minTone1, maxTone1, 0, 255); 
}

float  leftFilterNewB(int c) {
  return map(c, minTone1, maxTone1, 255, 0); 
}


// The right transtion is tricker, to go from a green to .. something.
// 00 ff 00 ->   ff ff 00
// So, seems like you only need to shift the red?
float rightFilterNewR(int c){
  return map(c, minTone2, maxTone2, 0, 255); 
}


// Need some way to encode a tinting value in a single int
// For example, what's the difference between 50 and 72?
// We could assume a range across a spectrum.
// assume a misi note range from 44 to 110
// That's a delta of 66
// if note in the first third, adjust r; second thrid, adjust g, etc.
//
// We assume the alpha color is 255 so do not change that value.
//   
//   Now, there's a lot sad coupling here.  The OSC script and MIDI handlers
//   have hard-code numbers for selecting the lead notes.
//
//   Now this file needs to know those values, and they end up
//   hard-code here.
//
//   Ideally the OSC script would send the note ranges so that
//   if that code chages this code knows to handle it.
//
//   But not right now
PImage leftTinter(PImage img, PImage destImg, int c){

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;

      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);

      if ( r < 255.0 || g < 255.0 || b < 255.0  ) {
        r =  leftFilterNewR(c); 
        g = 0.0; 
        b = leftFilterNewB(c);
      }
      destImg.pixels[loc] =  color(r,g,b);          
    }
  }
  return destImg;
}

// Green stays at 255. Blue stays at 0
PImage rightTinter(PImage img, PImage destImg, int c){

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;

      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);

      if ( r < 255.0 || g < 255.0 || b < 255.0  ) {
        r =  rightFilterNewR(c); 
        g = 255.0; 
        b = 0.0;
      }
      destImg.pixels[loc] =  color(r,g,b);          
    }
  }
  return destImg;
}

