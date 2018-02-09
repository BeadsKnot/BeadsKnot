//sボタンを押すと画像を保存 //<>//
// PImage image;// ->data_extraction
// int w, h;// ->data_extraction
// int d[][];// ->data_extraction
// int s;// ->data_extraction
// int n = s;// ->data_extraction
//boolean ofutarisama_flag=false;//お二人様かどうかのフラグ// ->data_extraction
//このofutarisama_flagはいらない？
PImage pastedImage;
PImage output;

data_extract data;
data_graph graph;
display disp;



String file_name="tes";

void setup() {
  int extractSize=1000;

  //size(1500, 1500);//初期のサイズ
  size(1000, 1000);//初期のサイズ
  // size(600, 600);//初期のサイズ
  disp = new display(1000, 1000);
  data = new data_extract(extractSize, extractSize, disp);
  graph = new data_graph(data);
}

void draw() {
  background(255);
  if (data.extraction_binalized) {
    loadPixels();
    for (int x=0; x<data.w; x++) {
      for (int y=0; y<data.h; y++) {
        pixels[x + y*width] = color(255*(1-data.d[x][y]));
      }
    }
    updatePixels();
  }
  //data_extractの内容を描画する場合。
  if (data.extraction_beads) {
    data.drawPoints();
    data.drawNbhs();
  } 
  //
  else if (data.extraction_complete) {
    data.drawPoints();
    data.drawNbhs();
    //data.tf.spring();
  } else if (graph.data_graph_complete) {
    graph.drawNodes();
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

  //if (int(key)==15) {// ctrl+o
  if ( key == 'o') {// o
    selectInput("Select a file to process:", "fileSelected");
  }
  if (key=='p') {
    PLink PL=new PLink(data, disp);
    PL.file_output();
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    PImage image = loadImage(selection.getAbsolutePath());
    data.make_data_extraction(image);
    graph.make_data_graph();
    file_name=selection.getAbsolutePath();
    int file_name_length= file_name.length();
    String extension=file_name.substring(file_name_length-3);
    if (extension.equals("png")==true||extension.equals("jpg")==true||extension.equals("gif")==true) {
      String remove_extension=file_name.substring(0, file_name_length-4);
      file_name=remove_extension;
    }
  }
}

void mouseClicked() {
  println(mouseX, mouseY);
}