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
        int dX = (r.x + r.width / 2) - src.width / 2;
        int dY = (r.y + r.height / 2) - src.height / 2;
        
        float scale = 0.5;
        
        int xL = int(dX * scale);
        int yL = int(dY * scale);
        
        strokeWeight(5); 
        stroke(light);
        line(r.x + r.width / 2, r.y + r.height / 2, 
             constrain(r.x + r.width / 2 + xL, 0, src.width), r.y + r.height / 2);
        line(r.x + r.width / 2, r.y + r.height / 2, 
             r.x + r.width / 2, r.y + r.height / 2 + yL);
        
        message = msg(dX, dY, src.width / 2, src.height / 2);
        
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

byte msg(int x, int y, int xN, int yN) {
  int neg = 2;
  int zer = 1;
  int pos = 0;
   
  int pan = 1;
  int tilt = 2;
  
  int a, m, n, v;
  
  if (abs(x) > abs(y)) {
    a = pan;
    m = x;
    n = xN;
  }
  else {
    a = tilt;
    m = y;
    n = yN;
  }
  
  if (abs(m) < 10) {
    v = zer;
  }
  else if (m < 0) {
    v = neg;
  }
  else {
    v = pos;
  }
  
  message = byte(a * 10 + v + 100);
  
  dly = -m * 30 / n + 30;

  return message;
}
