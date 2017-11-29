//sボタンを押すと画像を保存
PImage image;
int w, h;
int d[][];
int s;
int n = s;
boolean ofutarisama_flag=false;//お二人様かどうかのフラグ
PImage pastedImage;
PImage output;

data_extract data;

void setup() {
  //size(600, 600);//初期のサイズ
  size(1000, 1000);//初期のサイズ
  //size(1500, 1500);
  data = new data_extract(950, 950, null);
}

void draw() {
  background(255);
  data.drawPoints();
  data.drawNbhs();
  // if ((keyPressed==true)&&(key=='t')) {
  if ( ofutarisama_flag) {
    data.tf.spring();
  }
}

void keyPressed() {
  if ( key=='s') {
    int s = second();
    int m = minute();
    int h = hour();
    int d = day();
    int mon = month();
    save("knot"+mon+d+"-"+h+m+s+".png");
  }

  if (int(key)==15) {// ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    image = loadImage(selection.getAbsolutePath());
    //get_knot_from_img();
    data.make_data_extraction(image);
  }
}