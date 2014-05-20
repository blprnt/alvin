import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Collections;

ArrayList<Dive> allDives = new ArrayList();

ArrayList<Pilot> allPilots = new ArrayList();
HashMap<String, Pilot> pilotMap = new HashMap();

SimpleDateFormat sdf;

Dive firstDive;
Dive lastDive;
Date startDate;
Date endDate;

float rad = 175;

PFont label;
PFont labelLight;

int mode = 0;

int dc = 0;

String search = "";
int c = 0;

void setup() {
  size(1280, 1280, P3D); 
  smooth(4);

  label = createFont("OstrichSans-Bold", 48);
  labelLight = createFont("OstrichSans-Medium", 48);


  sdf = new SimpleDateFormat("MM/dd/yy");
  loadDives("../../data/AlvinHistory.csv");
  println(allDives.size());
  
  filterDives(search);
  println(dc);
  positionRing();
  
  Collections.sort(allPilots);
  Collections.reverse(allPilots);
  
  for (int i = 0; i < 10; i++) {
   Pilot p = allPilots.get(i);
   println((i + 1) + ". " + p.name + "     " + p.dives + "     " + round(p.hours)); 
  }
}

void draw() {

  background(0);
  textFont(label);
  textSize(48);
  textAlign(LEFT);
  fill(255);
  //text("ALVIN", 50, 68);

  if (search != "") {
    fill(255, 0, 0);
    text(search, 150, 68);
  }

  textSize(36);
  //text(c + " DIVES", 50, 110);



  if (mode == 1) renderCircleKey();

  //println(allDives.size());
  for (Dive d:allDives) {
    d.update();
    d.render();
    //float x = map(d.lonLat.x, -180, 180, 0, width);
    //float y = map(d.lonLat.y, -90, 90, height, 0);
    //println(x,y);
    //fill(#FF0000);
    //noStroke();
    //ellipse(x,y,3,3);
  }
}

void filterDives(String f) {
  for (Dive d:allDives) {
    String pass = d.pilotName + d.observer1 + d.observer2;
    boolean chk = pass.indexOf(f.toUpperCase()) != -1 || f == "";
    d.a = (chk) ? 200:2;
    dc += d.depth;
    if (chk) c++;
  } 
  //search = "";
  println(c + " DIVES");
}

void loadDives(String url) {
  Table t = loadTable(url, "header");
  for (TableRow row:t.rows()) {
    Dive d = new Dive().fromTableRow(row);
    allDives.add(d);
    
    Pilot p = null;
    if (!pilotMap.containsKey(d.pilotName)) {
      p = new Pilot();
      p.name = d.pilotName;
      pilotMap.put(d.pilotName, p); 
      allPilots.add(p);
    } else {
     p = pilotMap.get(d.pilotName); 
    }
    p.dives ++;
    p.hours += random(6,12);
  }

  firstDive = allDives.get(allDives.size() -1);
  startDate = new Date(firstDive.date.getYear(), 0, 1);

  lastDive = allDives.get(0);
  endDate = new Date(lastDive.date.getYear() + 1, 0, 1);

  //println(firstDive.date, lastDive.date);
}

void positionRing() {

  mode = 1;

  for (int i = 0; i < allDives.size(); i++) {
    Dive d = allDives.get(i);
    //float th = map(i, 0, allDives.size(), -PI/2, PI + PI/2);
    float th = map(d.date.getTime(), startDate.getTime(), endDate.getTime(), -PI/2, PI + PI/2 - 0.2);
    d.tpos.set(width/2 + (cos(th) * rad), height/2 + (sin(th) * rad));
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
      textSize(18);
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
  fill(255, 5);
  //stroke(255,50);
  noStroke();
  textFont(labelLight);
  textSize(14);
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
    text(depth + "m", 0, 0);
    popMatrix();
  }

  popMatrix();
}

void keyPressed() {
  if (key == 's') save("outs/alvin_" + search + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + ".png");
}

