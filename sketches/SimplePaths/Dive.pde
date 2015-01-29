class Dive {

  PVector[] simplePath;
  PVector[] ascent;
  PVector[] descent;

  float ppm = 1;
  float deep = 1;

  PVector off = new PVector();
  PVector toff = new PVector();


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
      println(p.z);
      if (p.z > startTol && !started) {
        started = true;
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

    ascent = new PVector[temp.size()];
    for (int j = 0; j < temp.size(); j++) {
      ascent[j] = temp.get(j);
    }
  }

  void update() {
  }

  void render() {
    
    off.lerp(toff, 0.1);

    pushMatrix();
    translate(-off.x, -off.y, -off.z);
    stroke(0, 100);
    strokeWeight(1);
    renderPath(simplePath);

    stroke(255, 0, 0);
    strokeWeight(3);
    renderPath(descent);

    stroke(0, 0, 255);
    strokeWeight(3);
    renderPath(ascent);
    popMatrix();
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

