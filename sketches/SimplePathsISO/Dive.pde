class Dive {

  PVector[] simplePath;
  PVector[] ascent;
  PVector[] descent;

  float ppm = 1;
  float deep = 1;

  PVector off = new PVector();
  PVector toff = new PVector();

  int diveIndex = 0;
  int ascentStart;
  int descentStart;
  
  int cupCount = 0;


  Dive fromCSV(Table t) {
    simplePath = new PVector[t.getRowCount()];
    for (int i = 0; i < t.getRowCount(); i++) {
      TableRow tr = t.getRow(i);
      PVector p = new PVector(tr.getFloat(0), tr.getFloat(1), tr.getFloat(2));
      simplePath[i] = p;
    }
    return(this);
  }

  void findAD() {
    //Find ascent and descent
    //----------------------------------------Descent
    ArrayList<PVector> temp = new ArrayList();
    int i = 0;
    int riseCount = 0;

    float startTol = -50;
    boolean started = false;
    float dtol = -10;
    float dstol = 0;

    boolean d = true;
    while (d) {
      PVector p = simplePath[i];
      PVector p2 = simplePath[i + 1];
      //println(p.z);
      if (p.z > startTol && !started) {
        started = true;
        descentStart = i;
        println(started);
      }
      if (started) {

        if (p2.z - p.z > dstol && p.z < dtol) {
          riseCount ++;
        } 
        else {
          riseCount = 0;
          if (p.z < dtol && started) temp.add(p);
        }

        if (riseCount >= 20 || i == simplePath.length) d = false;
      }
      i++;
    }

    descent = new PVector[temp.size()];
    for (int j = 0; j < temp.size(); j++) {
      descent[j] = temp.get(j);
    }

    //----------------------------------------Ascent
    temp = new ArrayList();
    i = simplePath.length - 1;
    riseCount = 0;

    d = true;
    while (d) {
      PVector p = simplePath[i];
      PVector p2 = simplePath[i - 1];
      if (p.z < dtol) temp.add(p);
      if (p2.z - p.z > dstol) {
        riseCount ++;
      } 
      else {
        riseCount = 0;
      }
      i--;
      if (riseCount >= 20 || i == 0) d = false;
    }

    ascentStart = i;
    diveIndex = descentStart;

    ascent = new PVector[temp.size()];
    for (int j = 0; j < temp.size(); j++) {
      ascent[j] = temp.get(j);
    }
  }

  void update() {
    if (cupping) cupCount += 50;
    diveIndex ++;
    if (diveIndex == simplePath.length) diveIndex = 0;
  }

  void render() {

    off.lerp(toff, 0.1);


    pushMatrix();
    translate(-off.x, -off.y, -off.z);

    if (mode == 0) {
      stroke(255, 200);
      strokeWeight(1);
      renderPath(simplePath);
    }

    if (mode == 0 || mode == 2) {
      stroke(255, 0, 0);
      strokeWeight(10);
      renderPath(descent);
    }

    if (mode == 0 || mode == 1) {
      stroke(0, 0, 255);
      strokeWeight(10);
      renderPath(ascent);
    }

    if (mode == 2 && cupping) cupIt(descent);
    if (mode == 1 && cupping) cupIt(ascent);

    //sub
    PVector sv = simplePath[diveIndex];
    pushMatrix();
    translate(sv.x, sv.y, sv.z);
    fill(255);
    noStroke();
    sphere(10);
    popMatrix();

    popMatrix();

    /*
    fill(255);
     noStroke();
     for(PVector p:descent) {
     pushMatrix();
     translate(p.x,p.y,p.z);
     //sphere(20);
     popMatrix();
     }
     */
  }

  void cupIt(PVector[] path) {
    int sparse = 5;
    int space = 3;
    int cap = 0;
    boolean capped = false;
    float tol = 1000;
    
    for (int i = 0; i < min(cupCount, path.length - space - cap); i++) {
      if (i % sparse == 1) {
        //print("CUP" + i);
        PVector p = path[i];
        PVector p2 = path[i + space];

        Vec3D v = new Vec3D(p.x, p.y, p.z);
        Vec3D v2 = new Vec3D(p2.x, p2.y, p2.z);
        Vec3D dif = v2.sub(v);

        if (v.distanceToSquared(v2) < tol) {

          pushMatrix();

          float headingXY = dif.headingXY();//atan2(p2.y - p.y, p2.x - p.x);
          float headingXZ = dif.headingXZ();//atan2(p2.z - p.z, p2.x - p.x);
          float headingYZ = dif.headingYZ();//atan2(p2.z - p.z, p2.y - p.y);
          translate(p.x, p.y, p.z);
          rotateZ(headingXY);
          rotateY(-headingXZ);
          rotateX(-headingYZ);

          color c = wormCols.pixels[floor(random(wormCols.pixels.length))];
          fill(c);
          scale(3);
          pushMatrix();
          rotateY(-PI/2);
          scale(random(0.8, 1.2));
          
          if (!capped) scale(1.5);
          shape(!capped ? ps0614:ps0610);
          
          capped = true;
          /*
          if (i == 0) {
            shape(ps0610);
          } else {  
            shape(ps0614);
          }
          */
          //
          popMatrix();
          stroke(0, 255, 0);
          //line(0,0,0,0,0,100);
          //line(0, 0, 100, 0);

          popMatrix();
        }
      }
    }
  }


  void renderPath(PVector[] path) {
    //Draw simple path
    noFill();
    beginShape();
    //println(simplePath.length * lineComplete);
    for (int i = 10; i < path.length; i++) {
      PVector p = path[i];
      vertex(p.x * ppm, p.y * ppm, p.z * ppm * deep);
    }
    endShape();
    strokeWeight(1);
  }
}

