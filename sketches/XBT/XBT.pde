import java.util.Date;
import java.text.SimpleDateFormat;

SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yy hh:mm:ss");

PVector focus = new PVector();
PVector tfocus = new PVector();

PVector rot = new PVector();
PVector trot = new PVector();

float depthMag = 1;
float tdepthMag = 0.1;

PVector minLonLat = new PVector(1000,1000);
PVector maxLonLat = new PVector(-1000,-1000);

ArrayList<XBTSequence> sequences = new ArrayList();
void setup() {
  size(displayWidth, displayHeight, P3D);
  for (int i = 0; i < 21; i++) {
    loadXBT("T7_" + nf(i, 5) + ".EDF");
  }
  arrangeRows();
  //arrangeMap();
  colorMode(HSB);
  
  println(minLonLat);
  println(maxLonLat);
}

void draw() {
  
  focus.lerp(tfocus, 0.1);
  rot.lerp(trot, 0.1);
  
  if (mousePressed) {
   trot.y += (mouseX - pmouseX) * -0.001; 
  }
  
  depthMag = lerp(depthMag, tdepthMag, 0.1);
  
  background(0);
  translate(focus.x, focus.y, focus.z);
  rotateX(rot.x);
  rotateY(rot.y);
  rotateZ(rot.z);
  for (XBTSequence x:sequences) {
    x.update();
    x.render();
  }
}

void arrangeRows() {
  tfocus = new PVector(width/2,height/2);
  trot.y = -PI;
  trot.x = PI - 0.3;
  tdepthMag = 1;
  for (int i = 0; i < sequences.size(); i++) {
    XBTSequence x = sequences.get(i);
    x.tpos.x = map(i, 0, sequences.size(), 50, width - 50) - width/2;
    x.tpos.y = 0;
    x.tpos.z = 0 - height/2;
    x.tw = (float)width/sequences.size();
  }
}

void loadXBT(String fileName) {

  XBTSequence xbt = new XBTSequence().fromEDF(fileName);
  sequences.add(xbt);
  if (sequences.size() > 1) xbt.chain = sequences.get(sequences.size() - 2);
}

void arrangeMap() {
  tfocus = new PVector(width/2, height/2);
  trot = new PVector();
  trot.x = -PI * 0.75;
  tdepthMag = 0.3;
  
  for(XBTSequence x:sequences) {    
    x.tpos.x = map(x.lonLat.x, minLonLat.x, maxLonLat.x, -width/2, width/2);
    x.tpos.y = map(x.lonLat.y, minLonLat.y, maxLonLat.y, -width/2, width/2);
  }
}

void keyPressed() {
 if (key == 'm') arrangeMap();
 if (key == 'l') arrangeRows();
}
