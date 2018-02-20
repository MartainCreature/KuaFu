import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.serial.*; 

Capture video;
OpenCV opencv;
Serial port;
PImage src, colorFilteredImage;
ArrayList<Contour> contours;

int gap = 10;
int strip = 20;
int stick = 106;
int button = 48;
int handle = 26;
int edge = 10;
int lH = 25;
int l0 = 10;

int x = 640 + 2 * gap + strip + button / 2;
int pY = 160 + gap + button / 2;
int cY = 160 + 2 * gap + 3 * button / 2;
int sX = 640 + 3 * gap + strip + button + stick / 2;
int sY = 160 + gap + stick / 2;
int tY = 160 + 2 * gap + stick;

int mX, mY;

color b0 = color(35);
color bB0 = color(240);
color b1 = color(35);
color bB1 = color(200);

boolean move = true;
boolean mp = false;
boolean mP = false;
boolean bs;

int fileNum = 1;

int rangeLow = 10;
int rangeHigh = 10;
int midx = 320;
int midy = 240;
int len = 30;

byte dirP, dirT;

int[] ntf = new int[3];
String s1 = "请检查云台连接";
String s2 = "请单击图像以选择颜色";

PFont font;

int i, j;

void setup() {
  video = new Capture(this, 640, 480);
  video.start(); 
  
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  port = new Serial(this,Serial.list()[2], 9600);
  
  size(853, 480, P2D);
  background(0);
  
  noStroke();
  fill(36);
  rect(640, 160, 213, 2 * gap + stick);
  
  strokeWeight(2);
  stroke(60);
  fill(255);
  rect(640 + gap, 160 + gap, strip, stick, edge);
  
  noStroke();
  fill(60);
  rect(640 + 3 * gap + strip + button, 160 + gap, stick, stick, edge);
  noStroke();
  fill(240);
  rect(640 + 3 * gap + strip + button + stick / 2 - handle / 2, 160 + gap + stick / 2 - handle / 2, handle, handle, edge);
  
  pauseI(b0, bB0);
  captureI(b0, bB0);
  
  font = createFont("font", 16);
}

void draw() {
  if (Serial.list().length < 5) {
    bs = false;
    for (i = 0; i < 3; i++) {
      if (ntf[i] == 1) {
        bs = true;
        break;
      }
    }
    if (!bs) {
      ntf[2] = 1;
    }
    
    update();
  }
  else {
    for (i = 0; i < 3; i++) {
      if (ntf[i] == 1) {
        ntf[i] = 0;
        break;
      }
    }
    
    update();
  }
  
  if (!mp) {
    bs = false;
    for (i = 0; i < 3; i++) {
      if (ntf[i] == 2) {
        bs = true;
        break;
      }
    }
    if (!bs) {
      ntf[2] = 2;
    }
    
    update();
    
    port.write(byte('!'));
  }
  else {
    for (i = 0; i < 3; i++) {
      if (ntf[i] == 2) {
        ntf[i] = 0;
        break;
      }
    }
    
    update();
  }
  
  if (video.available()) {
    video.read();
  }

  opencv.loadImage(video);

  opencv.useColor(); 
  src = opencv.getSnapshot();
  
  opencv.useColor(HSB);
  
  opencv.setGray(opencv.getH().clone());
  
  opencv.inRange(rangeLow, rangeHigh);
  
  colorFilteredImage = opencv.getSnapshot();
  
  contours = opencv.findContours(true, true);
  
  image(src, 0, 0);
  
  if (contours.size() > 0 && mp) {
    Contour biggestContour = contours.get(0);
    
    Rectangle r = biggestContour.getBoundingBox();
    
    if(r.width >= 20 & r.height >= 20) {
      noFill(); 
      strokeWeight(3); 
      stroke(240);
      rect(r.x, r.y, r.width, r.height);
    
      noStroke(); 
      fill(240);
      ellipse(r.x + r.width/2, r.y + r.height/2, 25, 25);
    
      if (r.x + r.width/2 < midx - 50) {
        dirP = byte('L');  
      } else if (r.x + r.width/2 < midx - 20) {
        dirP = byte('l');
      }      
      else if (r.x + r.width/2 > midx + 50) {
        dirP = byte('R');
      } else if (r.x + r.width/2 > midx + 20) {
        dirP = byte('r');
      }
      if (r.y + r.height/2 < midy - 50) {
        dirT = byte('U');
      } else if (r.y + r.height/2 < midy - 20) {
        dirT = byte('u');
      }
      else if (r.y + r.height/2 > midy + 50) {
        dirT = byte('D');
      } else if (r.y + r.height/2 > midy + 20) {
        dirT = byte('d');
      }
      else {
        port.write(byte('0'));
      }
    
      if (move && !mP) {
        port.write(dirP);
        port.write(dirT);
    
        strokeWeight(5); 
        stroke(240, 240, 240);
        if(dirP == byte('l') || dirP == byte('L')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 - len, r.y + r.height/2);
        }
        else if(dirP == byte('r') || dirP == byte('R')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2 + len, r.y + r.height/2);
        }
        if(dirT == byte('u') || dirP == byte('U')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 - len);
        }
        else if(dirT == byte('d') || dirP == byte('D')) {
          line(r.x + r.width/2, r.y + r.height/2, r.x + r.width/2, r.y + r.height/2 + len);
        }
      }
    } 
    else {
      port.write(byte('!'));
    }
  }
  
  if (mp) {
    image(colorFilteredImage, src.width, 0, src.width/3, src.height/3);
  }

  dirP = 0;
  dirT = 0;
  
  if (!move && mousePressed) {
    int a1 = 28;
    int a0 = 3;
    if (mX - sX < -a1) {
      port.write(byte('L'));  
    } else if (mX - sX < -a0) {
      port.write(byte('l'));
    }     
    else if (mX - sX > a1) {
      port.write(byte('R'));
    } else if (mX - sX > a0) {
      port.write(byte('r'));
    }
    if (mY - sY < -a1) {
      port.write(byte('U'));
    } else if (mY - sY < -a0) {
      port.write(byte('u'));
    }
    else if (mY - sY > a1) {
      port.write(byte('D'));
    } else if (mY - sY > a0) {
      port.write(byte('d'));
    }
  }
}

void mousePressed() {
  if (mouseX <= 640) {
    mp = true;
  
    color c = get(mouseX, mouseY);
  
    strokeWeight(2);
    stroke(60);
    fill(c);
    rect(640 + gap, 160 + gap, strip, stick, edge);
  
    int hue = int(map(hue(c), 0, 255, 0, 180));
  
    rangeLow = hue - 10;
    rangeHigh = hue + 10;
  }
  
  if (Over() == 'p') {
    if (move) {
      pauseI(b1, bB1);
    }
    else {
      continueI(b1, bB1);
    }
  }
  
  if (Over() == 'c') {
    captureI(b1, bB1);
  }
  
  if (Over() == 's') {
    mP = true;  
    
    mX = constrain(mouseX, sX - stick / 2 + (handle + 1) / 2, sX + stick / 2 - (handle + 1) / 2);
    mY = constrain(mouseY, sY - stick / 2 + (handle + 1) / 2, sY + stick / 2 - (handle + 1) / 2);
    
    noStroke();
    fill(60);
    rect(640 + 3 * gap + strip + button, 160 + gap, stick, stick, edge);
    noStroke();
    fill(240);
    rect(mX - handle / 2, mY - handle / 2, handle, handle, edge);
  }
}

void mouseReleased() {    
  if (Over() == 'p') {
    move = !move;
    if (move) {
      pauseI(b0, bB0);
    }
    else {
      continueI(b0, bB0);
    }
  }
  
  if (Over() == 'c') {
    if (video.available()) {
      video.read();
    }
    video.save("Saved/" + fileNum + ".tif");
    
    fileNum++;
    
    captureI(b0, bB0);
  }
  
  mP = false;
  noStroke();
  fill(60);
  rect(640 + 3 * gap + strip + button, 160 + gap, stick, stick, edge);
  noStroke();
  fill(240);
  rect(640 + 3 * gap + strip + button + stick / 2 - handle / 2, 160 + gap + stick / 2 - handle / 2, handle, handle, edge);
}

void mouseDragged() {
  if (mP) {
    mX = constrain(mouseX, sX - stick / 2 + (handle + 1) / 2, sX + stick / 2 - (handle + 1) / 2);
    mY = constrain(mouseY, sY - stick / 2 + (handle + 1) / 2, sY + stick / 2 - (handle + 1) / 2);
    
    noStroke();
    fill(60);
    rect(640 + 3 * gap + strip + button, 160 + gap, stick, stick, edge);
    noStroke();
    fill(240);
    rect(mX - handle / 2, mY - handle / 2, handle, handle, edge);
  }
}

char Over() {
  if (abs(mouseX - x) <= button / 2 && abs(mouseY - pY) <= button / 2) {
    return 'p';
  }
  else if (abs(mouseX - x) <= button / 2 && abs(mouseY - cY) <= button / 2) {
    return 'c';
  }
  else if (abs(mouseX - sX) <= stick / 2 && abs(mouseY - sY) <= stick / 2) {
    return 's';
  }
  else {
    return 'n';
  }
}

void pauseI(color f, color b) {
  fill(b);
  noStroke();
  rect(x - button / 2, pY - button / 2, button, button, edge);
  
  fill(f);
  noStroke();
  rect(x - 8, pY - 9, 5, 18);
  
  fill(f);
  noStroke();
  rect(x + 3, pY - 9, 5, 18);
}

void continueI(color f, color b) {
  fill(b);
  noStroke();
  rect(x - button / 2, pY - button / 2, button, button, edge);
  
  fill(f);
  noStroke();
  triangle(x - 6, pY - 10, x - 6, pY + 10, x + 11, pY);
}

void captureI(color f, color b) {
  fill(b);
  noStroke();
  rect(x - button / 2, cY - button / 2, button, button, edge);
  
  fill(f);
  noStroke();
  ellipse(x, cY, 18, 18);
}

void update() {
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 2; j++) {
      if (ntf[j] == 0) {
        ntf[j] = ntf[j + 1];
        ntf[j + 1] = 0;
      }
    }
  }
  
  noStroke();
  fill(0);
  rect(640, tY, 213, 320);
  
  noStroke();
  fill(36);
  rect(640, 160, 2, tY - 160);
  
  for (i = 0; i < 3; i++) {
    if (ntf[i] == 0) {
      break;
    }
    
    String sn = "";
    if (ntf[i] == 1) {
      sn = s1;
    }
    if (ntf[i] == 2) {
      sn = s2;
    }
    
    textFont(font, 16);
    fill(255);
    text(sn, 640 + l0, tY + l0 + i * lH, 213 - l0, 320 - 2 * gap - stick - l0 - i * lH);
  }
}
