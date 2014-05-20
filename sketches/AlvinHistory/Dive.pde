class Dive {

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

  float a = 200;

  color col;

  Dive() {
    col = (random(100) > 100) ? 255:#FF0000;
  }

  void update() {
    pos.lerp(tpos, 0.1);
    rot.lerp(trot, 0.1);
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);

    stroke(255);
    for (int i = 0; i < depth; i+=10) {
      stroke(map(i, 0, 2500, 150, 20), map(i, 0, 2500, 130, 15), map(i, 0, 2500, 255, 80), a);
      point((float)i/10, 0);
    }
    fill(col, a * 2);
    noStroke();
    ellipse(depth * 0.1, 0, 2, 2);
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
    println(pilotName);
    try {
      date = sdf.parse(tr.getString(0));
    } 
    catch(Exception e) {
      println(e);
    }

    //a = pilotName.equals("C. VAN DOVER") ? 200:1;
    return(this);
  }
}

float convertLL(String ll) {
  String[] ins = ll.split("-");
  float r = float(ins[0]);
  if (ins.length > 1) r += float(ins[1].replaceAll("[NSWE]",""))/ 60;
  if (ll.indexOf("S") != -1 || ll.indexOf("W") != -1) r *= -1;
  println(r);
  return(r);
}

