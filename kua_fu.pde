//夸父
//
//以颜色作为特征的物体追踪软件
//范子睿著
//版本 3.1.1

import processing.video.*;
import gab.opencv.*;
import com.hamoid.*;
import java.awt.Rectangle;
import processing.serial.*; 

Capture video;
OpenCV opencv;
VideoExport videoExport;
Serial port;

PImage src;
PImage colorFilteredImage;
ArrayList<Contour> contours;

int hueL;
int hueH;

int rX;
int rY;
int rW;
int rH;

int lD = 30;

int x0 = 640;
int y0 = 160;

int gap = 10;

int w1 = 20;
int w2 = 48;
int w3 = 106;
int lP = 26;
int lJ = 26;
int h1 = w3;

int edge = 10;

byte message;
int dirP;
int dirT;

int lF = 4;
int lS = 3;
int rS = 1;
int rF = 0;
int uF = 4;
int uS = 3;
int dS = 1;
int dF = 0;

int pX = 0;
int pY = 0;

int jX = 0;
int jY = 0;

color background = color(36);
color dark = color(60);
color light = color(240);
color pressed = color(200);

boolean moving = true;
boolean recording = false;
boolean selected = false;
boolean pressingJ = false;

String path = "视频/";
String prefix = "KF";
int time = month() * 1000000 + day() * 10000 + hour() * 100 + minute();
int count = 1;

PFont font;

void setup() {
  println("KuaFu 3.1.1 by Fan Zirui");
  println();
  
  size(853, 480, P2D);
  background(0);
  
  video = new Capture(this, 640, 480);
  video.start(); 
  
  print("Using ");
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  println();
  
  videoExport = new VideoExport(this, "", video);
  videoExport.setDebugging(false);
  
  port = new Serial(this,Serial.list()[2], 9600);
  
  font = createFont("font", 12);
    
  fill(background);
  noStroke();
  rect(640, 160, 213, gap + h1 + gap);
  fill(0);
  noStroke();
  rect(640, 160 + gap + h1 + gap, 213, 320 - gap - h1 - gap);
  
  fill(255);
  textFont(font);
  textAlign(RIGHT, BOTTOM);
  text("范子睿出品", width - 8, height - 8);
    
  selectedColor(light);
  
  pause(true, false);
  
  record(false, false);
  
  joyStick();
}

void draw() {
  if (!selected || !moving) {
    port.write(byte(9));
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
    Contour ctr = contours.get(0);
    Rectangle r = ctr.getBoundingBox();;
    boolean found = false;
    for (int i = 0; i < contours.size(); i++) {
      ctr = contours.get(i);
    
      r = ctr.getBoundingBox();
      
      if ((r.x - (rX + rW)) * ((r.x + r.width) - rX) <= 0 && (r.y - (rY + rH)) * ((r.y + r.height) - rY) <= 0 && r.width > 20 && r.height > 20) {
        found = true;
        
        rX = r.x;
        rY = r.y;
        rW = r.width;
        rH = r.height;
        
        break;
      }
    }
    
    if (found) {
      noFill(); 
      strokeWeight(3); 
      stroke(light);
      rect(r.x, r.y, r.width, r.height);
    
      noStroke(); 
      fill(light);
      ellipse(r.x + r.width/2, r.y + r.height/2, 25, 25);
    
      if (moving && !pressingJ) {
        dirP = pan((r.x + r.width / 2) - src.width / 2, 25, 50);
        dirT = tilt((r.y + r.height / 2) - src.height / 2, 25, 50);
        
        strokeWeight(5); 
        stroke(light);
        if(dirP == lS || dirP == lF) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 - lD, r.y + r.height/2);
        }
        else if(dirP == rS || dirP == rF) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 + lD, r.y + r.height/2);
        }
        if(dirT == uS || dirP == uF) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 - lD);
        }
        else if(dirT == dS || dirP == dF) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 + lD);
        }
        
        message = byte(dirP * 10 + dirT);
        
        port.write(message);
      }
    }
    else {
      rX = 0;
      rY = 0;
      rW = src.width;
      rH = src.height;
      
      port.write(byte(9));
    }
  }
  
  if (selected) {
    image(colorFilteredImage, src.width, 0, src.width/3, src.height/3);
  }
  
  strip();
    
  if (mousePressed) {
    if (Over() == 'p') {
      if (moving) {
        pause(true, true);
      }
      else {
        pause(false, true);
      }
    }
    
    if (Over() == 'r') {
      if (recording) {
        record(true, true);
      }
      else {
        record(false, true);
      }
    }
  }
  else {
    if (moving) {
      pause(true, false);
    }
    else {
      pause(false, false);
    }
    
    if (recording) {
      record(true, false);
    }
    else {
      record(false, false);
    }
  }
  
  int r0 = 3;
  int r1 = 28;
  
  if (pressingJ) {
    int x = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
    int y = y0 + gap + h1 / 2;
    
    jX = constrain(mouseX - x, -w3 / 2 + lJ / 2, w3 / 2 - lJ / 2);
    jY = constrain(mouseY - y, -h1 / 2 + lJ / 2, h1 / 2 - lJ / 2);
    
    joyStick();
    
    message = byte(pan(jX, r0, r1) * 10 + tilt(jY, r0, r1));
    
    port.write(message);
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
    
    message = byte(pan(jX, r0, r1) * 10 + tilt(jY, r0, r1));
    
    port.write(message);
  }
  else {
    jX = 0;
    jY = 0;
    
    joyStick();
  }
  
  if (recording) {
    videoExport.saveFrame();
  }
  
  delay(10);
}

void mousePressed() {
  if (mouseX <= 640) {
    selected = true;
  
    color c = get(mouseX, mouseY);
  
    selectedColor(c);
  
    int hue = int(map(hue(c), 0, 255, 0, 180));
    println(hue + " selected.");
  
    hueL = hue - 5;
    hueH = hue + 5;
    
    rX = mouseX;
    rY = mouseY;
    rW = 0;
    rH = 0;
  }
  
  if (Over() == 'j') {
    pressingJ = true;
  }
}

void mouseReleased() {
  if (Over() == 'p') {
    moving = !moving;
  }
  
  if (Over() == 'r') {
    recording = !recording;
    
    if (recording) {
      videoExport.setMovieFileName(path + prefix + time + "_" + count + ".mp4");
      videoExport.startMovie();
      
      count++;
    }
    else {
      videoExport.endMovie();
    }
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
  
  if (key == 'r') {
    recording = !recording;

    if (recording) {
      videoExport.setMovieFileName(path + prefix + time + "_" + count + ".mp4");
      videoExport.startMovie();
      
      count++;
    }
    else {
      videoExport.endMovie();
    }
  }
}

int pan(int x, int r0, int r1) {
  int p = 2;
  
  if (x < -r1) {
    p = lF;
  }
  else if (x < -r0) {
    p = lS;
  }
  else if (x > r1) {
    p = rF;
  }
  else if (x > r0) {
    p = rS;
  }
  
  return p;
}

int tilt(int y, int r0, int r1) {
  int t = 0;
  
  if (y < -r1) {
    t = uF;
  }
  else if (y < -r0) {
    t = uS;
  }
  else if (y > r1) {
    t = dF;
  }
  else if (y > r0) {
    t = dS;
  }
  
  return t;
}

char Over() {
  int x1 = x0 + gap + w1 + gap + w2 / 2;
  int y1 = y0 + gap + w2 / 2;
  int y2 = y0 + gap + w2 + gap + w2 / 2;
  int x2 = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
  int y3 = y0 + gap + w3 / 2;
  
  if (abs(mouseX - x1) <= w2 / 2 && abs(mouseY - y1) <= w2 / 2) {
    return 'p';
  }
  else if (abs(mouseX - x1) <= w2 / 2 && abs(mouseY - y2) <= w2 / 2) {
    return 'r';
  }
  else if (abs(mouseX - x2) <= w3 / 2 && abs(mouseY - y3) <= w3 / 2) {
    return 'j';
  }
  else {
    return 'n';
  }
}

void selectedColor(color c) {
  fill(c);
  strokeWeight(2);
  stroke(dark);
  rect(x0 + gap, y0 + gap, w1, h1, edge);
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
  rect(x0 + gap + w1 + gap, y0 + gap, w2, w2, edge);
    
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + w2 / 2;
  
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

void record(boolean s, boolean p) {
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
  rect(x0 + gap + w1 + gap, y0 + gap + w2 + gap, w2, w2, edge);
  
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + w2 + gap + w2 / 2;
  
  if (s) {
    fill(f);
    noStroke();
    rect(x - 7, y - 7, 15, 15, 2);
  }
  else {
    fill(f);
    noStroke();
    ellipse(x, y, 18, 18);
  }
}

void joyStick() {
  fill(dark);
  noStroke();
  rect(x0 + gap + w1 + gap + w2 + gap, y0 + gap, w3, w3, edge);
  
  int x = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
  int y = y0 + gap + w3 / 2;
  
  fill(light);
  noStroke();
  rect(x + jX - lJ / 2, y + jY - lJ / 2, lJ, lJ, edge);
}

void strip() {
  fill(background);
  noStroke();
  rect(640, 160, 20, 320);
  fill(0);
  noStroke();
  rect(640, 160 + gap + h1 + gap, 20, 320 - gap - h1 - gap);
  
  color c = get(x0 + gap + w1 / 2, y0 + gap + h1 / 2);
  selectedColor(c);
}
