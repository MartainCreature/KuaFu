void mousePressed() {
  if (mouseX <= 640) {
    selected = true;
  
    palette.clr = get(mouseX * displayDensity(), mouseY * displayDensity());
  
    palette.display();
  
    int hue = int(map(hue(palette.clr), 0, 255, 0, 180));
    println("Hue(" + hue + ") selected.");
  
    hueL = hue - 5;
    hueH = hue + 5;
    
    rX = mouseX;
    rY = mouseY;
    rW = 0;
    rH = 0;
  }
  
  if (joyStick.over()) {
    joyStick.state = true;
  }
  
  if (changePath.over()) {
    selectFolder("", "folderSelected");
  }
}

void mouseReleased() {
  if (pause.over() && !joyStick.state) {
    pause.state = !pause.state;
  }
  
  if (record.over() && !joyStick.state) {
    record.state = !record.state;
    
    if (record.state) {
      videoExport.setMovieFileName(path + "/" + prefix + count + ".mp4");
      videoExport.startMovie();
      
      count++;
    }
    else {
      videoExport.endMovie();
    }
  }
  
  joyStick.state = false;
  
  joyStick.display();
}

void keyTyped() {
  if (key == 'p') {
    pause.state = !pause.state;
  }
  
  if (key == 'r') {
    record.state = !record.state;

    if (record.state) {
      videoExport.setMovieFileName(path + "/" + prefix + count + ".mp4");
      videoExport.startMovie();
      
      count++;
    }
    else {
      videoExport.endMovie();
    }
  }
  
  if (key == 'c') {
    selectFolder("", "folderSelected");
  }
}

void manualEvent() {
  if (joyStick.state) {
    joyStick.sX = mouseX;
    joyStick.sY = mouseY;
  }
  else if (keyPressed) {
    if (keyCode == 37) {
      joyStick.sX = joyStick.xM - (joyStick.r0 + joyStick.r1) / 2;
    }
    else if (keyCode == 39) {
      joyStick.sX = joyStick.xM + (joyStick.r0 + joyStick.r1) / 2;
    }
    else {
      joyStick.sX = joyStick.xM;
    }
    if (keyCode == 38) {
      joyStick.sY = joyStick.yM - (joyStick.r0 + joyStick.r1) / 2;
    }
    else if (keyCode == 40) {
      joyStick.sY = joyStick.yM + (joyStick.r0 + joyStick.r1) / 2;
    }
    else {
      joyStick.sY = joyStick.yM;
    }
  }
}

void folderSelected(File selection) {
  if (selection != null) {
    path = selection.getAbsolutePath();
  }
}
