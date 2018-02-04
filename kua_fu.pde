import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.serial.*; 

Capture video;
OpenCV opencv;
Serial port;
PImage src, colorFilteredImage;
ArrayList<Contour> contours;

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
  
  if (contours.size() > 0) {
    Contour biggestContour = contours.get(0);
    
    Rectangle r = biggestContour.getBoundingBox();
    
    if(r.width >= 20 & r.height >= 20) {
      noFill(); 
      strokeWeight(3); 
      stroke(240, 240, 240);
      rect(r.x, r.y, r.width, r.height);
    
      noStroke(); 
      fill(240, 240, 240);
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
  
  color c = get(mouseX, mouseY);
  
  int hue = int(map(hue(c), 0, 255, 0, 180));
  
  rangeLow = hue - 10;
  rangeHigh = hue + 10;
}