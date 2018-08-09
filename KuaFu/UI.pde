class PointMap {
  int x0, y0;
  int width, height;
  int xM, yM;
  int pX0, pY0;
  int pX1, pY1;
  int pL;
  int edge;
  int opa = 0;
  
  PointMap(int x, int y, int w, int h, float pX, float pY) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    xM = x0 + w / 2;
    yM = y0 + h / 2;
    pL = 26;
    pX0 = x0 + pL / 2 + int((w - pL) * pX);
    pY0 = y0 + pL / 2 + int((h - pL) * pY);
    edge = 10;
  }
  
  boolean over() {
    if (abs(mouseX - xM) <= width / 2 && abs(mouseY - yM) <= height / 2) {
      return true;
    }
    else {
      return false;
    }
  }
  
  void display(int p) {
    if (p == 1) {
      pX1 = constrain(mouseX, x0 + pL / 2, x0 + width - pL / 2);
      pY1 = constrain(mouseY, y0 + pL / 2, y0 + height - pL / 2);
      
      opa = 255;
    }
    else if (p == 2) {
      pX1 = pX0;
      pY1 = pY0;
      
      opa = 255;
    }
    else {
      opa -= 64;
    }
    
    noStroke();
    fill(dark);
    rect(x0, y0, width, height, edge);
    
    opa = constrain(opa, 0, 255);
    
    stroke(light, opa);
    noFill();
    rect(pX1 - pL / 2, pY1 - pL / 2, pL, pL, edge);
  }
}

class Palette {
  int x0, y0;
  int width, height;
  int edge;
  color clr;
  
  Palette(int x, int y, int w, int h) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    edge = 10;
    clr = color(0);
  }
  
  void display() {
    strokeWeight(2);
    stroke(dark);
    fill(clr);
    rect(x0, y0, width, height, edge);
  }
}

class Button {
  int x0, y0;
  int width, height;
  int xM, yM;
  int x1A, y1A, x2A, y2A;
  int edge;
  boolean type;
  color f;
  color b0, b1;
  String name; 
  PShape i1, i2;
  boolean state;
  
  Button(int x, int y, int w, int h, int e, boolean t, String n) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    xM = x0 + w / 2;
    yM = y0 + h / 2;
    type = t;
    state = false;
    x1A = 0;
    y1A = 0;
    x2A = 0;
    y2A = 0;
    edge = e;
    
    if (type) {
      f = background;
      b0 = light;
      b1 = pressed;
    }
    else {
      f = light;
      b0 = color(0);
      b1 = color(50);
    }
    
    i1 = loadShape(sketchPath() + "/图标/" + n + ".svg");
    i2 = loadShape(sketchPath() + "/图标/" + n + ".svg");
    
    i1.setFill(f);
    i2.setFill(f);
  }
  
  Button(int x, int y, int w, int h, int e, boolean t, String n1, String n2) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    xM = x0 + w / 2;
    yM = y0 + h / 2;
    type = t;
    state = false;
    x1A = 0;
    y1A = 0;
    x2A = 0;
    y2A = 0;
    edge = e;
    
    if (type) {
      f = background;
      b0 = light;
      b1 = pressed;
    }
    else {
      f = light;
      b0 = color(0);
      b1 = color(50);
    }
    
    i1 = loadShape(sketchPath() + "/图标/" + n1 + ".svg");
    i2 = loadShape(sketchPath() + "/图标/" + n2 + ".svg");
    
    i1.setFill(f);
    i2.setFill(f);
  }
  
  boolean over() {
    if (abs(mouseX - xM) <= width / 2 && abs(mouseY - yM) <= height / 2) {
      return true;
    }
    else {
      return false;
    }
  }
  
  void display(boolean pressed) {
    if (pressed) {
      noStroke();
      fill(b1);
      rect(x0, y0, width, height, edge);
    }
    else {
      noStroke();
      fill(b0);
      rect(x0, y0, width, height, edge);
    }
    
    if (state) {
      shape(i2, xM - i1.width / 2 + x2A, yM - i1.height / 2 + y2A);
    }
    else {
      shape(i1, xM - i2.width / 2 + x1A, yM - i2.height / 2 + y1A);
    }
  }
}

class JoyStick {
  int x0, y0;
  int width, height;
  int xM, yM;
  int sX, sY;
  int sL;
  int r0, r1;
  int edge;
  boolean state;
  
  JoyStick(int x, int y, int w, int h) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    xM = x0 + w / 2;
    yM = y0 + h / 2;
    sX = xM;
    sY = yM;
    sL = 26;
    r0 = 3;
    r1 = 28;
    edge = 10;
    state = false;
  }
  
  boolean over() {
    if (abs(mouseX - xM) <= width / 2 && abs(mouseY - yM) <= height / 2) {
      return true;
    }
    else {
      return false;
    }
  }
  
  void display() {
    if (state || keyPressed) {
      sX = constrain(sX, x0 + sL / 2, x0 + width - sL / 2);
      sY = constrain(sY, y0 + sL / 2, y0 + height - sL / 2);
    }
    else {
      sX = xM;
      sY = yM;
    }
    
    noStroke();
    fill(dark);
    rect(x0, y0, width, height, edge);
    noStroke();
    fill(light);
    rect(sX - sL / 2, sY - sL / 2, sL, sL, edge);
  }
}

class Text {
  int x0, y0;
  int width, height;
  
  Text(int x, int y, int w, int h) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
  }
  
  void display(String t) {
    fill(light);
    textFont(font);
    textAlign(LEFT, TOP);
    text(t, x0, y0, width, height);
  }
}

void canvas() {
  noStroke();
  fill(0);
  rect(video.width,
       video.height / 3 + gap + camera.height + gap + palette.height + gap,
       video.width / 3,
       video.height * 2 / 3 - gap - camera.height - gap - palette.height - gap);
  
  noStroke();
  fill(background);
  rect(video.width,
       video.height / 3,
       video.width / 3,
       gap + camera.height + gap + palette.height + gap);
}

void setCursor() {
  if (joyStick.state) {
    cursor(MOVE);
  }
  else if (mouseX <= 640 || camera.over()) {
    cursor(CROSS);
  }
  else if (pause.over() || record.over() || changePath.over() || joyStick.over()) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  }
}
