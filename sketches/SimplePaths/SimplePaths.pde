import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.volume.*;
import toxi.processing.*;


String filePath = "paths/";
String[] diveFiles = {
  "AL4717", "AL4718", "AL4719", "AL4721", "AL4722", "AL4723", "AL4724"
    //"AL4723"
};

ArrayList<Dive> allDives = new ArrayList();

PVector rot = new PVector();
PVector trot = new PVector();

float z = 0;
float tz = 0.25;

PVector focus;
PVector tfocus;

void setup() {
  size(1280, 720, P3D);
  
  focus = new PVector(width/2, height/3);
  tfocus = new PVector(width/2, height/3);


  smooth(8);
  loadDives();
}

void draw() {

  if (mousePressed) {
    trot.x += (mouseY - pmouseY) * 0.01;
    trot.z -= (mouseX - pmouseX) * 0.01;
  }

  rot.lerp(trot, 0.1);
  focus.lerp(tfocus, 0.1);
  z = lerp(z, tz, 0.1);


  background(255);

  translate(focus.x, focus.y);
  scale(z);
  rotateX(rot.x);
  rotateY(rot.y);
  rotateZ(rot.z);
  for (Dive d:allDives) {
    d.update();
    d.render();
  }
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
  }
  tfocus.y = width/2;
}

void joinDescents() {
  for (Dive d:allDives) {
    d.toff = d.descent[d.descent.length - 1];
  }
  tfocus.y = width/2;
}

void keyPressed() {
  if (key == 's') {
    save("ALVIN_" + hour() + "_" + minute() + "_" + second() + ".png");
  } 
  if (key == 'a') joinAscents();
  if (key == 'd') joinDescents();
}

