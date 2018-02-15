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
int strip = 25;
int stick = 126;
int button = 57;
int edge = 10;

int x = 640 + 2 * gap + stick + button / 2;
int pY = 160 + 2 * gap + strip + button / 2;
int cY = 160 + 3 * gap + strip + 3 * button / 2;

color b0 = color(100);
color bB0 = color(80);
color b1 = color(220);
color bB1 = color(20);

boolean move = true;

boolean mp = false;

int fileNum = 1;

int rangeLow = 10;
int rangeHigh = 10;
int midx = 320;
int midy = 240;
int len = 30;
byte dirP;
byte dirT;


void setup() {
  video = new Capture(this, 640, 480);
  video.start();
  
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  port = new Serial(this,Serial.list()[2], 9600);
  
  size(853, 480, P2D);
  background(0);
  
  noStroke();
  fill(255);
  rect(640, 160, 213, 3 * gap + strip + stick);
  
  strokeWeight(2);
  stroke(240);
  fill(255);
  rect(640 + gap, 160 + gap, 213 - 2 * gap, strip, edge);
  
  noStroke();
  fill(240);
  rect(640 + gap, 160 + 2 * gap + strip, stick, stick, edge);
  
  pauseI(b0, bB0);
  captureI(b0, bB0);
}

void draw() {
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
  
  if (contours.size() > 0 && mp == true) {
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
    
      if (move == true) {
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
  
  image(colorFilteredImage, src.width, 0, src.width/3, src.height/3);

  dirP = 0;
  dirT = 0;
  
  delay(100);
}

void mousePressed() {
  if (mouseX <= 640) {
    mp = true;
  
    color c = get(mouseX, mouseY);
  
    strokeWeight(2);
    stroke(240);
    fill(c);
    rect(640 + gap, 160 + gap, 213 - 2 * gap, strip, edge);
  
    int hue = int(map(hue(c), 0, 255, 0, 180));
  
    rangeLow = hue - 10;
    rangeHigh = hue + 10;
  }
  
  if (Over() == 'p') {
    if (move == true) {
      pauseI(b1, bB1);
    }
    else {
      continueI(b1, bB1);
    }
  }
  
  if (Over() == 'c') {
    captureI(b1, bB1);
  }
}

void mouseReleased() {    
  if (Over() == 'p') {
    move = !move;
    if (move == true) {
      pauseI(b0, bB0);
    }
    else {
      continueI(b0, bB0);
    }
  }
  
  if (Over() == 'c') {
    if (video.available() == true) {
      video.read();
    }
    video.save("Saved/" + fileNum + ".tif");
    
    fileNum++;
    
    captureI(b0, bB0);
  }
}

char Over() {
  if (abs(mouseX - x) <= button / 2 && abs(mouseY - pY) <= button / 2) {
    return 'p';
  }
  else if (abs(mouseX - x) <= button / 2 && abs(mouseY - cY) <= button / 2) {
    return 'c';
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
  rect(x - 11, pY - 13, 7, 26);
  fill(f);
  noStroke();
  rect(x + 4, pY - 13, 7, 26);
}

void continueI(color f, color b) {
  fill(b);
  noStroke();
  rect(x - button / 2, pY - button / 2, button, button, edge);
  
  fill(f);
  noStroke();
  triangle(x - 8, pY - 14, x - 8, pY + 14, x + 16, pY);
}

void captureI(color f, color b) {
  fill(b);
  noStroke();
  rect(x - button / 2, cY - button / 2, button, button, edge);
  
  fill(f);
  noStroke();
  ellipse(x, cY, 25, 25);
}
