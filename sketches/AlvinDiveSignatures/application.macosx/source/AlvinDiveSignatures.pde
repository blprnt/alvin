import controlP5.*;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Collections;

String alvinServer = "/Volumes/data_on_alvin/";
String pathToUSBL = "/USBL/";
String pathToTopLab = "/Toplab_DVL/";
String pathToDepthFile = "/c+c/";
//String cruiseID = "archive/AT26-13/";
String cruiseID = "AT26-15/";

PVector rot = new PVector();
PVector trot = new PVector();

PVector focus = new PVector();
PVector tfocus = new PVector();

float ppm = 0.8;

PVector alvin = new PVector();
PVector talvin = new PVector();

float zoom = 0;
float tzoom = 1;

float deep = 0;
float tdeep = 0;

boolean archive = false;

boolean playing = false;

PImage node;

PFont light;
PFont heavy;

float offX = 0;

boolean drawLine = false;
boolean hasDepth = false;

//14:55:53.110
//2014/05/25 20:28:14.180
SimpleDateFormat sdfFull = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss.SSS");
SimpleDateFormat sdfTime = new SimpleDateFormat("hh:mm:ss.SSS");

Dive featureDive;

//Controls
ControlP5 cp5;
ListBox diveList;
String[] availableDives; 


String debug = "";
Date currentDate = new Date();

void setup() {
  size(displayWidth, displayHeight, P3D);

  light = createFont("Knockout-47Bantamweight", 72);
  heavy = createFont("Knockout-50Welterweight", 72);

  node = loadImage("node.png");

  //loadStrings(alvinServer + cruiseID + "/" + pathToUSBL + "Obs63 05240032.csv");
  background(255);
  colorMode(HSB);

  loadInterface();

  //featureDive = loadDive("AL4723");
  //println(featureDive.maxBounds);
}

void loadInterface() {
  //DIVE LIST
  cp5 = new ControlP5(this);
  diveList = cp5.addListBox("diveList")
    .setPosition(10, 30)
      .setSize(200, 250)
        .setItemHeight(30)
          .setBarHeight(20)
            .setColorBackground(color(255, 128))
              .setColorActive(color(0))
                .setColorForeground(color(255, 100, 0))
                  ;

  diveList.captionLabel().toUpperCase(true);
  diveList.captionLabel().set("ALVIN DIVES");
  diveList.captionLabel().setColor(0xffff0000);
  diveList.captionLabel().style().marginTop = 3;
  diveList.valueLabel().style().marginTop = 3;

  //Get a list of available dive IDs from directories
  availableDives = listFileNames(alvinServer + cruiseID);

  int i = 0;
  for (String dn:availableDives) {
    ListBoxItem lbi = diveList.addItem(dn, i);
    lbi.setColorBackground(0xffff0000);
    i++;
  }
  
  //ZOOM SLIDER
  cp5.addSlider("tzoom")
     .setPosition(220, height - 45)
     .setWidth(400)
     .setHeight(20)
     .setRange(0.5,5) // values can range from big to small as well
     .setValue(1)
     //.setNumberOfTickMarks(10)
     ;
     
  // PLAY/PAUSE
  cp5.addToggle("playing")
     .setPosition(30,height - 45)
     .setSize(50,20)
     ;
     
  // DRAW LINE
  cp5.addToggle("drawLine")
     .setPosition(90,height - 45)
     .setSize(50,20)
     ;
  
  // DRAW LINE
  cp5.addToggle("hasDepth")
     .setPosition(150,height - 45)
     .setSize(50,20)
     ;
  
  
}

void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.


  if (theEvent.isGroup() && theEvent.name().equals("diveList")) {
    diveList.close();
    int i = (int)theEvent.group().value();
    println("LOAD DIVE "+availableDives[i]);
    featureDive = loadDive(availableDives[i]);
    
  }
}


void draw() {
  background(0);
  rectMode(CENTER);
  pushMatrix();
  hint(ENABLE_DEPTH_TEST);
  
  

  if (mousePressed && mouseY < height - 100) {
    trot.z += (mouseX - pmouseX) * -0.01; 
    trot.x += (mouseY - pmouseY) * 0.01;
  }

  rot.lerp(trot, 0.01);
  focus.lerp(tfocus, 0.1);
  alvin.lerp(talvin, 0.1);
  zoom = lerp(zoom, tzoom, 0.1);
  deep = lerp(deep, tdeep, 0.1);

  if (featureDive != null) {
    
    featureDive.tlineComplete = drawLine ? 1:0;
    tdeep = hasDepth? 1:0;

    fill(255);
    textFont(heavy);
    textSize(72);
    text("ALVIN#" + cruiseID + featureDive.diveNo, 50, 90);

    textSize(48);
    text("MAX DEPTH: " + round(featureDive.maxDepth) + "m", 50, 135);
    text("DEPTH: " + round(featureDive.currentDepth) + "m", 50, 185);
    currentDate = featureDive.currentDate;
    text("TIME: " + nf(currentDate.getHours(),2) + ":" + nf(currentDate.getMinutes(),2) + ":" + nf(currentDate.getSeconds(),2), 50, 235);

    translate(width/2, height/2);
    scale(zoom);
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);
    translate(-width/2, -height/2);
    translate(width/2, height/2);

    PVector target = (playing || featureDive.dc != 0) ? (alvin):(featureDive.centroid);
    tfocus.set(target.x, target.y, target.z);

    translate(-focus.x, -focus.y, -focus.z * deep);
    
    colorMode(RGB);
    stroke(86,138,131);
    //if (deep > 0.001) 
    renderSurface();
    colorMode(HSB);
    
    
    translate(offX, 0);

    Dive d = featureDive;
    d.update();
    d.render();

    pushMatrix();
    translate(alvin.x, alvin.y, alvin.z);
    fill(255);
    noStroke();
    sphere(5);
    popMatrix();

    stroke(35);
    translate(0, 0, (-featureDive.maxDepth - 5) * ppm);
    if (deep > 0.001) renderSurface();
  }

  popMatrix();
  hint(DISABLE_DEPTH_TEST);
}

Dive loadDive(String diveNo) {
  Dive d = new Dive();
  d.diveNo = diveNo;

  //Get depth file
  String depthFileURL = alvinServer + cruiseID + diveNo + "/" + pathToDepthFile + diveNo + ".dep";
  d.loadDepthFile(depthFileURL);

  //Get filenames in USBL 
  String[] files = listFileNames(alvinServer + cruiseID + diveNo + "/" + pathToUSBL);

  for (String f:files) {
    String url = alvinServer + cruiseID + diveNo + "/" + pathToUSBL + f;
    loadUSBLFile(url, d);
  }

  //Sort USBL points
  Collections.sort(d.TPDRPoints);

  //Create simple path
  d.simplify();

  //Get markers from TopLabDVL files
  //Get filenames in USBL 
  files = listFileNames(alvinServer + cruiseID + diveNo + "/" + pathToTopLab);
  for (String f:files) {
    if (f.indexOf("CSV") != -1) {
      println(f);
      String url = alvinServer + cruiseID + diveNo + "/" + pathToTopLab + f;
      d.loadMarkers(url);
      //loadUSBLFile(url, d);
      break;
    }
  }

  return(d);
}

void renderSurface() {

  float s = 5000 * ppm;
  int n = 50;
  for (int i = 0; i < n; i++) {
    float step = map(i, 0, n, -s, s);
    line(-s, step, s, step);
    line(step, -s, step, s);
  }
}

void loadUSBLFile(String url, Dive d) {
  String[] rows = loadStrings(url);
  for (String row:rows) {
    d.fileUSBL(row);
  }
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } 
  else {
    // If it's not a directory
    return null;
  }
}

void saveImage() {
  println("SAVE");
 save("Screenshots/" + cruiseID + featureDive.diveNo + "/DiveViz_" + featureDive.dc + "_" + nf(zoom, 2,2) + "_" + nf(trot.z, 2, 2) + ".png"); 
}

void keyPressed() {
  if (key == '=') tzoom += 0.1;
  if (key == '-') tzoom -= 0.1;
  if (key == ' ') {
    playing = !playing;
    //tdeep = (playing) ? 1:0; 
    //if (!playing) tfocus = new PVector();
  }
  if (key == 'd') {
    tdeep = (tdeep == 0) ? 1:0;
    if (tdeep == 1 && trot.x == 0) {
      trot.x = 0.92;
      trot.z = -0.31;
    }
  }
  if (key == 'l') {
    featureDive.tlineComplete = (featureDive.tlineComplete == 1) ? 0:1;
  }

  if (keyCode == RIGHT) {
    offX -= 10;
  }
  if (key == 's') {
    saveImage();
  }
}

