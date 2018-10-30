// usage //<>// //<>//
// o : ファイル読み込み
// s : 画像を保存

// グローバル変数はこれだけ
data_extract data;// 画像解析から読み込んだ線のデータ
data_graph graph;// data_extractから解析した平面グラフのデータ
display disp;// 画面表示に関する定数
EdgeConst ec;// Edgeに関する定数
drawOption dOpt;// 描画に関するオプション
String file_name="test";// 読み込んだファイル名を使って保存ファイル名を生成する
float beads_interval = 20 ;// ビーズの間隔
// グローバル変数終了


void setup() {
  int extractSize=1000;

  size(1000, 1000);//初期のサイズ
  //初期化
  disp = new display(1000, 1000);
  data = new data_extract(extractSize, extractSize, disp);
  graph = new data_graph(data);
  ec = new EdgeConst();
  dOpt = new drawOption();
}

void draw() {
  background(255);
  if (data.extraction_binalized) {// 二値化したデータを表示
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
  //data_extract+spring_modelの内容を描画する場合。
  else if (data.extraction_complete) {
    data.drawPoints();
    data.drawNbhs();
    data.tf.spring();// ばねモデルで動かしたものを表示
    // 平面グラフのデータもある場合、ばねモデルで動かした結果をNodeにフィードバックする必要がある？
  } 
  // 平面グラフのデータを表示
  else if (graph.data_graph_complete) {
    graph.draw_nodes_edges();
  }else if(dOpt.data_graph_all_complete){
    data.drawPoints();
    data.drawNbhs();
    data.tf.spring();// ばねモデルで動かしたものを表示
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
  else if ( key == 'o' || int(key)==15) {// o // ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  }
  else if (key=='p') {
    PLink PL=new PLink(data, disp);
    PL.file_output();
  }
  else if(key == 'm'){ // modify
    if(graph.data_graph_complete){
      graph.modify();
    }
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

boolean node_dragging=false;
int dragged_nodeID = -1;
float node_dragging_x0 = 0f;
float node_dragging_y0 = 0f;

void mousePressed() {
  int ndID = graph.is_PVector_on_Joint(mouseX, mouseY);
  if(ndID != -1){
    node_dragging = true;
    dragged_nodeID = ndID;
    int pt0ID = graph.nodes.get(dragged_nodeID).pointID;
    Bead pt0 = data.points.get(pt0ID);
    node_dragging_x0 = pt0.x;
    node_dragging_y0 = pt0.y;
  }
}

void mouseDragged(){
  if(node_dragging){
    float mX = disp.getX_fromWin(mouseX);
    float mY = disp.getY_fromWin(mouseY);

    float node_dragging_min_dist = dist(node_dragging_x0,node_dragging_y0,mX,mY);
    for(int ndID=0; ndID<graph.nodes.size(); ndID++){
      if(ndID != dragged_nodeID){
        int ptID = graph.nodes.get(ndID).pointID;
        //println(ndID, ptID);
        Bead pt = data.points.get(ptID);
        float x = pt.x;
        float y = pt.y;
        float d = dist(mX,mY,x,y);
        //println(d,node_dragging_min_dist);
        if(d < node_dragging_min_dist){//ボロノイ領域を超えたら処理をしない。
          return;
        }
      }
    }
    println(mX,mY);
    Bead pt0 = data.points.get(graph.nodes.get(dragged_nodeID).pointID);
    pt0.x = mX;
    pt0.y = mY;
    // 図全体のmodify();
  }
}

void mouseReleased(){
  node_dragging=false; 
}
