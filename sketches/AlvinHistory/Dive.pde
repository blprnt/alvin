class Dive implements Comparable {

  Date date;
  int depth;
  String opsArea;
  PVector lonLat = new PVector();

  PVector pos = new PVector();
  PVector tpos = new PVector();

  PVector rot = new PVector();
  PVector trot = new PVector();

  String pilotName;
  String observer1;
  String observer2;

  PGraphics slice;

  float life = 0;
  boolean alive = false;
  boolean stamped = false;

  float a = 60;

  color col;

  float timeFraction = 0;

  Dive() {
  }

  Dive init() {
    slice = createGraphics(int(depth * 0.1) + 5, 4, P3D);

    slice.beginDraw();
    slice.smooth(4);
    slice.background(0, 0);
    slice.endDraw();
    slice.noStroke();

    float d = map(depth, 0, 4500, 255, 0);
    col = color(255, 0, 0);

    return(this);
  }

  void clear() {
    slice.beginDraw();
    slice.background(0, 0);
    slice.endDraw();
  }

  void update() {
    pos.lerp(tpos, 0.1);
    rot.lerp(trot, 0.1);
    if (life < depth) {
      if (timeFraction < globalTimeFraction) {
        life += 25;
        if (!alive) {
          alive = true;
          diveCount ++;
        }
      }
    } 
    else {
      life = depth;
    }
  }

  void render() {

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    scale(sc);
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);

    int i = int(life);

    stroke(255);
    if (life < depth) {
      //slice.beginDraw();


      //slice.endDraw();
    } 
    else {
      if (!stamped) {
        //stamped = true;
      }
    }
    //image(slice, 0, 0);
    stroke(131, 187, 216, 100);
    rotateY(-grot.x * map(depth, 0, 2500, 0, 1));

    if (10 < 5) {
      noStroke();
      for (int j = 0; j < min(life,depth); j+=25) {
        fill(map(j, 0, 2500, 100, 20), map(j, 0, 2500, 110, 15), map(j, 0, 2500, 205, 80), a);
        rect((float)j/10, 2, 2, 2);
      }
    } 
    else {
      line(0, 0, (float)i/10, 0);
    }

    fill(col, a * 2);
    noStroke();
    rect(life * 0.1, 0, 4, 4);
    //text(depth, depth * 0.1, 0);
    popMatrix();
  }

  Dive fromTableRow(TableRow tr) {
    //0    1    2      3   4      5         6    7  8     9     10    11
    //Date,Dive,Cruise,Leg,Ch Sci,Ops  Area,Lat,Lon,Depth,Pilot,Obs 1,Obs 2
    depth = tr.getInt(8);
    pilotName = tr.getString(9).toUpperCase();
    observer1 = tr.getString(10);
    observer2 = tr.getString(11);
    lonLat.x = convertLL(tr.getString(7));
    lonLat.y = convertLL(tr.getString(6));
    try {
      date = sdf.parse(tr.getString(0));
    } 
    catch(Exception e) {
      println(e);
    }

    //a = pilotName.equals("C. VAN DOVER") ? 200:1;
    return(this);
  }
  
  int compareTo(Object o) {
    return(depth - ((Dive) o).depth);
  }
}

float convertLL(String ll) {
  String[] ins = ll.split("-");
  float r = float(ins[0]);
  if (ins.length > 1) r += float(ins[1].replaceAll("[NSWE]", ""))/ 60;
  if (ll.indexOf("S") != -1 || ll.indexOf("W") != -1) r *= -1;
  return(r);
}

