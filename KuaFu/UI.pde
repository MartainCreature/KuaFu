class Position {
  int x0, y0;
  int width, height;
  int pX, pY;
  int pL;
  int edge;
  
  Position(int x, int y, int w, int h) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    pX = x0 + width / 2;
    pY = y0 + height / 2;
    pL = 26;
    edge = 10;
  }
  
  void display() {
    pX = constrain(pX, x0 + pL / 2, x0 + width - pL / 2);
    pY = constrain(pY, y0 + pL / 2, y0 + height - pL / 2);
    
    noStroke();
    fill(dark);
    rect(x0, y0, width, height, edge);
    strokeWeight(2);
    stroke(light);
    noFill();
    rect(pX - pL / 2, pY - pL / 2, pL, pL, edge);
  }
}

class Palette {
  int x0, y0;
  int width, height;
  int edge;
  
  Palette(int x, int y, int w, int h) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    edge = 10;
  }
  
  void display() {
    strokeWeight(2);
    stroke(dark);
    fill(selectedC);
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
  
  Button(int x, int y, int w, int h, boolean t, String n) {
    x0 = x;
    y0 = y;
    width = w;
    height = h;
    xM = x0 + w / 2;
    yM = y0 + h / 2;
    type = t;
    name = n;
    state = false;
    x1A = 0;
    y1A = 0;
    x2A = 0;
    y2A = 0;
    
    if (type) {
      edge = 10;
      f = background;
      b0 = light;
      b1 = pressed;
    }
    else {
      edge = 5;
      f = light;
      b0 = color(0);
      b1 = background;
    }
    
    if (n.equals("pause")) {
      i1 = loadShape(sketchPath() + "/图标/pauseI.svg");
      i2 = loadShape(sketchPath() + "/图标/resumeI.svg");
    }
    else if (n.equals("record")) {
      i1 = loadShape(sketchPath() + "/图标/recordI.svg");
      i2 = loadShape(sketchPath() + "/图标/stopI.svg");
    }
    else if (n.equals("change")) {
      i1 = loadShape(sketchPath() + "/图标/changeI.svg");
      i2 = loadShape(sketchPath() + "/图标/changeI.svg");
    }
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
       video.height / 3 + gap + cameraAngle.height + gap + palette.height + gap,
       video.width / 3,
       video.height * 2 / 3 - gap - cameraAngle.height - gap - palette.height - gap);
  
  noStroke();
  fill(background);
  rect(video.width,
       video.height / 3,
       video.width / 3,
       gap + cameraAngle.height + gap + palette.height + gap);
}

void setCursor() {
  if (joyStick.state) {
    cursor(MOVE);
  }
  else if (mouseX <= 640) {
    cursor(CROSS);
  }
  else if (pause.over() || record.over() || changePath.over() || joyStick.over()) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  }
}
