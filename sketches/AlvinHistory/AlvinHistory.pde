import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Collections;

ArrayList<Dive> allDives = new ArrayList();
ArrayList<Pilot> allPilots = new ArrayList();
HashMap<String, Pilot> pilotMap = new HashMap();

ArrayList<Dive> activeDives = new ArrayList();

SimpleDateFormat sdf;

Dive firstDive;
Dive lastDive;
Date startDate;
Date endDate;

float rad = 175;
float osize = 1280;

float sc = 1;

PFont label;
PFont labelLight;

int mode = 0;

int dc = 0;

String search = "";
int c = 0;

float diveCount = 0;

float globalTimeFraction = 0;

PGraphics canvas;

PVector grot = new PVector();
PVector tgrot = new PVector();

float zoom = 1;
float tzoom = 1;

String[] filters = {"", "HICKEY", "VAN DOVER"};
int filterIndex = 0;

float totalDepth = 0;

void setup() {
  size(1280,720, P3D); 

  sc = (float) height / osize;

  canvas = createGraphics(int(osize), int(osize), P3D);
  canvas.beginDraw();
  canvas.background(0, 0);
  canvas.endDraw();

  smooth(4);
  rectMode(CENTER);

  label = createFont("OstrichSans-Bold", 48);
  labelLight = createFont("OstrichSans-Medium", 48);

  sdf = new SimpleDateFormat("MM/dd/yy");
  loadDives("../../data/AlvinHistory.csv");
  println(allDives.size());

  filterDives(search);
  setStartEnd();
  positionRing();

  Collections.sort(allPilots);
  Collections.reverse(allPilots);

  for (int i = 0; i < 10; i++) {
    Pilot p = allPilots.get(i);
    println((i + 1) + ". " + p.name + "     " + p.dives + "     " + round(p.hours));
  }
  
  java.util.Collections.sort(allDives);
  println("MEDIAN" + allDives.get(allDives.size() / 2).depth);
}

void filterReset(String f) {
  for (Dive d:activeDives) {
   d.life = 0;
   d.alive = false;
   d.stamped = false; 
   //d.clear();
  }
  search = f;
  globalTimeFraction = 0;
  filterDives(search);
  setStartEnd();
  positionRing();
  
  canvas.beginDraw();
  canvas.background(0, 0);
  canvas.endDraw();
}

void draw() {
  
  grot.lerp(tgrot, 0.1);
  zoom = lerp(zoom, tzoom, 0.1);

  if (globalTimeFraction < 1) globalTimeFraction += 0.001;
  
  if (tgrot.x != 0) {
    if (mousePressed) tgrot.z += (mouseX - pmouseX) * -0.01;
  } else {
   tgrot.z = 0; 
  }

  background(21,32,45);
  
  pushMatrix();
  scale(sc);
  
  textFont(label);
  textSize(72);
  textAlign(LEFT);
  fill(255);
  text("ALVIN AT 50", 50, 78);

  if (search != "") {
    fill(255, 0, 0);
    text(":" + search, 50 , 150);
  }

  textSize(36);
  //text(c + " DIVES", 50, 110);

  popMatrix();
  
  translate(width/2, height/2);
  scale(zoom);
  translate(0,grot.x * 100);
  rotateX(grot.x);
  rotateY(grot.y);
  rotateZ(grot.z);
  translate(-width/2, -height/2);
  
  hint(DISABLE_DEPTH_MASK);
  if (mode == 1) renderCircleKey();
  hint(ENABLE_DEPTH_MASK);

  int i =0;
  for (Dive d:activeDives) {
    if (!d.stamped ) {
      d.update();
      if (i % 1 == 0 && d.life > 0) {
        d.render();
        i++;
      }
    }
  }

  //DiveCount
  textSize(60);
  textAlign(CENTER);
  fill(255);
  text(int(diveCount), width/2, height/2 + 5);
  textSize(24);
  text("DIVES", width/2, height/2 + 24 + 5);

  image(canvas, 0, 0);
  
  saveFrame("frames/alvin-######.png");
}

void filterDives(String f) {
  activeDives = new ArrayList();
  totalDepth = 0;
  int c = 0;
  for (Dive d:allDives) {
    String pass = d.pilotName + d.observer1 + d.observer2;
    boolean chk = pass.indexOf(f.toUpperCase()) != -1 || f == "";
    d.a = (chk) ? 200:2;
    
    if (chk) {
      c++;
      activeDives.add(d);
      totalDepth += d.depth;
    }
  } 
  //search = "";
  println(c + " DIVES");
  println(totalDepth + " METRES");
}

void loadDives(String url) {
  Table t = loadTable(url, "header");
  for (TableRow row:t.rows()) {
    Dive d = new Dive().fromTableRow(row).init();



    Pilot p = null;
    if (!pilotMap.containsKey(d.pilotName)) {
      p = new Pilot();
      p.name = d.pilotName;
      pilotMap.put(d.pilotName, p); 
      allPilots.add(p);
    } 
    else {
      p = pilotMap.get(d.pilotName);
    }
    p.dives ++;
    p.hours += random(6, 12);

    allDives.add(d);
  }



  //println(firstDive.date, lastDive.date);
}


void setStartEnd() {
  firstDive = activeDives.get(activeDives.size() -1);
  startDate = new Date(firstDive.date.getYear(), 0, 1);

  lastDive = activeDives.get(0);
  endDate = new Date(lastDive.date.getYear() + 1, 0, 1);

  //Set time fractions
  for (Dive d:activeDives) {
    d.timeFraction = map(d.date.getTime(), startDate.getTime(), endDate.getTime(), 0, 1);
  }
}

void positionRing() {

  mode = 1;

  for (int i = 0; i < allDives.size(); i++) {
    Dive d = allDives.get(i);
    //float th = map(i, 0, allDives.size(), -PI/2, PI + PI/2);
    float th = map(d.date.getTime(), startDate.getTime(), endDate.getTime(), -PI/2, PI + PI/2 - 0.2);
    d.tpos.set(width/2 + (cos(th) * rad * sc), height/2 + (sin(th) * rad * sc));
    d.pos = d.tpos;
    d.trot.z = d.rot.z = th;
  }
}

void renderCircleKey() {

  //YEARS
  int sy = startDate.getYear();
  int ey = endDate.getYear();
  //println(sy, ey);
  pushMatrix();
  translate(width/2, height/2);
  scale(sc);
  stroke(255);
  textFont(label);
  for (int i = sy + 1; i < ey; i++) {
    Date d = new Date(i, 0, 1);
    float th = map(d.getTime(), startDate.getTime(), endDate.getTime(), -PI/2, PI + PI/2 - 0.2);
    pushMatrix();
    rotate(th);
    line(rad, 0, rad - (i % 10 == 0 ? 20:10), 0);
    if (i % 10 == 0) {
      translate(rad - 22, 0);
      textAlign(RIGHT);
      textSize(30);
      fill(255, 150);
      text(i + 1900, 0, 6);
    }
    popMatrix();
  }

  //DEPTH
  int[] rings = {
    50, 250, 500, 1000, 2500, 4500
  };
  reverse(rings);
  fill(255, 15);
  //stroke(255,50);
  noStroke();
  textFont(labelLight);
  textSize(24);
  textAlign(CENTER);
  for (int depth:rings) {
    float w = (rad * 2) + (depth / 5);
    ellipse(0, 0, w, w);
  }

  fill(255, 160);
  for (int depth:rings) {
    float th = PI + PI/2 - 0.1;
    pushMatrix();
    rotate(th);
    translate(rad + depth / 10 - 10, 0);
    rotate(PI/2);
    text(depth + "m", 0, -10);
    popMatrix();
  }

  stroke(255);
  rotateZ((globalTimeFraction * TAU) - PI/2);
  line(rad, 0, rad-50, 0);

  popMatrix();
}

void keyPressed() {
  if (key == 's') save("outs/alvin_" + search + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
  if (key == 'c') filterReset("VAN DOVER");
  if (key == 't') {
    tgrot.x = (tgrot.x == 0) ? 1:0;
    tzoom = (tgrot.x == 0) ? 1:1.3;
      
  }
  if (keyCode == RIGHT) {
    dc = 0;
    diveCount = 0;
    filterIndex ++;
    if (filterIndex == filters.length) filterIndex = 0;
    filterReset(filters[filterIndex]);
  } else if (keyCode == LEFT) {
    
  }
}

