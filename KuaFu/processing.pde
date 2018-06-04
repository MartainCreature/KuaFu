void processImage() {
  opencv.loadImage(video);

  opencv.useColor(); 
  src = opencv.getSnapshot();
  
  opencv.blur(5); 
  
  opencv.useColor(HSB);
  
  opencv.setGray(opencv.getH().clone());
  
  opencv.inRange(hueL, hueH);
  
  colorFilteredImage = opencv.getSnapshot();
  
  contours = opencv.findContours(true, true);
}

void track() {
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
    
      if (!pause.state && !joyStick.state) {
        dirP = pan((r.x + r.width / 2) - src.width / 2, 20, 60);
        dirT = tilt((r.y + r.height / 2) - src.height / 2, 20, 60);
        
        strokeWeight(5); 
        stroke(light);
        int lD = 30;
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
}

int pan(int x, int r0, int r1) {
  int p = 2;
  
  if (x < -r1) {
    p = lF;
    cameraAngle.pX -= 2;
  }
  else if (x < -r0) {
    p = lS;
    cameraAngle.pX -= 1;
  }
  else if (x > r1) {
    p = rF;
    cameraAngle.pX += 2;
  }
  else if (x > r0) {
    p = rS;
    cameraAngle.pX += 1;
  }
  
  return p;
}

int tilt(int y, int r0, int r1) {
  int t = 2;
  
  if (y < -r1) {
    t = uF;
    cameraAngle.pY -= 2;
  }
  else if (y < -r0) {
    t = uS;
    cameraAngle.pY -= 1;
  }
  else if (y > r1) {
    t = dF;
    cameraAngle.pY += 2;
  }
  else if (y > r0) {
    t = dS;
    cameraAngle.pY += 1;
  }
    
  return t;
}
