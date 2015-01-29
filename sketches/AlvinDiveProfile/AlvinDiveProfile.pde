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

//14:55:53.110
//2014/05/25 20:28:14.180
SimpleDateFormat sdfFull = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss.SSS");
SimpleDateFormat sdfTime = new SimpleDateFormat("hh:mm:ss.SSS");

Dive featureDive;

String debug = "";

void setup() {
  size(590 * 2, 442 * 2, P3D);

  light = createFont("Knockout-47Bantamweight", 72);
  heavy = createFont("Knockout-50Welterweight", 72);

  node = loadImage("node.png");

  //loadStrings(alvinServer + cruiseID + "/" + pathToUSBL + "Obs63 05240032.csv");
  background(255);
  colorMode(HSB);
  featureDive = loadDive("AL4722");
  println(featureDive.maxBounds);
  trot.x = 0.92;
  trot.z = -0.31;
}

void draw() {
  background(0,0,25);

  if (mousePressed) {
    trot.z += (mouseX - pmouseX) * -0.01; 
    trot.x += (mouseY - pmouseY) * 0.01;
  }

  rot.lerp(trot, 0.01);
  focus.lerp(tfocus, 0.1);
  alvin.lerp(talvin, 0.1);
  zoom = lerp(zoom, tzoom, 0.1);
  deep = lerp(deep, tdeep, 0.1);

  fill(255);
  textFont(heavy);
  textSize(72);
  blendMode(ADD);
  text("ALVIN#" + cruiseID + featureDive.diveNo, 50, 90);

  translate(width/2, height/2);
  scale(zoom);
  rotateX(rot.x);
  rotateY(rot.y);
  rotateZ(rot.z);
  translate(-width/2, -height/2);
  translate(width/2, height/2);

  tfocus.set(alvin.x, alvin.y, alvin.z);

  translate(-focus.x, -focus.y, -focus.z);

  stroke(255, 120 * deep);
  if (deep > 0.001) renderSurface();

  Dive d = featureDive;
  d.update();
  d.render();

  pushMatrix();
  translate(alvin.x, alvin.y, alvin.z);
  fill(255);
  noStroke();
  sphere(5);
  popMatrix();
  
  stroke(255, 25 * deep);
  translate(0,0,-featureDive.maxDepth * ppm);
  if (deep > 0.001) renderSurface();
  
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

  float s = 5000;
  int n = 60;
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
  }
  
  if (key == 'l') {
    featureDive.tlineComplete = (featureDive.tlineComplete == 1) ? 0:1;
  }
}

