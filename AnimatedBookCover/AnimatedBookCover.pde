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


int animationLoop  = 1;
int ANIMATE_ON_COUNT = 3;

int animationCounter = 0;
int maxAnimationLoop = 5;


String mainSceneName = "osc-for-artists";

AnimataP5 mainScene;
AnimataP5Osc ap5osc;
AP5CustomOsc ap5CustomOsc;
SceneManager sceneManager;


/**************************************************************************/
/**************************************************************************/
class SceneManager {

  private PApplet owner;
  private HashMap sceneTable = new HashMap();

  SceneManager(PApplet parent) {
    owner = parent;
  }

  // Assumes the given scene name is the base part of the nmt file with the project XML
  // e.g. "foo" => "foo.nmt"
  //
  void loadScene(String sceneName ) {  
    AnimataP5 ap5 = new AnimataP5(owner, sceneName + ".nmt");
    ap5.renderPriority(sceneTable.size());
    println("\tLoad scene: '" +  sceneName + "'");
    sceneTable.put(sceneName, ap5);
  }

  //-----------------------------------------------------------
  AnimataP5 getScene(String sceneName) {
    return (AnimataP5) sceneTable.get(sceneName);
  }

}



/**************************************************************************/
/**************************************************************************/
class AP5CustomOsc {

  private PApplet owner;
  private SceneManager sceneManager;

  AP5CustomOsc(PApplet pa, SceneManager sm ) {
    owner = pa;
    sceneManager = sm;
  }




  //-----------------------------------------------------------
  void handleOsc(OscMessage oscMsg) {
    println("AP5CustomOsc#handleOsc called for  " + oscMsg.addrPattern() );
  }

}

// Adding this, and having it return true, makes your sketch fullscree, no window borders.
// It's set to false for demo purposes
boolean sketchFullScreen() {
  //  return true;
  return false;
}


//-----------------------------------------------------------
void setup() {
  size(508, 738, OPENGL);
  sceneManager = new  SceneManager(this);
  ap5CustomOsc = new AP5CustomOsc(this,  sceneManager);
  ap5osc = new AnimataP5Osc(this, sceneManager, ap5CustomOsc);

  sceneManager.loadScene(mainSceneName);
  mainScene = sceneManager.getScene(mainSceneName);
  ap5osc.loadData();
  ap5osc.setupOsc();
}

//-----------------------------------------------------------
void draw() {
  background(255);
  mainScene.draw(0,0);
}


