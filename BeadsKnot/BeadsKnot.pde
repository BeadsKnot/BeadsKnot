//sボタンを押すと画像を保存
// PImage image;// ->data_extraction
// int w, h;// ->data_extraction
// int d[][];// ->data_extraction
// int s;// ->data_extraction
// int n = s;// ->data_extraction
boolean ofutarisama_flag=false;//お二人様かどうかのフラグ// ->data_extraction
PImage pastedImage;
PImage output;

data_extract data;

void setup() {
  int extractSize=1500;

  //size(1500, 1500);//初期のサイズ
  size(1000, 1000);//初期のサイズ
  // size(600, 600);//初期のサイズ

  data = new data_extract(extractSize, extractSize, null);
}

void draw() {
  background(255);
  data.drawPoints();
  data.drawNbhs();
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
    PImage image = loadImage(selection.getAbsolutePath());
    data.make_data_extraction(image);
  }
}