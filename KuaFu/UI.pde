void platformPosition() {
  fill(dark);
  noStroke();
  rect(x0 + gap, y0 + gap, w0, h1, edge);
  
  int x = x0 + gap + w0 / 2;
  int y = y0 + gap + h1 / 2;
  
  noFill();
  strokeWeight(2);
  stroke(light);
  rect(x - lP / 2 + pX * 0.9, y - lP / 2 + pY * 0.85, lP, lP, edge);
}

void selectedColor(color c) {
  fill(c);
  strokeWeight(2);
  stroke(dark);
  rect(x0 + gap, y0 + gap + h1 + gap, w1, h2, edge);
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
  rect(x0 + gap + w1 + gap, y0 + gap + h1 + gap, w2, w2, edge);
    
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + h1 + gap + w2 / 2;
  
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
  rect(x0 + gap + w1 + gap, y0 + gap + h1 + gap + w2 + gap, w2, w2, edge);
  
  int x = x0 + gap + w1 + gap + w2 / 2;
  int y = y0 + gap + h1 + gap + w2 + gap + w2 / 2;
  
  if (s) {
    fill(f);
    noStroke();
    rect(x - 7.5, y - 7.5, 15, 15, 2);
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
  rect(x0 + gap + w1 + gap + w2 + gap, y0 + gap + h1 + gap, w3, w3, edge);
  
  int x = x0 + gap + w1 + gap + w2 + gap + w3 / 2;
  int y = y0 + gap + h1 + gap + w3 / 2;
  
  fill(light);
  noStroke();
  rect(x + jX - lJ / 2, y + jY - lJ / 2, lJ, lJ, edge);
}

void strip() {
  fill(background);
  noStroke();
  rect(640, 160, 30, 320);
  fill(0);
  noStroke();
  rect(640, 160 + gap + h1 + gap + h2 + gap, 213, 320 - gap - h1 - gap - h2 - gap);

  selectedColor(sC);
  
  fill(255);
  text("保存路径 " + videoPath, 640 + 10, 160 + gap + h1 + gap + h2 + gap + 10, 213 - 20, 480);
}
