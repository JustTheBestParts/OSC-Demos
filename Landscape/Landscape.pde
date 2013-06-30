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

//-----------------------------------------------------------
void setup() {
  size(1200, 500, OPENGL);
  loadScene(mainSceneName);
  mainScene = (AnimataP5) sceneTable.get(mainSceneName);
  loadData();
  setupOsc();

leftFilter  = loadImage("leftFilter.png");
rightFilter = loadImage("rightFilter.png");
  

}


//-----------------------------------------------------------
void draw() {
  background(0);
  mainScene.draw(0,0);
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


  AnimataP5 ap5 = (AnimataP5) sceneTable.get(mainSceneName);
  ap5.setNewMeshImage( leftFilter,  layerName); 
}




