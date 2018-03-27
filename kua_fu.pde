//夸父
//
//以颜色作为特征的物体追踪软件
//范子睿著
//版本：2.2.0

import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.serial.*; 

Capture video;
OpenCV opencv;
Serial port;

PImage src;
PImage colorFilteredImage;
ArrayList<Contour> contours;

int hueL;
int hueH;

int lD = 30;

int x0 = 640;
int y0 = 160;

int gap = 10;

int w0 = 853 - x0 - gap * 2;
int w1 = 20;
int w2 = 48;
int w3 = 106;
int lP = 26;
int lJ = 26;
int h1 = (w0 - lP) / 2 + lP;
int h2 = w3;

int edge = 10;

byte dirP;
byte dirT;

int pX = 0;
int pY = 0;
int jX = 0;
int jY = 0;

color background = color(36);
color dark = color(60);
color light = color(240);
color pressed = color(200);

boolean moving = true;
boolean selected = false;
boolean pressingJ = false;

int fileNum = 1;

PFont font;

void setup() {
  println("KuaFu 2.2.0 by Fan Zirui");
  println();
  
  size(853, 480, P2D);
  background(0);
  
  video = new Capture(this, 640, 480);
  video.start(); 
  
  print("Using ");
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  
  port = new Serial(this,Serial.list()[2], 9600);
  
  font = createFont("font", 12);
    
  fill(background);
  noStroke();
  rect(640, 160, 213, gap + h1 + gap + h2 + gap);
  fill(0);
  noStroke();
  rect(640, 160 + gap + h1 + gap + h2 + gap, 213, 320 - gap - h1 - gap - h2 - gap);
  
  fill(255);
  textFont(font);
  textAlign(RIGHT, BOTTOM);
  text("范子睿出品", width - 8, height - 8);
  
  platformPosition();
  
  selectedColor(light);
  
  pause(true, false);
  
  capture(false);
  
  joyStick();
}

void draw() {
  if (!selected || !moving) {
    port.write(byte('!'));
  }
  
  if (video.available()) {
    video.read();
  }

  opencv.loadImage(video);

  opencv.useColor(); 
  src = opencv.getSnapshot();
  
  opencv.useColor(HSB);
  
  opencv.setGray(opencv.getH().clone());
  
  opencv.inRange(hueL, hueH);
  
  colorFilteredImage = opencv.getSnapshot();
  
  contours = opencv.findContours(true, true);
  
  image(src, 0, 0);
  
  if (contours.size() > 0 && selected) {
    Contour biggestContour = contours.get(0);
    
    Rectangle r = biggestContour.getBoundingBox();
    
    if (r.width > 20 && r.height > 20) {
      noFill(); 
      strokeWeight(3); 
      stroke(light);
      rect(r.x, r.y, r.width, r.height);
    
      noStroke(); 
      fill(light);
      ellipse(r.x + r.width/2, r.y + r.height/2, 25, 25);
    
      if (moving && !pressingJ) {
        dirP = pan((r.x + r.width / 2) - src.width / 2, 15, 50);
        dirT = tilt((r.y + r.height / 2) - src.height / 2, 15, 50);
        
        strokeWeight(5); 
        stroke(light);
        if(dirP == byte('l') || dirP == byte('L')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 - lD, r.y + r.height/2);
        }
        else if(dirP == byte('r') || dirP == byte('R')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 + lD, r.y + r.height/2);
        }
        if(dirT == byte('u') || dirP == byte('U')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 - lD);
        }
        else if(dirT == byte('d') || dirP == byte('D')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 + lD);
        }
        
        port.write(dirP);
        port.write(dirT);
      }
    }
    else {
      port.write(byte('!'));
    }
  }
  
  if (selected) {
    image(colorFilteredImage, src.width, 0, src.width/3, src.height/3);
  }
  
  strip();
  
  platformPosition();
  
  if (mousePressed) {
    if (Over() == 'p') {
      if (moving) {
        pause(true, true);
      }
      else {
        pause(false, true);
      }
    }
    
    if (Over() == 'c') {
      capture(true);
    }
  }
  else {
    if (moving) {
      pause(true, false);
    }
    else {
      pause(false, false);
    }
    
    capture(false);
  }
  
  int r0 = 3;
  int r1 = 28;
  
  if (pressingJ) {
    int x = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
    int y = y0 + gap + h1 + gap + h2 / 2;
    
    jX = constrain(mouseX - x, -w3 / 2 + lJ / 2, w3 / 2 - lJ / 2);
    jY = constrain(mouseY - y, -h2 / 2 + lJ / 2, h2 / 2 - lJ / 2);
    
    joyStick();
    
    port.write(pan(jX, r0, r1));
    port.write(tilt(jY, r0, r1));
  }
  
  if (keyPressed) {
    if (keyCode == 37) {
      jX = -(r0 + r1) / 2;
    }
    else if (keyCode == 39) {
      jX = (r0 + r1) / 2;
    }
    else {
      jX = 0;
    }
    if (keyCode == 38) {
      jY = -(r0 + r1) / 2;
    }
    else if (keyCode == 40) {
      jY = (r0 + r1) / 2;
    }
    else {
      jY = 0;
    }
    
    joyStick();
    
    port.write(pan(jX, r0, r1));
    port.write(tilt(jY, r0, r1));
  }
  else {
    jX = 0;
    jY = 0;
    
    joyStick();
  }
}

void mousePressed() {
  if (mouseX <= 640) {
    selected = true;
  
    color c = get(mouseX, mouseY);
  
    selectedColor(c);
  
    int hue = int(map(hue(c), 0, 255, 0, 180));
  
    hueL = hue - 5;
    hueH = hue + 5;
  }
  
  if (Over() == 'j') {
    pressingJ = true;
  }
}

void mouseReleased() {
  if (Over() == 'p') {
    moving = !moving;
  }
  
  if (Over() == 'c') {
    if (video.available()) {
      video.read();
    }
    video.save("照片/" + fileNum + ".tif");
    
    fileNum++;
  }
  
  pressingJ = false;
  
  jX = 0;
  jY = 0;
  joyStick();
}

void keyTyped() {
  if (key == 'p') {
    moving = !moving;
  }
  
  if (key == 'c') {
    if (video.available()) {
      video.read();
    }
    video.save("照片/" + fileNum + ".tif");
    
    fileNum++;
  }
}

byte pan(int x, int r0, int r1) {
  byte p = 0;
  
  if (x < -r1) {
    p = 'L';
    pX -= 2;
  }
  else if (x < -r0) {
    p = 'l';
    pX -= 1;
  }
  else if (x > r1) {
    p = 'R';
    pX += 2;
  }
  else if (x > r0) {
    p = 'r';
    pX += 1;
  }
  pX = constrain(pX, -90, 90);
  
  return p;
}

byte tilt(int y, int r0, int r1) {
  byte t = 0;
  
  if (y < -r1) {
    t = 'U';
    pY -= 2;
  }
  else if (y < -r0) {
    t = 'u';
    pY -= 1;
  }
  else if (y > r1) {
    t = 'D';
    pY += 2;
  }
  else if (y > r0) {
    t = 'd';
    pY += 1;
  }
  pY = constrain(pY, -45, 45);
  
  return t;
}

char Over() {
  int x1 = x0 + gap + w1 + gap + w2 / 2;
  int y1 = y0 + gap + h1 + gap + w2 / 2;
  int y2 = y0 + gap + h1 + gap + w2 + gap + w2 / 2;
  int x2 = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
  int y3 = y0 + gap + h1 + gap + w3 / 2;
  
  if (abs(mouseX - x1) <= w2 / 2 && abs(mouseY - y1) <= w2 / 2) {
    return 'p';
  }
  else if (abs(mouseX - x1) <= w2 / 2 && abs(mouseY - y2) <= w2 / 2) {
    return 'c';
  }
  else if (abs(mouseX - x2) <= w3 / 2 && abs(mouseY - y3) <= w3 / 2) {
    return 'j';
  }
  else {
    return 'n';
  }
}

void platformPosition() {
  fill(dark);
  noStroke();
  rect(x0 + gap, y0 + gap, w0, h1, edge);
  
  int x = x0 + gap + w0 / 2;
  int y = y0 + gap + h1 / 2;
  
  noFill();
  strokeWeight(2);
  stroke(light);
  rect(x - lP / 2 + pX * 0.9, y - lP / 2 + pY * 0.85, lP, lP, edge);
}

void selectedColor(color c) {
  fill(c);
  strokeWeight(2);
  stroke(dark);
  rect(x0 + gap, y0 + gap + h1 + gap, w1, h2, edge);
}

void pause(boolean s, boolean p) {
  color b;
  color f;
  if (!p) {
    b = light;
    f = background;
  }
  else {
    b = pressed;
    f = background;
  }
  
  fill(b);
  noStroke();
  rect(x0 + gap + w1 + gap, y0 + gap + h1 + gap, w2, w2, edge);
    
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + h1 + gap + w2 / 2;
  
  if (s) {
    fill(f);
    noStroke();
    rect(x - 8, y - 9, 5, 18);
    
    fill(f);
    noStroke();
    rect(x + 3, y - 9, 5, 18);
  }
  else {
    fill(f);
    noStroke();
    triangle(x - 6, y - 10, x - 6, y + 10, x + 11, y);
  }
}

void capture(boolean p) {
  color b;
  color f;
  if (!p) {
    b = light;
    f = background;
  }
  else {
    b = pressed;
    f = background;
  }
  
  fill(b);
  noStroke();
  rect(x0 + gap + w1 + gap, y0 + gap + h1 + gap + w2 + gap, w2, w2, edge);
  
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + h1 + gap + w2 + gap + w2 / 2;
  
  fill(f);
  noStroke();
  ellipse(x, y, 18, 18);
}

void joyStick() {
  fill(dark);
  noStroke();
  rect(x0 + gap + w1 + gap + w2 + gap, y0 + gap + h1 + gap, w3, w3, edge);
  
  int x = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
  int y = y0 + gap + h1 + gap + w3 / 2;
  
  fill(light);
  noStroke();
  rect(x + jX - lJ / 2, y + jY - lJ / 2, lJ, lJ, edge);
}

void strip() {
  fill(background);
  noStroke();
  rect(640, 160, 2, 320);
  fill(0);
  noStroke();
  rect(640, 160 + gap + h1 + gap + h2 + gap, 2, 320 - gap - h1 - gap - h2 - gap);
}
