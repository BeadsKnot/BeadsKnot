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
float beads_interval = 15 ;// ビーズの間隔
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
    data.drawNbhs();
    data.drawPoints();
  } 
  //data_extract+spring_modelの内容を描画する場合。
  else if (data.extraction_complete) {
    data.drawNbhs();
    data.drawPoints();
    //data.tf.spring();// ばねモデルで動かしたものを表示
    // 平面グラフのデータもある場合、ばねモデルで動かした結果をNodeにフィードバックする必要がある？
  } 
  // 平面グラフのデータを表示
  else if (graph.data_graph_complete) {
    graph.draw_nodes_edges();
  } else if (dOpt.data_graph_all_complete) {
    data.drawPoints();
    data.drawNbhs();
    data.tf.spring();// ばねモデルで動かしたものを表示
  }
}

void keyPressed() {
  if ( key=='s') {
    selectInput("Select a file to save", "saveFileSelect");
  }

  //if (int(key)==15) {// ctrl+o
  else if ( key == 'o' || int(key)==15) {// o // ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  } else if (key=='p') {
    PLink PL=new PLink(data, disp);
    PL.file_output();
  } else if (key == 'm') { // modify
    if (graph.data_graph_complete) {
      graph.modify();
    }
  }
}

void saveFileSelect(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    file_name=selection.getAbsolutePath();
    int file_name_length= file_name.length();
    String extension=file_name.substring(file_name_length-3);
    if (extension.equals("png")==true||extension.equals("jpg")==true||extension.equals("gif")==true) {
      save(file_name);// 画像として保存
    } else {
      PrintWriter file; 
      file = createWriter(file_name);
      file.println("BeadsKnot,0");
      file.println("Nodes,"+graph.nodes.size());
      for (int nodeID=0; nodeID<graph.nodes.size(); nodeID++) {
        Node nd = graph.nodes.get(nodeID);
        file.print(nd.x+","+nd.y+","+nd.theta+",");
        file.println(nd.r[0]+","+nd.r[1]+","+nd.r[2]+","+nd.r[3]);
      }
      file.println("Edges,"+graph.edges.size());
      for (int edgeID=0; edgeID<graph.edges.size(); edgeID++) {
        Edge ed = graph.edges.get(edgeID);
        file.println(ed.ANodeID+","+ed.ANodeRID+","+ed.BNodeID+","+ed.BNodeRID);
      }
      file.println("BeadsKnotEnd");
      file.flush();
      file.close();
      exit();
    }
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    file_name=selection.getAbsolutePath();
    int file_name_length= file_name.length();
    String extension=file_name.substring(file_name_length-3);
    if (extension.equals("png")==true||extension.equals("jpg")==true||extension.equals("gif")==true) {
      PImage image = loadImage(selection.getAbsolutePath());
      data.make_data_extraction(image);
      graph.make_data_graph();
      String remove_extension=file_name.substring(0, file_name_length-4);
      file_name=remove_extension;
    } else {
      BufferedReader reader = createReader(file_name);
      String line = null;
      int version = -1;
      // 失敗したときのためにバックアップを取っておくのがよさそうだ。
      try {
        if ((line = reader.readLine()) != null) {
          String[] pieces = split(line, ',' );
          if (pieces[0].equals("BeadsKnot")) {
            version = int(pieces[1]);
          } else return;
        }
        if (version==0) {
          int nodeNumber=0,edgeNumber=0;
          if ((line = reader.readLine()) != null) {
            String[] pieces = split(line, ',' );
            if (pieces[0].equals("Nodes")) {
              nodeNumber = int(pieces[1]);
              graph.nodes.clear();
              data.points.clear();
              for (int n=0; n<nodeNumber; n++) {
                line = reader.readLine();
                pieces = split(line, ',');
                Node nd = new Node(float(pieces[0]), float(pieces[1]));
                nd.theta = float(pieces[2]);
                nd.r[0] = float(pieces[3]);
                nd.r[1] = float(pieces[4]);
                nd.r[2] = float(pieces[5]);
                nd.r[3] = float(pieces[6]);
                nd.pointID = n;
                graph.nodes.add(nd);
                Bead bd = new Bead(float(pieces[0]), float(pieces[1]));
                bd.c = 2;
                data.points.add(bd);
              }
            } else return;
          }
          if ((line = reader.readLine()) != null) {
            String[] pieces = split(line, ',' );
            if (pieces[0].equals("Edges")) {
              edgeNumber = int(pieces[1]);
              graph.edges.clear();
              for (int n=0; n<edgeNumber; n++) {
                line = reader.readLine();
                pieces = split(line, ',');
                Edge ed = new Edge(int(pieces[0]), int(pieces[1]), int(pieces[2]), int(pieces[3]));
                graph.edges.add(ed);
                Bead bd = new Bead(0f,0f);// id = nodeNumber+n
                bd.n1 = ed.ANodeID;
                bd.n2 = ed.BNodeID;
                bd.c = 2;
                Bead bdA = data.points.get(ed.ANodeID);
                bdA.set_un12(ed.ANodeRID, nodeNumber+n);
                Bead bdB = data.points.get(ed.BNodeID);
                bdB.set_un12(ed.BNodeRID, nodeNumber+n);
                data.points.add(bd);
              }
              for(int n=0; n<nodeNumber; n++){
                Bead bd = data.points.get(n);
                if(bd.u1==-1 && bd.u2==-1) {
                  bd.midJoint=true;
                }
                else {
                  bd.Joint = true;
                }
              }
            }
            graph.modify();
            graph.update_points();
            graph.add_close_point_Joint();
            data.extraction_complete = true;
          }
        }
        reader.close();
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
}

boolean node_dragging=false;
int dragged_nodeID = -1;
float node_dragging_x0 = 0f;
float node_dragging_y0 = 0f;
float mousePressX = 0;
float mousePressY = 0;

void mousePressed() {
  mousePressX = mouseX;
  mousePressY = mouseY;
  int ndID = graph.is_PVector_on_Joint(mouseX, mouseY);
  if (ndID != -1) {
    node_dragging = true;
    dragged_nodeID = ndID;
    int pt0ID = graph.nodes.get(dragged_nodeID).pointID;
    Bead pt0 = data.points.get(pt0ID);
    node_dragging_x0 = pt0.x;
    node_dragging_y0 = pt0.y;
  }
}

void mouseDragged() {
  if (node_dragging) {
    float mX = disp.getX_fromWin(mouseX);
    float mY = disp.getY_fromWin(mouseY);

    float node_dragging_min_dist = dist(node_dragging_x0, node_dragging_y0, mX, mY);
    for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
      if (ndID != dragged_nodeID) {
        int ptID = graph.nodes.get(ndID).pointID;
        Bead pt = data.points.get(ptID);
        float x = pt.x;
        float y = pt.y;
        float d = dist(mX, mY, x, y);
        if (d < node_dragging_min_dist) {//ボロノイ領域を超えたら処理をしない。
          return;
        }
      }
    }
    //println(mX,mY);
    Node nd0 = graph.nodes.get(dragged_nodeID);
    nd0.x = mX;
    nd0.y = mY;
    //if (keyPressed) {
    //  if (key == 'r') {
    //    nd0.theta += 0.1f;
    //  }
    //  if (key == 't') {
    //    nd0.theta -= 0.1f;
    //  }
    //}
    Bead bd0 = data.points.get(nd0.pointID);
    bd0.x = mX;
    bd0.y = mY;
    // 図全体のmodify();
    graph.modify();
    // 形を整えた後に、pointsのデータを更新する
    graph.update_points();
    graph.add_close_point_Joint();
  }
}

void mouseReleased() {
  node_dragging=false;

  if (dist(mouseX, mouseY, mousePressX, mousePressY)<1.0) {// クリック
    println("click");
    if (keyPressed) {
      if (key=='c') {
        // ノードをクリックしている場合には、クロスチェンジする。
        for (int nodeID=0; nodeID<graph.nodes.size(); nodeID++) {
          Node node = graph.nodes.get(nodeID);
          float mX = disp.getX_fromWin(mouseX);
          float mY = disp.getY_fromWin(mouseY);
          if (dist(mX, mY, node.x, node.y)<10) {
            println("cross change");
            if (node.Joint) {
              graph.crosschange(nodeID);
            }
          }
        }
      }
    }
  }
}
