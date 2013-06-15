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

HashMap sceneTable = new HashMap();
HashMap mainCharacterScenes = new HashMap();

String mainCharacterLayer = "main_head";
String baseMainSceneName = "sprite_";

String leftFacingScene = baseMainSceneName + "left";
String rightFacingScene = baseMainSceneName + "right";
String frontFacingScene = baseMainSceneName + "front";

String mainCharacterScene = rightFacingScene;


// Adding this, and having it return true, makes your sketch fullscree, no window borders.
// It's set to false for demo purposes
boolean sketchFullScreen() {
//  return true;
  return false;
}


//-----------------------------------------------------------
void setup() {
float initialScaling = 1.8;
// The displayWidth and displayHeight variables contain the width and 
// height of the screen where the sketch was launched. So to run a 
// sketch that uses the full width and height of the screen, use the following:
// size(displayWidth, displayHeight);
// The size here is set smaller for screencast and demo purposes

  size(displayWidth/2, displayHeight/2, OPENGL);
   println("w x h: " + displayWidth + " x " + displayHeight);
 
  loadScene("scene-backdrop");
  loadScene(leftFacingScene );
  loadScene(rightFacingScene );
  loadScene(frontFacingScene );

  // Sort-of hacky way to adjust some scaling. 
  if (height > 1100 ) {
    setLayerScale("scene-backdrop",  "main_layer", 1.9 ); }
   else {
     initialScaling = displayHeight/630; 
     setLayerScale("scene-backdrop",  "main_layer", 1.6 );
 }

  setLayerScale(leftFacingScene,  mainCharacterLayer, initialScaling );
  setLayerScale(rightFacingScene, mainCharacterLayer, initialScaling );
  setLayerScale(frontFacingScene, mainCharacterLayer, initialScaling );

  setLayerVisibility(leftFacingScene,  mainCharacterLayer, 0);
  setLayerVisibility(rightFacingScene, mainCharacterLayer, 0);
  setLayerVisibility(frontFacingScene, mainCharacterLayer, 0);

  setLayerVisibility(mainCharacterScene, mainCharacterLayer, 1);
 
  loadData();
  setupOsc();

  AnimataP5 main = (AnimataP5) sceneTable.get(leftFacingScene);
  ArrayList sprites = new ArrayList();
  sprites.add(loadImage(baseMainSceneName + "left_000.png"));
  sprites.add(loadImage(baseMainSceneName + "left_001.png"));
  sprites.add(loadImage(baseMainSceneName + "left_002.png"));
  sprites.add(loadImage(baseMainSceneName + "left_003.png"));
  sprites.add(loadImage(baseMainSceneName + "left_004.png"));
  sprites.add(loadImage(baseMainSceneName + "left_005.png"));
  main.setLayerSpriteImages("main_head", sprites, ANIMATE_ON_COUNT);

  main = (AnimataP5) sceneTable.get(rightFacingScene);
  sprites = new ArrayList();
  sprites.add(loadImage(baseMainSceneName + "right_000.png"));
  sprites.add(loadImage(baseMainSceneName + "right_001.png"));
  sprites.add(loadImage(baseMainSceneName + "right_002.png"));
  sprites.add(loadImage(baseMainSceneName + "right_003.png"));
  sprites.add(loadImage(baseMainSceneName + "right_004.png"));
  sprites.add(loadImage(baseMainSceneName + "right_005.png"));
  main.setLayerSpriteImages("main_head", sprites, ANIMATE_ON_COUNT);

  main = (AnimataP5) sceneTable.get(frontFacingScene);
  sprites = new ArrayList();
  sprites.add(loadImage(baseMainSceneName + "front_000.png"));
  sprites.add(loadImage(baseMainSceneName + "front_001.png"));
  sprites.add(loadImage(baseMainSceneName + "front_002.png"));
  sprites.add(loadImage(baseMainSceneName + "front_003.png"));
  sprites.add(loadImage(baseMainSceneName + "front_004.png"));
  sprites.add(loadImage(baseMainSceneName + "front_005.png"));
  main.setLayerSpriteImages("main_head", sprites, ANIMATE_ON_COUNT);

}

//-----------------------------------------------------------
void draw() {
  background(0);
  List<AnimataP5> ap5s = new ArrayList<AnimataP5>();
  AnimataP5 main = (AnimataP5) sceneTable.get(mainCharacterScene);

  Iterator i = sceneTable.entrySet().iterator(); 

  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
    ap5s.add((AnimataP5) me.getValue());
  }

  Collections.sort(ap5s);
  for(AnimataP5 a: ap5s ){
    a.draw(0,0);
  }
}
