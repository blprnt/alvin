String imageDir = "/Volumes/OCR LockBox/ProxyVideo/PortRecorder/DirectProxies/stillsSmall";
int w =  4800;
PGraphics canvas;

void setup() {
  size(500, 500, P2D);
  canvas = createGraphics(w, int((w * 9.0) / 16), P2D);
}

void draw() {
  if (frameCount == 1) imageGrid();
}

void imageGrid() {
  String[] files = listFileNames(imageDir);
  int n = int(sqrt(files.length - 1));
  println(n);
  
  canvas.beginDraw();
  canvas.background(0);
  
  PImage img;
  
  int c = 1;
  float iw = canvas.width / n;
  float ih = canvas.height / n;
  
  for (int y = 0; y < n; y++) {
   for(int x = 0; x < n; x++) {
    String fn = files[c];
    img = loadImage(imageDir + "/" + fn);
    canvas.image(img, x * iw, y * ih, iw, ih);
    print(c + ".");
    c++;
   } 
  }
  

  
  canvas.endDraw();
  canvas.save("grid.jpg");
  
  image(canvas,0,0,width,height);
}

String[] listFileNames(String dir) {
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

void keyPressed() {
}

