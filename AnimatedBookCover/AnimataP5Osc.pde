import oscP5.*;
import netP5.*;

OscP5 oscP5;

class AnimataP5Osc {

  private PApplet owner;
  private SceneManager sceneManager; 
  private AP5CustomOsc customOsc;

  private AnimataP5 ap5; 

  String configFile = "config.txt";

  String clientOSCAddress = "0.0.0.0";
  String localOSCAddress  = "0.0.0.0";

  int clientOSCPort    = 9000;
  int localOSCPort     = 8000;


  /*********************************************************************/
  AnimataP5Osc(PApplet ownerApp, SceneManager scnMgr , AP5CustomOsc co) {
    owner = ownerApp;
    sceneManager = scnMgr;
    customOsc = co;
  }

  /*********************************************************************/
  void oscEvent(OscMessage oscMsg) {
    println("OSC message recieved!");
    handleOsc(oscMsg);
    customOsc.handleOsc(oscMsg);
  }


  /*********************************************************************/
  void setupOsc()  {
    loadData();
    oscP5 = new OscP5(this, localOSCAddress, localOSCPort);

    println(" Using OSC config values:");
    println(" localOSCAddress:\t" + localOSCAddress);
    println(" localOSCPort:\t" + localOSCPort);
  }


  /*********************************************************************/
  void loadData(){

    String defaultValues[] = split("127.0.0.1\n127.0.0.1\n8081\n8001", "\n");

    try {
      String lines[] = loadStrings(configFile);
      for (int i=0; i < lines.length; i++) { defaultValues[i] =  lines[i]; }
    } catch(Exception e) {
      println("Error loading data from '" + configFile + "'");
      e.printStackTrace();
    }

    int i = 0;

    clientOSCAddress = trim(defaultValues[i]);          i++;
    localOSCAddress  = trim(defaultValues[i]);          i++;
    clientOSCPort    = int(trim(defaultValues[i]));     i++;
    localOSCPort     = int(trim(defaultValues[i]));     i++;

  }

  /*********************************************************************/
  void moveLayerJoint(String sceneName, String layerName, String jointName, float x, float y) {
    ap5 = sceneManager.getScene(sceneName);
    ap5.moveJointOnLayer(jointName, layerName, x, y); 
  }

  /*********************************************************************/
  void moveJoint(String sceneName,  String jointName, float x, float y) {
    ap5 = sceneManager.getScene(sceneName);
    ap5.moveJoint(jointName, x, y); 
  }

  /*********************************************************************/
  void setTextureImage(String sceneName,  String layerName, String imageName) {
    ap5 = sceneManager.getScene(sceneName);
    ap5.setNewMeshImage( imageName,  layerName); 
  }

  /*********************************************************************/
  void setTexturePImage(String sceneName,  String layerName, PImage image) {
    ap5 = sceneManager.getScene(sceneName);
    ap5.setNewMeshPImage(image,  layerName); 
  }


  /*********************************************************************/
  //    Moving a layer, x and y are the position coordinates as float values:	/layerpos name x y
  void moveLayerAbsolute(String sceneName, String layerName, float x, float y) {
    ap5 = sceneManager.getScene(sceneName);
    Layer l = ap5.getLayer(layerName);
    l.setPosition(x, y);
  }

  /*********************************************************************/
  void moveLayerRelative(String sceneName, String layerName, float x, float y) {
    ap5 = sceneManager.getScene(sceneName);
    Layer l = ap5.getLayer(layerName);
    l.setPosition(l.x() + x, l.y() + y);
  }

  /*********************************************************************/
  void setLayerAlpha(String sceneName, String layerName, float value) {
    ap5 = sceneManager.getScene(sceneName);
    Layer l = ap5.getLayer(layerName);
    l.setLayerAlpha(layerName, value );
  }

  /*********************************************************************/
  void setLayerScale(String sceneName, String layerName, float value) {
    ap5 = sceneManager.getScene(sceneName);
    Layer l = ap5.getLayer(layerName);
    l.setLayerScale(layerName, value );
  }


  /*********************************************************************/
  void setLayerVisibility(String sceneName, String layerName, int state) {
    ap5 = sceneManager.getScene(sceneName);
    Layer l = ap5.getLayer(layerName);
    l.setVisibility(state == 1);
  }

  /*********************************************************************/
  //  Control the length of a bone, value is a float between 0 and 2:	 /anibone name value
  void setBoneLength(String sceneName, String boneName, float length){
    ap5 = sceneManager.getScene(sceneName);
    Bone b = ap5.getBone(boneName);
    b.setSize(length);
  }


  /*********************************************************************/
  //  Control the length of a bone, value is a float between 0 and 2:	 /anibone name value
  void setBoneScale(String sceneName, String boneName, float scale){
    ap5 = sceneManager.getScene(sceneName);
    Bone b = ap5.getBone(boneName);
    b.setScale(scale);
  }

  /*********************************************************************/
  void handleOsc(OscMessage oscMsg) {
    print("\t\t\t### received an osc message.");
    print(" addrpattern: "+oscMsg.addrPattern());
    println(" typetag: "+oscMsg.typetag());
    //  println(" arguments: "+oscMsg.arguments()[0].toString());


    //  Assume this:
    //      /animata/<sceneName>/[itemType]/<itemName>/[actionOrQuery] <arg1,  ...>

    int realm     = 1;
    int sceneName = 2;
    int itemType  = 3;
    int itemID    = 4;

    String[] parts = split(oscMsg.addrPattern(), "/");
    String[] res;
    String reAnimata = "animata";

    println(oscMsg.addrPattern());

    if (parts[realm].equals(reAnimata) ) {
      println("Animata message. Scene name " + parts[sceneName] + "parts[itemType] = '" + parts[itemType] + "'" );

      //  If we got this:   /animata/<sceneName>/layer/<layer-name>/<some actioj or query>
      if (parts[itemType].equals("layer") ) {
        //    println("Act on layer '" + parts[itemID] + "'" );
        handleLayerAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
      }

      if (parts[itemType].equals("joint") ) {
        //   println("Act on joint '" + parts[itemID] + "'" );
        handleJointAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
      }

      if (parts[itemType].equals("bone") ) {
        //  println("@  @ @ @ A ct on bone '" + parts[itemID] + "'" );
        handleBoneAction( parts[sceneName], parts[itemID], subset(parts, itemID+1), oscMsg.arguments() );
      }

      if (parts[itemType].equals("load") ) {
        // println("Load scene '" + parts[sceneName] + "'" );
        sceneManager.loadScene( parts[sceneName] );
      }
    } 
  }



  /*********************************************************************/
  void handleLayerAction(String sceneName, String layerName, String[] messageTail, Object[] args ) {
    //    println("**** handleLayerAction for '" +  sceneName + "', layer '" + layerName + "'" );

    String action = messageTail[0];

    //    println("\taction  = " + action  );
    if (action.equals("move") ) {
      Float x = parseFloat( (args[0]).toString() );
      Float y = parseFloat( (args[1]).toString() );
      moveLayerAbsolute(sceneName, layerName, x, y);              
    }

    if (action.equals("alpha") ) {
      //    println("---- alpha message ");
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

  /*********************************************************************/
  void handleJointAction(String sceneName, String jointName, String[] messageTail, Object[] args ) {
    //    println("**** handleJointAction for '" +  sceneName + "', jointName '" + jointName + "'" );

    String action = messageTail[0];

    //  println("action  = " + action  );
    if (action.equals("move") ) {
      Float x = parseFloat( (args[0]).toString() );
      Float y = parseFloat( (args[1]).toString() );
      moveJoint(sceneName, jointName, x, y);              
    }


  }

  /*********************************************************************/
  void handleBoneAction(String sceneName, String boneName, String[] messageTail, Object[] args ) {
    //    println("* * *   handleBoneAction for '" +  sceneName + "', boneName '" + boneName + "' * * * * * " );

    String action = messageTail[0];

    //  println("handleBoneAction action  = '" + action  + "'" );

    if (action.equals("scale") ) {
      Float scale = parseFloat( (args[0]).toString() );
      println("Call setBoneScale .... ");
      setBoneScale(sceneName, boneName, scale);
    } else if (action.equals("length") ) {
      Float length = parseFloat( (args[0]).toString() );
      println("Call setBoneLength .... ");
      setBoneLength(sceneName, boneName, length);
    } else {
      println("Have no handler for bone action " + action );
    }

    //println("End of handleBoneAction ");

  }

}
