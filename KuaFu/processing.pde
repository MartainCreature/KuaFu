int getLastCount() {
  File file = new File(path);
  String names[] = file.list();
  
  int max = 0;
  for (int i = names.length - 1; i >= 0; i --) {
    int num = 0;
    
    int len = names[i].length();
    if (names[i].charAt(0) == 'K'
        && names[i].charAt(1) == ' '
        && names[i].charAt(len - 4) == '.'
        && names[i].charAt(len - 3) == 'm'
        && names[i].charAt(len - 2) == 'p'
        && names[i].charAt(len - 1) == '4') {
      
      for (int j = 2; j <= len - 5; j ++) {
        if (names[i].charAt(j) >= '0' || names[i].charAt(j) <= '9') {
          num = num * 10 + names[i].charAt(j) - '0';
        }
        else {
          break;
        }
        
        if (j == len - 5 && num > max) {
          max = num;
        }
      }
    }
  }
  
  return max;
}

void processImage() {
  opencv.loadImage(video);
  
  opencv.useColor(); 
  src = opencv.getSnapshot();
  
  opencv.blur(5); 
  
  opencv.useColor(HSB);
  
  opencv.setGray(opencv.getH().clone());
  
  opencv.inRange(hue - 5, hue + 5);
  
  colorFilteredImage = opencv.getSnapshot();
  
  contours = opencv.findContours(true, true);
}

void track() {
  if (contours.size() > 0 && selected) {
    Contour ctr = contours.get(0);
    Rectangle r = ctr.getBoundingBox();;
    boolean found = false;
    for (int i = 0; i < contours.size(); i ++) {
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
      ellipse(r.x + r.width / 2, r.y + r.height / 2, 25, 25);
      
      if (!pause.state && !joyStick.state) {
        dirP = pan((r.x + r.width / 2) - src.width / 2, 20, 60);
        dirT = tilt((r.y + r.height / 2) - src.height / 2, 20, 60);
        
        strokeWeight(5); 
        stroke(light);
        int lD = 30;
        if(dirP == lS || dirP == lF) {
          line(r.x + r.width / 2, r.y + r.height / 2, r.x + r.width / 2 - lD, r.y + r.height / 2);
        }
        else if(dirP == rS || dirP == rF) {
          line(r.x + r.width / 2, r.y + r.height / 2, r.x + r.width / 2 + lD, r.y + r.height / 2);
        }
        if(dirT == uS || dirP == uF) {
          line(r.x + r.width / 2, r.y + r.height / 2, r.x + r.width / 2, r.y + r.height / 2 - lD);
        }
        else if(dirT == dS || dirP == dF) {
          line(r.x + r.width / 2, r.y + r.height / 2, r.x + r.width / 2, r.y + r.height / 2 + lD);
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
  int t = 2;
  
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
