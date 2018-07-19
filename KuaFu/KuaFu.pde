//夸父
//
//采用颜色特征的物体实时跟踪软件
//范子睿
//版本 3.6.2

String ver = "3.6.2";

import processing.video.*;
import gab.opencv.*;
import com.hamoid.*;
import java.awt.Rectangle;
import processing.serial.*;

Capture video;
OpenCV opencv;
VideoExport videoExport;
Serial port;

int hue;
PImage src;
PImage colorFilteredImage;

ArrayList<Contour> contours;
int rX, rY;
int rW, rH;

byte message;
int lMessage;
int dirP, dirT;
int lF = 4;
int lS = 3;
int rS = 1;
int rF = 0;
int uF = 4;
int uS = 3;
int dS = 1;
int dF = 0;

boolean selected = false;

String path = "/Documents/夸父";
String prefix = "K ";
int count = 1;

int gap = 10;
color background = color(36);
color dark = color(60);
color light = color(240);
color pressed = color(200);
PFont font;

PointMap camera;
Palette palette;
Button pause;
Button record;
Button changePath;
JoyStick joyStick;
Text absolutePath;

void setup() {
  println("KuaFu " + ver + " by Fan Zirui");
  println();
  
  size(853, 480, P2D);
  pixelDensity(displayDensity());
  surface.setTitle("夸父 " + ver);
  background(0);
  
  path = System.getProperty("user.home") + path + "/视频";
  
  video = new Capture(this, 640, 480);
  video.start(); 
  
  print("Using ");
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  println();
  
  videoExport = new VideoExport(this, "", video);
  videoExport.setDebugging(false);
  videoExport.setFfmpegPath(sketchPath() + "/ffmpeg");

  port = new Serial(this, Serial.list()[2], 9600);
  
  font = createFont("", 12);
  
  camera = new PointMap(video.width + gap,
                        int(video.height / 3) + gap,
                        int(video.width / 3) - gap * 2,
                        (int(video.width / 3) - gap * 2 - 10) / 2 + 10,
                        0.5,
                        0.9);
  palette = new Palette(video.width + gap,
                        int(video.height / 3) + gap + camera.height + gap,
                        20,
                        106);
  pause = new Button(video.width + gap + palette.width + gap,
                     int(video.height / 3) + gap + camera.height + gap,
                     48,
                     48,
                     true, "pause");
  record = new Button(video.width + gap + palette.width + gap,
                      int(video.height / 3) + gap + camera.height + gap + pause.height + gap,
                      48,
                      48,
                      true, "record");
  changePath = new Button(video.width + int(video.width / 3) - gap - 20,
                          int(video.height / 3) + gap + camera.height + gap + palette.height + gap + gap + 1,
                          20,
                          14,
                          false, "change");
  joyStick = new JoyStick(video.width + gap + palette.width + gap + pause.width + gap,
                          int(video.height / 3) + gap + camera.height + gap,
                          palette.height,
                          palette.height);
  absolutePath = new Text(video.width + gap,
                          int(video.height / 3) + gap + camera.height + gap + palette.height + gap + gap,
                          int(video.width / 3) - gap * 2,
                          480);
  
  pause.x1A += 1;
  pause.y1A += 1;
  pause.x2A += 2;
  pause.y2A -= 1;
  record.x1A -= 1;
  record.y1A -= 1;
  record.x2A += 2;
  record.y2A += 2;
  
  canvas();
  
  noStroke();
  fill(dark);
  rect(camera.x0, camera.y0, camera.width, camera.height, camera.edge);
  
  palette.display();
  pause.display(false);
  record.display(false);
  changePath.display(false);
  joyStick.display();
  absolutePath.display("保存路径\n" + path);
  
  count = getLastCount() + 1;
  
  port.write(byte(5));
}

void draw() {
  if (!selected || pause.state) {
    port.write(byte(9));
  }
  
  if (video.available()) {
    video.read();
  }
  
  processImage();
  
  image(src, 0, 0);
  
  if (selected) {
    image(colorFilteredImage, src.width, 0, src.width / 3, src.height / 3);
  }
  
  track();
  
  canvas();
  
  if (mousePressed && camera.over()) {
    camera.display(1);
    
    float pP = 1 - (constrain(mouseX - camera.x0, camera.pL / 2, camera.width - camera.pL / 2) - camera.pL / 2) * 1.0 / (camera.width - camera.pL);
    float pT = 1 - (constrain(mouseY - camera.y0, camera.pL / 2, camera.height - camera.pL / 2) - camera.pL / 2) * 1.0 / (camera.height - camera.pL);
    if (pP >= 1) {
      pP -= 0.01;
    }
    if (pT >= 1) {
      pT -= 0.01;
    }
      
    lMessage = 100 + int(pP * 10) * 10 + int(pT * 10);
    
    port.write(lMessage);
  }
  else {
    camera.display(0);
  }
  camera.opa -= 64;
  if (camera.opa < 0) {
    camera.opa = 0;
  }
  
  palette.display();
  absolutePath.display("保存路径\n" + path);
  
  pause.display(mousePressed && !joyStick.state && pause.over());
  record.display(mousePressed && !joyStick.state && record.over());
  changePath.display(mousePressed && !joyStick.state && changePath.over());
  
  manualEvent();
  
  joyStick.display();
  
  setCursor();
  
  if (record.state) {
    videoExport.saveFrame();
  }
  
  if (joyStick.state) {
    message = byte(pan(joyStick.sX - joyStick.xM, joyStick.r0, joyStick.r1) * 10
                   + tilt(joyStick.sY - joyStick.yM, joyStick.r0, joyStick.r1));
    
    port.write(message);
  }
  
  delay(50);
}
