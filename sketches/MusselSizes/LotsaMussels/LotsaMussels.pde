ArrayList<Mussel> mussels = new ArrayList();

float sf = 0.5;

void setup() {
  size(displayWidth, displayHeight, P3D);
  loadMussels("MusselSizes.csv");
  scatter();
}

void draw() {
  background(0);
  translate(width/2, height/2);
  for(Mussel m:mussels) {
   m.update();
   m.render(); 
  }
}

void loadMussels(String url) {
  Table t = loadTable(url, "header");
  for (TableRow tr:t.rows()) {
    Mussel m = new Mussel();
    m.dims.x = tr.getFloat("width") * sf;
    m.dims.y = tr.getFloat("length") * sf;
    m.dims.z = tr.getFloat("height") * sf;
    if (tr.getString("width").length() > 0 && tr.getString("height").length() > 0 && tr.getString("length").length() > 0) mussels.add(m);
  }
}

void scatter() {
 for(Mussel m:mussels) {
  m.tpos.set(random(m.dims.x/2, width - m.dims.x/2) - width/2, random(m.dims.y/2, height - m.dims.y/2) - height/2);
 } 
}

void lineUp() {
 float x = -width/2 + 50;
 float y = - height/2 + 200; 
 for (Mussel m:mussels) {
  m.tpos.set(x,y);
  x += m.dims.x; 
  if (x > width/2 - 50) {
    x = -width/2 + 50;
    y += 200;
  }
  
 }
}

void keyPressed() {
 if (key == 'x') scatter(); 
 if (key == 'l') lineUp(); 
 if (key == 'o') {
  java.util.Collections.sort(mussels);
  java.util.Collections.reverse(mussels);
  lineUp(); 
 }
}

class Mussel implements Comparable{
 
  PVector dims = new PVector();
  PVector pos = new PVector();
  PVector tpos = new PVector();
  
  void update() {
    pos.lerp(tpos, 0.1);
  }
  
  void render() {
    noFill();
    stroke(255,105);
    pushMatrix();
      translate(pos.x, pos.y, pos.z);
      //box(dims.x, dims.y, dims.z);
      musselShell(10, dims.y);
    popMatrix();
  }
  
  int compareTo(Object o) {
    Mussel m = (Mussel) o;
    return(int(dims.y * dims.x * dims.z) - int(m.dims.y * m.dims.x * m.dims.z));
  }
  
}

void musselShell(int seed, float r) {
  pushMatrix();
  randomSeed(seed);
  noStroke();
 float distort = random(0.8,1.2);
  for(int i = 0; i < 10; i++) {
    fill(map(i, 0, 10, 100, 255));
    shell(r, 1.1, distort);
    r -= 3;
    translate(0,2);
  } 
  
  popMatrix();
}



void shell(float r, float vs, float hs) {
  
  beginShape();
  PVector p = null;
  for (int i = 0; i < 10; i++) {
    float th = map(i, 0, 10, 0, TAU);
    p = new PVector(sin(th * vs) * r * vs, cos(th * hs) * r * hs);
    //ellipse(p.x, p.y, 5, 5);;
    if (i == 0) curveVertex(p.x * vs, p.y * hs);
    curveVertex(p.x, p.y);
  }
  curveVertex(p.x, p.y);
  curveVertex(p.x, p.y);

  endShape();
  
}
