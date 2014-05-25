/*

 // This is a MK21 EXPORT DATA FILE  (EDF)
 //
 Date of Launch:  05/23/2014
 Time of Launch:  22:27:09
 Sequence #    :  6
 Latitude      :  28 52.3313N
 Longitude     :  88 51.30762W
 Serial #      :  00000000
 
 Entries start at line 34
 Depth (m) - Temperature (°C) - Sound Velocity (m/s)
 
 */

class XBTSequence {

  Date date;
  int sequence;
  PVector lonLat = new PVector();

  ArrayList<PVector> readings = new ArrayList();

  PVector pos = new PVector();
  PVector tpos = new PVector();

  float w = 0;
  float tw = 0;

  XBTSequence chain;
  
  int life = 0;



  void update() {
    pos.lerp(tpos, 0.1);
    w = lerp(w, tw, 0.1);
    life += 10;
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    fill(255);
    sphere(5);
    fill(255);
    rotate(PI/2);
    text(sequence + " " + date, 30, 0);
    popMatrix();
    for (int i = 0; i < min(life,readings.size()); i++) {
      PVector reading = readings.get(i);
      float c = map(reading.y, 0, 30, 120, 0);
      stroke(c, 255, 255);
      if (chain != null) {
        line(pos.x, pos.y - (c * 10) + 50, pos.z + (reading.x * depthMag), chain.pos.x, chain.pos.y - (c * 10) + 50, pos.z + (reading.x * depthMag));
      }
    }
    
  }

  XBTSequence fromEDF(String fileName) {
    String[] ins = loadStrings(fileName);
    try {
      date = sdf.parse(ins[2].split(":  ")[1] + " " + ins[3].split(":  ")[1]);
    }
    catch (Exception e) {
      println(e);
    }

    sequence = int(ins[4].split(":  ")[1]);
    lonLat.x = convertLL(ins[5].split(":  ")[1]);
    lonLat.y = convertLL(ins[6].split(":  ")[1]);

    println(lonLat);

    minLonLat.x = min(lonLat.x, minLonLat.x);
    minLonLat.y = min(lonLat.y, minLonLat.y);

    maxLonLat.x = max(lonLat.x, maxLonLat.x);
    maxLonLat.y = max(lonLat.y, maxLonLat.y);

    for (int i = 33; i < ins.length; i++) {
      String[] cols = split(ins[i], TAB);
      PVector reading = new PVector(float(cols[0]), float(cols[1]), float(cols[2]));
      readings.add(reading);
    }

    return(this);
  }
}

float convertLL(String ll) {
  String[] ins = ll.split(" ");
  float r = float(ins[0]);
  if (ins.length > 1) r += float(ins[1].replaceAll("[NSWE]", ""))/ 60;
  if (ll.indexOf("S") != -1 || ll.indexOf("W") != -1) r *= -1;
  return(r);
}

