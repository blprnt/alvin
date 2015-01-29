
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.volume.*;
import toxi.processing.*;

String fileLocation0610 = "Cup06-10.obj";
String fileLocation0614 = "Cup06-14.obj";

PShape ps0610;
PShape ps0614;


ToxiclibsSupport gfx;

VolumetricSpaceArray volume;
IsoSurface surface;
VolumetricBrush brush;

TriangleMesh mesh = new TriangleMesh("mesh");

float ISO = 0.9;
int GRID = 10;
int DIM = 400;

int mode = 0;

String title = "ASCENT/DESCENT - 6 Dives.";
PFont label;

PImage wormCols;

Vec3D SCALE = new Vec3D(DIM, DIM, DIM);
ArrayList <Point> pointCloud;

String filePath = "paths/";
String[] diveFiles = {
  "AL4717", "AL4718", "AL4719", "AL4721", "AL4722", "AL4723", "AL4724"
    //"AL4723"
};

ArrayList<Dive> allDives = new ArrayList();

PVector rot = new PVector();
PVector trot = new PVector(1, 0, 0);
PVector rotSpeed = new PVector();

float z = 0;
float tz = 0.25;

PVector focus;
PVector tfocus;

color off = 60;
color on = 255;

boolean cupping = false;

void setup() {
  size(1280, 720, P3D);

  focus = new PVector(width/2, height/3);
  tfocus = new PVector(width/2, height/4);

  label = createFont("OstrichSans-Black", 48);
  
  wormCols = loadImage("wormCols2.jpg");
  
  //Cups
  ps0610 = loadShape(fileLocation0610);
  ps0610.disableStyle();
  ps0614 = loadShape(fileLocation0614);
  ps0614.disableStyle();


  gfx=new ToxiclibsSupport(this);

  pointCloud = new ArrayList <Point> ();

  volume=new VolumetricSpaceArray(SCALE, GRID, GRID, GRID);
  surface=new ArrayIsoSurface(volume);
  brush=new RoundBrush(volume, 5);

  for (int i = 0; i < 100; i++) {
    //Vec3D v = new Vec3D(random(-300, 300), random(-300, 300), random(-300, 300));
    //Point p = new Point( v);
    //pointCloud.add(p);
  }

  smooth(8);
  loadDives();

  //for (Dive d:allDives) {
  Dive d = allDives.get(0);
  for (PVector pv:d.ascent) {
    Vec3D v = new Vec3D(-pv.x, pv.y, pv.z);
    Point p = new Point( v);
    //if (random(100) < 10) pointCloud.add(p);
  } 
  //}

  splitDives();
}

void draw() {
  
  randomSeed(0);
  
  if (mousePressed) {
    trot.x += (mouseY - pmouseY) * 0.01;
    trot.z -= (mouseX - pmouseX) * 0.01;
  }

  rot.lerp(trot, 0.1);
  focus.lerp(tfocus, 0.1);
  z = lerp(z, tz, 0.1);

  trot.add(rotSpeed);


  background(off);
  if (mode == 1 || mode == 2) lights();

  textFont(label);
  text(title, 50, 80);

  translate(focus.x, focus.y);
  scale(z);
  rotateX(rot.x);
  rotateY(rot.y);
  rotateZ(rot.z);
  for (Dive d:allDives) {
    d.update();
    d.render();
  }

  volume.clear();

  for (Point p : pointCloud) {
    p.display();
  }
  volume.closeSides();

  surface.reset();
  surface.computeSurfaceMesh(mesh, ISO);
  mesh.computeVertexNormals();

  stroke(255);
  noFill();
  //fill(255);
  //gfx.mesh(mesh, true);
  
  //saveFrame("frames/alvin-######.png");
}

void loadDives() {
  for (String f:diveFiles) {
    loadStrings(filePath + f + ".csv");
    Dive d = new Dive().fromCSV(loadTable(filePath + f + ".csv"));
    d.findAD();
    allDives.add(d);
  }
}

void joinAscents() {
  for (Dive d:allDives) {
    d.toff = d.ascent[d.ascent.length - 1];
    d.diveIndex = d.ascentStart;
  }
  tfocus.y = width/2;
  mode = 1;
  title = "ASCENT";
  //rotSpeed.set(0, 0, 0.01);
}

void joinDescents() {
  for (Dive d:allDives) {
    d.toff = d.descent[d.descent.length - 1];
    d.diveIndex = d.descentStart;
  }
  tfocus.y = width/2;
  mode = 2;
  title = "DESCENT";
  //rotSpeed.set(0, 0, 0.01);
}

void reset() {
  for (Dive d:allDives) {
    d.toff = new PVector();
    d.diveIndex = d.descentStart;
  }
  tfocus.y = 80;
  mode = 0;
  rotSpeed.set(0, 0, 0);
  cupping = false;
}

void splitDives() {
  for (int i =0 ; i < allDives.size(); i++) {
    Dive d = allDives.get(i);
    float x = map(i, 0, allDives.size(), -width * 1.9, width * 2.4);
    d.toff = new PVector(x, 0, 0);
    d.diveIndex = d.descentStart;
  }
  tfocus.y = 120;
  trot.set(PI/2, 0, 0);
  mode = 0;
  tz = 0.2;
  rotSpeed.set(0, 0, 0);
  cupping = false;
}

void keyPressed() {
  if (key == 's') {
    save("ALVIN_" + hour() + "_" + minute() + "_" + second() + ".png");
  } 
  if (key == 'a') joinAscents();
  if (key == 'd') joinDescents();
  if (key == ' ') reset();
  if (key == 'r') splitDives();
  if (key == 'c') {
   cupping = !cupping;
   if (cupping) {
    for(Dive d:allDives) d.cupCount =0 ;
   } 
  }
}


class Point {

  Vec3D loc;

  Point(Vec3D _loc) {
    loc = _loc;
  }

  void run() {

    display();
  }

  void display() {
    strokeWeight(5);
    stroke(255, 0, 0);
    point(loc.x, loc.y, loc.z);

    brush.setSize(80);
    brush.drawAtAbsolutePos(loc, 1);
  }
}

