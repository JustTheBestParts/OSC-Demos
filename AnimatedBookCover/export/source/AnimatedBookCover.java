import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AnimatedBookCover extends PApplet {





int animationLoop  = 1;
int ANIMATE_ON_COUNT = 3;

int animationCounter = 0;
int maxAnimationLoop = 5;

HashMap sceneTable = new HashMap();
// HashMap mainCharacterScenes = new HashMap();

String mainSceneName = "osc-for-artists";

AnimataP5 mainScene;

// Adding this, and having it return true, makes your sketch fullscree, no window borders.
// It's set to false for demo purposes
public boolean sketchFullScreen() {
//  return true;
  return false;
}


//-----------------------------------------------------------
public void setup() {
  size(508, 738, OPENGL);
  loadScene(mainSceneName);
  mainScene = (AnimataP5) sceneTable.get(mainSceneName);
  loadData();
  setupOsc();
}

//-----------------------------------------------------------
public void draw() {
  background(255);
  mainScene.draw(0,0);
}
// These methods should be handling OSC requests.
// The main OSC code (where oscEvent is defined) 
// figures out what to do and with what data and routes it off to
// methods here.
//
// This code assumes that all AnimataP5 instances are stored in a HashMap
// and keyed by scene name; the scene name is Animata nmt file minus the
// extension (".nmt") part.
//  
//  


public void moveLayerJoint(String sceneName, String layerName, String jointName, float x, float y) {
  // println("moveLayerJoint: " + jointName + ", to  " + x + ", " + y );
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  ap5.moveJointOnLayer(jointName, layerName, x, y); 
}

public void moveJoint(String sceneName,  String jointName, float x, float y) {
  // println("moveJoint: " + jointName + ", to  " + x + ", " + y );
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  ap5.moveJoint(jointName, x, y); 
}

public void setTextureImage(String sceneName,  String layerName, String imageName) {
  // println("setTextureImage: " + imageName  + " for " + layerName );
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  ap5.setNewMeshImage( imageName,  layerName); 
}

public void setTexturePImage(String sceneName,  String layerName, PImage image) {
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  ap5.setNewMeshImage( image,  layerName); 
}

/* 
   Ideally, the code or the OSC message wold not need to know too much. OTOH, the OSC now needs to know
   the scene name.  So, some options:

   /animata/<scene-name>/orientation <right, left, forward>

BUT: We are using different scenes for different directions.  Or, more broadly, we are
allow this AP5 app to toggle active character stuff, so it is not really about direction
but about what scene should be assigned to the main character variable.

Where does this logic live?  In the Leap controller? What sort of API should it
expect? Not every program is going to have a notion of `main character`, and even this
app might have several characters that need swapping.

What might be nice is to have yet another sort of scene-struct thing, where you can define  a meta-scene
as a collection of scenes, only one begin active at a time.  So the OSC directs messages to a meta-scene,
and may tell it some detail (`../orientation/left`), and the meta-scene itself then decides how to
handle that (perhaps by swapping out the the active sub-scene).

For now we can just hack it and have the OSC decide to send main character orientation messages.

 */


// Assumes the given scene name is the base part of the nmt file with the project XML
// e.g. "foo" => "foo.nmt"
//
public void loadScene(String sceneName ) {  
  AnimataP5 ap5 = new AnimataP5(this, sceneName + ".nmt");
  ap5.renderPriority(sceneTable.size());
  // println("\tLoad scene: '" +  sceneName + "'");
  sceneTable.put(sceneName, ap5);
}


//    Moving a layer, x and y are the position coordinates as float values:	/layerpos name x y
public void moveLayerAbsolute(String sceneName, String layerName, float x, float y) {
  // println("moveLayerAbsolute " + sceneName + "::" + layerName + " to  " + x + ", " + y);  
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  // println("Have ap5 = " + ap5);
  Layer l = ap5.getLayer(layerName);
  l.setPosition(x, y);

}

public void moveLayerRelative(String sceneName, String layerName, float x, float y) {
  // println("moveLayerRelative " + sceneName + "::" + layerName + " to  " + x + ", " + y);  
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  // println("Have ap5 = " + ap5);
  Layer l = ap5.getLayer(layerName);
  l.setPosition(l.x() + x, l.y() + y);
}

public void setLayerAlpha(String sceneName, String layerName, float value) {
  println("setLayerAlpha " + layerName + " :  " + value);

  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  println("Have ap5 = " + ap5);

  Layer l = ap5.getLayer(layerName);
  println("Have layer = " + l );
  // P5 tint uses a int from 0 to 255, so we need to map this
  // HOWEVER: If AP5 is just reading in the XML and uses the alpha value there, then
  // it has to account for the mapping. So if we are using this to set the object propery 
  // we should assume that AP5 is convert the float percentage to 0-255
  // l.setLayerAlpha(layerName, map(value, 0,1, 0,255) );
  l.setLayerAlpha(layerName, value );

}

public void setLayerScale(String sceneName, String layerName, float value) {
  // println("setLayerScale " + layerName + " :  " + value);
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  Layer l = ap5.getLayer(layerName);
  // P5 tint uses a int from 0 to 255, so we need to map this
  // HOWEVER: If AP5 is just reading in the XML and uses the sclae value there, then
  // it has to account for the mapping. So if we are using this to set the object propery 
  // we should assume that AP5 is convert the float percentage to 0-255
  // l.setLayerAlpha(layerName, map(value, 0,1, 0,255) );
  l.setLayerScale(layerName, value );

}


public void setLayerVisibility(String sceneName, String layerName, int state) {
  // println("setLayerVisibility " + layerName + " :  " + state);
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  Layer l = ap5.getLayer(layerName);
  l.setVisibility(state == 1);
}


//  Control the length of a bone, value is a float between 0 and 2:	 /anibone name value
public void setBoneLength(String sceneName, String boneName, float length){
  // println("setBoneLength " + boneName + " :  " + length);
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  Bone b = ap5.getBone(boneName);
  b.setSize(length);
}



//  Control the length of a bone, value is a float between 0 and 2:	 /anibone name value
public void setBoneScale(String sceneName, String boneName, float scale){
  // println("setBoneScale " + boneName + " :  " + scale);
  AnimataP5 ap5 = (AnimataP5) sceneTable.get(sceneName);
  Bone b = ap5.getBone(boneName);
  b.setScale(scale);
}




OscP5 oscP5;

String configFile = "config.txt";

String clientOSCAddress = "0.0.0.0";
String localOSCAddress  = "0.0.0.0";

int clientOSCPort    = 9000;
int localOSCPort     = 8000;

//-----------------------------------------------------------
public void setupOsc()  {
  loadData();
  oscP5 = new OscP5(this, localOSCAddress, localOSCPort);

  println(" Using OSC config values:");
  println(" localOSCAddress:\t" + localOSCAddress);
  println(" localOSCPort:\t" + localOSCPort);
}


//-----------------------------------------------------------
public void loadData(){
  println("***************************** DEBUGGERY: load data ... ******************************"); // DEBUG

  String defaultValues[] = split("127.0.0.1\n127.0.0.1\n8081\n8001", "\n");

  try {
    String lines[] = loadStrings(configFile);

    for (int i=0; i < lines.length; i++) {
      defaultValues[i] =  lines[i]; 
    }
  } catch(Exception e) {
    println("Error loading data from '" + configFile + "'");
    e.printStackTrace();
  }

  int i = 0;

  clientOSCAddress = trim(defaultValues[i]);          i++;
  localOSCAddress  = trim(defaultValues[i]);          i++;
  clientOSCPort    = PApplet.parseInt(trim(defaultValues[i]));     i++;
  localOSCPort     = PApplet.parseInt(trim(defaultValues[i]));     i++;

}


//-----------------------------------------------------------
public void oscEvent(OscMessage oscMsg) {

  /* print the address pattern and the typetag of the received OscMessage */

  print("\t\t\t### received an osc message.");
  print(" addrpattern: "+oscMsg.addrPattern());
  println(" typetag: "+oscMsg.typetag());
  //  println(" arguments: "+oscMsg.arguments()[0].toString());


  //  Assume this:
  //      /animata/<sceneName>/[itemType]/<itemName>/[actionOrQuery] (args ...)


  int realm     = 1;
  int sceneName = 2;
  int itemType  = 3;
  int itemID    = 4;

  String[] parts = split(oscMsg.addrPattern(), "/");
  // println("parts[realm]: '" + parts[realm]  + "'" );

  String[] res;

  // Done mostly to suggest a way to process messages meant for different aspects of the sketch
  String reAnimata = "animata";
  String reSketch = "sketch";

  println(oscMsg.addrPattern());

  if (parts[realm].equals(reAnimata) ) {
    println("Animata message. Scene name " + parts[sceneName] + "parts[itemType] = '" + parts[itemType] + "'" );

    //  If we got this:   /animata/<sceneName>/layer/<layer-name>/<some actioj or query>
    if (parts[itemType].equals("layer") ) {
      println("Act on layer '" + parts[itemID] + "'" );
      handleLayerAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
    }

    if (parts[itemType].equals("joint") ) {
      println("Act on joint '" + parts[itemID] + "'" );
      handleJointAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
    }

    if (parts[itemType].equals("bone") ) {
      println("@  @ @ @ A ct on bone '" + parts[itemID] + "'" );
      handleBoneAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
    }
  
    if (parts[itemType].equals("load") ) {
      println("Load scene '" + parts[sceneName] + "'" );
      loadScene( parts[sceneName] );
    }

  } 

}


// How much do we want to assume?  We need the scene and layer name.
// That probably is in the message address.  But if we change how that is ordered
// then code that exepctec it would break.
// Ideally we apps just the needed data as generially as possible.
public void handleLayerAction(String sceneName, String layerName, String[] messageTail, Object[] args ) {
  println("**** handleLayerAction for '" +  sceneName + "', layer '" + layerName + "'" );

   String action = messageTail[0];
 
  println("\taction  = " + action  );
  if (action.equals("move") ) {
    Float x = parseFloat( (args[0]).toString() );
    Float y = parseFloat( (args[1]).toString() );
    moveLayerAbsolute(sceneName, layerName, x, y);              
  }

  if (action.equals("alpha") ) {
    println("---- alpha message ");
    Float f = parseFloat( (args[0]).toString() );
    setLayerAlpha(sceneName, layerName, f);
  }


  if (action.equals("scale") ) {
    Float f = parseFloat( (args[0]).toString() );
    setLayerScale(sceneName, layerName, f);
  }


  if (action.equals("visibilty") ) {
    int i = parseInt( (args[0]).toString() );
    setLayerVisibility(sceneName, layerName, i);
  }

  if (action.equals("image") ) {
    String imageName = args[0].toString();
    setTextureImage(sceneName, layerName, imageName);
  }

  //     Float y = parseFloat( (args[1]).toString() );

  //   println("new location: " + x + ", " + y);
  // moveLayerJoint(parts[layer], parts[joint],   x, y);
}

public void handleJointAction(String sceneName, String jointName, String[] messageTail, Object[] args ) {
  println("**** handleJointAction for '" +  sceneName + "', jointName '" + jointName + "'" );

  String action = messageTail[0];

  println("action  = " + action  );
  if (action.equals("move") ) {
    Float x = parseFloat( (args[0]).toString() );
    Float y = parseFloat( (args[1]).toString() );
    moveJoint(sceneName, jointName, x, y);              
  }


}

public void handleBoneAction(String sceneName, String boneName, String[] messageTail, Object[] args ) {
  println("* * *   handleBoneAction for '" +  sceneName + "', boneName '" + boneName + "' * * * * * " );

  String action = messageTail[0];

  println("handleBoneAction action  = '" + action  + "'" );

  if (action.equals("scale") ) {
    Float scale = parseFloat( (args[0]).toString() );
    println("Call setBoneScale .... ");
    setBoneScale(sceneName, boneName, scale);
  } else if (action.equals("length") ) {
    Float length = parseFloat( (args[0]).toString() );
    println("Call setBoneLength .... ");
    setBoneLength(sceneName, boneName, length);
  } else {

    println("Have no handler for action " + action );
}

  println("End of handleBoneAction ");

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AnimatedBookCover" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
