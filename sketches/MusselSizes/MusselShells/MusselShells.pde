float rad = 100;

void setup() {

  size(500, 500);
}

void draw() {
  
  background(0);
  translate(width/2, height/2);
  noStroke();
  
  musselShell(mouseX, 50);
}

void musselShell(int seed, float r) {
  pushMatrix();
  randomSeed(seed);
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

