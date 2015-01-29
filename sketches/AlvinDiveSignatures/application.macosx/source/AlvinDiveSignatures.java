import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.text.SimpleDateFormat; 
import java.util.Date; 
import java.util.Collections; 
import java.util.ArrayList; 
import processing.core.PVector; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AlvinDiveSignatures extends PApplet {







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

float ppm = 0.8f;

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

public void setup() {
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

public void loadInterface() {
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
     .setRange(0.5f,5) // values can range from big to small as well
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

public void controlEvent(ControlEvent theEvent) {
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


public void draw() {
  background(0);
  rectMode(CENTER);
  pushMatrix();
  hint(ENABLE_DEPTH_TEST);
  
  

  if (mousePressed && mouseY < height - 100) {
    trot.z += (mouseX - pmouseX) * -0.01f; 
    trot.x += (mouseY - pmouseY) * 0.01f;
  }

  rot.lerp(trot, 0.01f);
  focus.lerp(tfocus, 0.1f);
  alvin.lerp(talvin, 0.1f);
  zoom = lerp(zoom, tzoom, 0.1f);
  deep = lerp(deep, tdeep, 0.1f);

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
    if (deep > 0.001f) renderSurface();
  }

  popMatrix();
  hint(DISABLE_DEPTH_TEST);
}

public Dive loadDive(String diveNo) {
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

public void renderSurface() {

  float s = 5000 * ppm;
  int n = 50;
  for (int i = 0; i < n; i++) {
    float step = map(i, 0, n, -s, s);
    line(-s, step, s, step);
    line(step, -s, step, s);
  }
}

public void loadUSBLFile(String url, Dive d) {
  String[] rows = loadStrings(url);
  for (String row:rows) {
    d.fileUSBL(row);
  }
}

public String[] listFileNames(String dir) {
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

public void saveImage() {
  println("SAVE");
 save("Screenshots/" + cruiseID + featureDive.diveNo + "/DiveViz_" + featureDive.dc + "_" + nf(zoom, 2,2) + "_" + nf(trot.z, 2, 2) + ".png"); 
}

public void keyPressed() {
  if (key == '=') tzoom += 0.1f;
  if (key == '-') tzoom -= 0.1f;
  if (key == ' ') {
    playing = !playing;
    //tdeep = (playing) ? 1:0; 
    //if (!playing) tfocus = new PVector();
  }
  if (key == 'd') {
    tdeep = (tdeep == 0) ? 1:0;
    if (tdeep == 1 && trot.x == 0) {
      trot.x = 0.92f;
      trot.z = -0.31f;
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

class Dive {

  String diveNo;
  String dateString;
  int dc = 0;

  PVector minBounds = new PVector(100000, 100000, 100000);
  PVector maxBounds = new PVector(-100000, -100000, -100000);

  ArrayList<TPDRPoint> TPDRPoints = new ArrayList();
  ArrayList<DepthRecord> depthRecords = new ArrayList();

  PVector[] complexPath;
  PVector[] simplePath;

  ArrayList<Marker> markers = new ArrayList();

  Date startDate;
  Date endDate;

  Date currentDate = new Date();

  float maxDepth = 0;
  float currentDepth = 0;

  float lineComplete = 0;
  float tlineComplete = 1;

  PVector markerOff;
  PVector centroid = new PVector();

  HashMap<String, Marker> markerMap = new HashMap();

  public void simplify() {
    int t = TPDRPoints.size();
    println("BEFORE SIMPLIFICATION:" + t);
    complexPath = new PVector[t];
    for (int i = 0; i < t; i++) {
      complexPath[i] = TPDRPoints.get(i).pos;
    }

    simplePath = Simplify.runningAverage(complexPath, 10);

    //Calculate average
    for (PVector p:simplePath) {
      centroid.add(p);
    }
    centroid.div(simplePath.length);
    centroid.z = -(maxDepth * 0.7f) * ppm;

    //simplePath = Simplify.simplify(simplePath, 50, true);
    //println("AFTER SIMPLIFICATION" + simplePath.length);
  }

  public void update() {


    if (lineComplete < 1 && tlineComplete == 1) lineComplete += 0.01f;
    if (lineComplete > 0 && tlineComplete == 0) lineComplete -= 0.01f;
    lineComplete = constrain(lineComplete, 0, 1);
  }

  public void render() {
    if (TPDRPoints.size() > 0) {
      if (lineComplete < 0.99f ) {
        for (int c = 0; c < TPDRPoints.size(); c++) {
          TPDRPoint tp = TPDRPoints.get(c); 
          PVector p = tp.pos;

          pushMatrix();
          translate(p.x * ppm, p.y * ppm, p.z * ppm * deep);
          //rotateX(radians(tp.rot.x));
          //rotateY(radians(tp.rot.y));
          //rotateZ(radians(tp.rot.z) + PI/4);
          //line(-5, 0, 5, 0);
          //point(0, 0, 0);
          rotateZ(-rot.z);
          rotateY(-rot.y);
          rotateX(-rot.x);
          //tint(map(c, 0, TPDRPoints.size(), 0, 180), 255, 255);
          //image(node,0,0);

          //stroke(0);
          /*
        stroke(map(c, 0, TPDRPoints.size(), 0, 180), 255, 255);
           point(0, 0);
           //*/

          //*
          noStroke();
          fill(map(c, 0, TPDRPoints.size(), 0, 180), 255, 255);
          rect(0, 0, 1, 1);
          //*/


          popMatrix();
        }
      }


      TPDRPoint tp = TPDRPoints.get(dc);
      currentDate = tp.date;
      currentDepth = tp.depth;
      debug = "" + tp.rot.z;
      talvin.set(tp.pos.x * ppm, tp.pos.y * ppm, tp.pos.z * ppm * deep);
      //if (tp.pos.z < 0) tfocus.z = tp.pos.z * ppm * deep;
      //println(p.z * ppm);

      //*
      for (Marker m:markers) {
        m.update();
        m.render();
      }
      //*/

      //Draw simple path
      stroke(230);
      strokeWeight(3);
      noFill();
      beginShape();
      println(simplePath.length * lineComplete);
      for (int i = 10; i < simplePath.length * lineComplete - 11; i++) {
        PVector p = simplePath[i];
        vertex(p.x * ppm, p.y * ppm, p.z * ppm * deep);
      }
      endShape();
      strokeWeight(1);

      //Animate Alvin
      if (playing) dc ++;
      if (dc == TPDRPoints.size()) dc = 0;

      //Draw centroid
      pushMatrix();
      fill(255, 255, 255);
      translate(centroid.x, centroid.y, centroid.z * deep);
      noStroke();
      //rect(0,0,10,50);
      //rect(0,0,50,10);

      popMatrix();
    }
  }

  public void loadMarkers(String url) {
    String[] rows = loadStrings(url);
    for (String row:rows) {
      String[] cols = split(row, ",");
      if (cols[64].length() > 1 && !cols[64].equals("TGT Label")) {
        //println(cols[64], float(cols[66]), float(cols[67]), float(cols[68]));
        addMarker(cols[64], PApplet.parseFloat(cols[66]), PApplet.parseFloat(cols[67]), PApplet.parseFloat(cols[68]));
      };
    }
  }

  public void addMarker(String name, float x, float y, float d) {
    if (!markerMap.containsKey(name)) {
      Marker m = new Marker();
      m.pos.set(x * ppm, y * ppm, d * ppm);
      if (markerOff == null) {
        markerOff = new PVector(m.pos.x, m.pos.y, m.pos.z);
        println("MARKEROFF", markerOff);
      } 


      m.pos.x -= markerOff.x;
      m.pos.y -= markerOff.y;
      m.pos.z -= markerOff.z;


      if (m.pos.z <= 50) m.pos.z = maxDepth * -ppm;

      m.pos.x *= 10;
      m.pos.y *= 10;

      m.n = name;
      markers.add(m);
      markerMap.put(name, m);
    } 
    else {
    }
  }

  public void loadDepthFile(String url) {
    println("LOADING DEPTH FILE.");
    String[] rows = loadStrings(url);
    for (String row:rows) {
      //DEP 2014/05/25 20:28:14.180 ALVI 0 504.110364 *0001751.765
      String[] cols = split(row, " ");
      if (dateString == null) dateString = cols[1];
      DepthRecord dr = new DepthRecord();
      dr.depth = PApplet.parseFloat(cols[5]);
      maxDepth = max(maxDepth, dr.depth);
      try {
        dr.date = sdfFull.parse(cols[1] + " " + cols[2]);
      } 
      catch(Exception e) {
      }
      depthRecords.add(dr);
    }

    startDate = depthRecords.get(0).date;
    endDate = depthRecords.get(depthRecords.size() - 1).date;

    println(startDate, endDate);
  }

  public void fileUSBL(String usbl) {
    String[] cols = split(usbl, ",");
    if (cols[0].equals("TPDR")) parseTPDR(cols);
  }

  public void parseTPDR(String[] cols) {
    //0    1    2    3     4   5    6    7     8    9       10       11      12   13    14    15    16      17      18     19    20
    //TPDR,tick,name,index,fix,flag,time,pitch,roll,bearing,residual,quality,east,north,depth,const,x_angle,y_angle,debug1,debug2,debug3
    float depth = PApplet.parseFloat(cols[14]);
    float x = PApplet.parseFloat(cols[12]);
    float y = PApplet.parseFloat(cols[13]);
    float z = -PApplet.parseFloat(cols[14]);

    float pitch = PApplet.parseFloat(cols[7]);
    float roll = PApplet.parseFloat(cols[8]);
    float bearing = PApplet.parseFloat(cols[9]);

    float xangle = PApplet.parseFloat(cols[16]);
    float yangle = PApplet.parseFloat(cols[17]);

    String timeString = cols[1];

    TPDRPoint tp = new TPDRPoint();
    tp.depth = depth;
    tp.pos.set(x, y, z);
    tp.rot.set(pitch, roll, bearing);

    boolean goodDate = true;
    try {
      tp.date = sdfFull.parse(dateString + " " + timeString);
    } 
    catch (Exception e) {
      goodDate = false;
    }

    if (goodDate && tp.date.getTime() > startDate.getTime() && tp.date.getTime() < endDate.getTime() && tp.pos.x != 0) {
      TPDRPoints.add(tp);

      minBounds.x = min(x, minBounds.x);
      minBounds.y = min(y, minBounds.y);
      minBounds.z = min(z, minBounds.z);

      maxBounds.x = max(x, maxBounds.x);
      maxBounds.y = max(y, maxBounds.y);
      maxBounds.z = max(z, maxBounds.z);
    }

    //println(depth);
  }
}

class TPDRPoint implements Comparable {
  PVector pos = new PVector();
  PVector rot = new PVector();
  Date date;
  float depth;

  public int compareTo(Object o) {
    return(PApplet.parseInt(date.getTime() -  ((TPDRPoint)o).date.getTime()));
  }
}

class DepthRecord {
  Date date;
  float depth;
}

class Marker {
  PVector pos = new PVector();
  String n;

  public void update() {
  }

  public void render() {
    pushMatrix();

    translate(-pos.x, -pos.y, pos.z * deep);

    fill(156, 255, 255);
    noStroke();
    rect(0, 0, 3, 15);
    rect(0, 0, 15, 3);

    fill(255);
    scale(rot.x / (PI * 0.5f) );
    rotateX(-PI/2);
    rotateY(rot.z);
    rotateZ(-PI/2);
    textFont(light);
    textSize(14);
    text(n, 5, -5);

    stroke(0);
    line(0, 0, textWidth(n) + 5, 0);
    popMatrix();
  }
}

/**

 * ijeomamotion
 * A cross-mode Processing library for sketching animations with numbers, colors vectors, beziers, curves and more. 
 * http://ekeneijeoma.com/processing/ijeomamotion
 *
 * Copyright (C) 2012 Ekene Ijeoma http://ekeneijeoma.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      Ekene Ijeoma http://ekeneijeoma.com
 * @modified    05/08/2013
 * @version     5.2 (52)
 */

//package ijeoma.math;





public static class Simplify {
  
  public static PVector[] runningAverage (PVector[] points, int bracket) {
    PVector[] newPoints = new PVector[points.length];
    for(int i = 0; i < points.length; i++) {
     int leftEdge = max(0, i - bracket);
     int leftBleed = 0 - (i - bracket);
     int rightEdge = min(points.length - 1, i + bracket);
     PVector av = new PVector();
     int b = 0;
     for(int j = leftEdge; j <rightEdge; j++) {
       av.add(points[j]);
       b++;
     }
     av.div(bracket * 2);
     newPoints[i] = av;
    }
    
    return(newPoints);
  }
  
  
  public static PVector[] simplify(PVector[] points, float tolerance) {
    float sqTolerance = tolerance * tolerance;

    return simplifyDouglasPeucker(points, sqTolerance);
  }

  public static PVector[] simplify(PVector[] points, float tolerance,
      boolean highestQuality) {
    float sqTolerance = tolerance * tolerance;

    if (!highestQuality)
      points = simplifyRadialDistance(points, sqTolerance);

    points = simplifyDouglasPeucker(points, sqTolerance);

    return points;
  }

  // distance-based simplification
  public static PVector[] simplifyRadialDistance(PVector[] points, float sqTolerance) {
    int len = points.length;

    PVector point = new PVector();
    PVector prevPoint = points[0];

    ArrayList<PVector> newPoints = new ArrayList<PVector>();
    newPoints.add(prevPoint);

    for (int i = 1; i < len; i++) {
      point = points[i];

      if (getSquareDistance(point, prevPoint) > sqTolerance) {
        newPoints.add(point);
        prevPoint = point;
      }
    }

    if (!prevPoint.equals(point)) {
      newPoints.add(point);
    }

    return newPoints.toArray(new PVector[newPoints.size()]);
  }

  // simplification using optimized Douglas-Peucker algorithm with recursion
  // elimination
  public static PVector[] simplifyDouglasPeucker(PVector[] points, float sqTolerance) {
    int len = points.length;

    Integer[] markers = new Integer[len];

    Integer first = 0;
    Integer last = len - 1;

    float maxSqDist;
    float sqDist;
    int index = 0;

    ArrayList<Integer> firstStack = new ArrayList<Integer>();
    ArrayList<Integer> lastStack = new ArrayList<Integer>();

    ArrayList<PVector> newPoints = new ArrayList<PVector>();

    markers[first] = markers[last] = 1;

    while (last != null) {
      maxSqDist = 0;

      for (int i = first + 1; i < last; i++) {
        sqDist = getSquareSegmentDistance(points[i], points[first],
            points[last]);

        if (sqDist > maxSqDist) {
          index = i;
          maxSqDist = sqDist;
        }
      }

      if (maxSqDist > sqTolerance) {
        markers[index] = 1;

        firstStack.add(first);
        lastStack.add(index);

        firstStack.add(index);
        lastStack.add(last);
      }

      if (firstStack.size() == 0)
        first = null;
      else
        first = firstStack.remove(firstStack.size() - 1);

      if (lastStack.size() == 0)
        last = null;
      else
        last = lastStack.remove(lastStack.size() - 1);
    }

    for (int i = 0; i < len; i++) {
      if (markers[i] != null)
        newPoints.add(points[i]);
    }

    return newPoints.toArray(new PVector[newPoints.size()]);
  }

  public static float getSquareDistance(PVector p1, PVector p2) {
    float dx = p1.x - p2.x, dy = p1.y - p2.y, dz = p1.z - p2.z;
    return dx * dx + dz * dz + dy * dy;
  }

  // square distance from a point to a segment
  public static float getSquareSegmentDistance(PVector p, PVector p1, PVector p2) {
    float x = p1.x, y = p1.y, z = p1.z;

    float dx = p2.x - x, dy = p2.y - y, dz = p2.z - z;

    float t;

    if (dx != 0 || dy != 0 || dz != 0) {
      t = ((p.x - x) * dx + (p.y - y) * dy) + (p.z - z) * dz
          / (dx * dx + dy * dy + dz * dz);

      if (t > 1) {
        x = p2.x;
        y = p2.y;
        z = p2.z;

      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
        z += dz * t;
      }
    }

    dx = p.x - x;
    dy = p.y - y;
    dz = p.z - z;

    return dx * dx + dy * dy + dz * dz;
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#000000", "--hide-stop", "AlvinDiveSignatures" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
