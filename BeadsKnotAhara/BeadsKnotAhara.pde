
data_extract dataExt;
//data_graph dataGraph;
int disp_wid, disp_hei, disp_offset;

drawOption DO;

void setup() {
  size(800, 800);
  disp_offset=10;
  disp_wid=800;//display width
  disp_hei=800;//display height
  DO = new drawOption(); 
  //nonmeridian2.png
  PImage img = loadImage("nonmeridian2.png");
  //PImage img = loadImage("K11a1.gif");
  dataExt = new data_extract(disp_wid, disp_hei, img);
  //dataGraph = new data_graph(dataExt);
}

void draw() {
  background(255);
  if (DO.drawOriginalImage) {
    image(dataExt.image, disp_offset, disp_offset, disp_wid-2*disp_offset, disp_hei-2*disp_offset);
  } else if (DO.drawThinningImage) {
    loadPixels();
    for (int x = 0; x<disp_wid; ++x) {
      for (int y = 0; y<disp_hei; ++y) {
        if (dataExt.d[y][x]==0) {
          pixels[x+y*disp_wid] = color(255);
        } else {
          pixels[x+y*disp_wid] = color(0);
        }
      }
    }
    updatePixels();
  } else if (DO.drawBeadsAndNhds) {
    for (int n=0; n<dataExt.nbhs.size(); ++n) {
      int n1 = dataExt.nbhs.get(n).a;
      float x1 = dataExt.points.get(n1).x;
      float y1 = dataExt.points.get(n1).y;
      int n2 = dataExt.nbhs.get(n).b;
      float x2 = dataExt.points.get(n2).x;
      float y2 = dataExt.points.get(n2).y;
      line(x1, y1, x2, y2);
    }
    for (int p=0; p<dataExt.points.size(); ++p) {
      float x = dataExt.points.get(p).x;
      float y = dataExt.points.get(p).y;
      ellipse(x, y, 3, 3);
    }
  }
}

void keyPressed() {
  if (int(key)==15) {// ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  }
  if(key=='1'){
    DO.changeDrawOption(1);
  }
  else  if(key=='2'){
    DO.changeDrawOption(2);
  }

  else if(key=='3'){
    DO.changeDrawOption(3);
  }
  else if (key == CODED){
    if(keyCode == UP){
      dataExt.thng.threshold += 5;
      println("threshold = "+dataExt.thng.threshold);
      dataExt.thng.get_knot_from_img();
    } else if(keyCode == DOWN){
      dataExt.thng.threshold -= 5;
      println("threshold = "+dataExt.thng.threshold);
      dataExt.thng.get_knot_from_img();
    }

  }

}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    PImage img = loadImage(selection.getAbsolutePath());
    dataExt = new data_extract(disp_wid, disp_hei, img);
  }
}