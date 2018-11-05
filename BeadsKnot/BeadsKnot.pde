import java.awt.*; //<>// //<>//
import javax.swing.*;

// usage
// o : ファイル読み込み
// s : 画像を保存

// グローバル変数はこれだけ
data_extract data;// 画像解析から読み込んだ線のデータ
data_graph graph;// data_extractから解析した平面グラフのデータ
display disp;// 画面表示に関する定数
EdgeConst ec;// Edgeに関する定数
drawOption Draw;// 描画に関するオプション
mouseDrag mouse;
parts_editing edit;
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
  Draw = new drawOption();
  mouse = new mouseDrag();
  edit = new parts_editing();
}

void draw() {
  background(255);
  if (Draw._binarized_image) {// 二値化したデータを表示
    loadPixels();
    for (int x=0; x<data.w; x++) {
      for (int y=0; y<data.h; y++) {
        pixels[x + y*width] = color(255*(1-data.d[x][y]));
      }
    }
    updatePixels();
  }
  //data_extractの内容を描画する場合。
  if (Draw._beads) {
    data.drawNbhs();
    data.drawPoints();
    //    data.tf.spring();// ばねモデルで動かしたものを表示
  } 
  // 平面グラフのデータを表示
  else if (Draw._data_graph) {
    graph.draw_nodes_edges();
  } else if (Draw._free_loop) {
    mouse.draw_trace();
  } else if (Draw._parts_editing) {
    edit.draw_parts();
    mouse.draw_trace();
  }
}

void keyPressed() { 
  // 'n' -> free_loop モード。
  // 'e' -> parts_editingモード
  if ( key=='s' || int(key)==19) {
    selectInput("Select a file to save", "saveFileSelect");
  } else if ( key == 'o' || int(key)==15) {// o // ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  } else if (key == 'm') { // modify
    if (Draw._data_graph) {
      graph.modify();
    }
  } else if (key == 'n') {
    Draw.free_loop();
    mouse.trace.clear();// 絵のクリア
  } else if (key == 'e') {
    Draw.parts_editing();
    edit.beads.clear();
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
    if (extension.equals("png") || extension.equals("jpg") || extension.equals("gif")) {
      save(file_name);// 画像として保存
    } else if (extension.equals("lnk")) {
      PLink PL=new PLink(data, disp);
      PL.file_output();
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
          int nodeNumber=0, edgeNumber=0;
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
                Bead bd = new Bead(0f, 0f);// id = nodeNumber+n
                bd.n1 = ed.ANodeID;
                bd.n2 = ed.BNodeID;
                bd.c = 2;
                Bead bdA = data.points.get(ed.ANodeID);
                bdA.set_un12(ed.ANodeRID, nodeNumber+n);
                Bead bdB = data.points.get(ed.BNodeID);
                bdB.set_un12(ed.BNodeRID, nodeNumber+n);
                data.points.add(bd);
              }
              for (int n=0; n<nodeNumber; n++) {
                Bead bd = data.points.get(n);
                if (bd.u1==-1 && bd.u2==-1) {
                  bd.midJoint=true;
                } else {
                  bd.Joint = true;
                }
              }
            }
            graph.modify();
            graph.update_points();
            graph.add_close_point_Joint();
            Draw.beads();// drawモードの変更
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


void mousePressed() {
  mouse.PressX = mouseX;
  mouse.PressY = mouseY;
  if (Draw._beads) {
    int ptID = graph.is_PVector_on_points(mouseX, mouseY);
    if (ptID!=-1) {
      if (data.points.get(ptID).Joint || data.points.get(ptID).midJoint) {//nodeをドラッグする
        mouse.node_dragging = true;
        for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
          if (graph.nodes.get(ndID).pointID == ptID) {
            mouse.dragged_nodeID = ndID;
          }
        }
        int pt0ID = graph.nodes.get(mouse.dragged_nodeID).pointID;
        Bead pt0 = data.points.get(pt0ID);
        mouse.DragX = pt0.x;
        mouse.DragY = pt0.y;
        println("ドラッグ開始");
        return;
      } else {
        int jt_ndID =graph.next_to_node(ptID); 
        if (jt_ndID!=-1) {//ノードの隣をドラッグした場合
          mouse.node_next_dragging = true;
          mouse.dragged_nodeID = jt_ndID;
          Node nd = graph.nodes.get(mouse.dragged_nodeID);
          mouse.dragged_theta = atan2(mouseY - nd.y, mouseX - nd.x);
          mouse.nd_theta = nd.theta;
        }
      }
    }
  } else if (Draw._free_loop) {
    mouse.prev = new PVector(mouseX, mouseY);
    mouse.trace.add(mouse.prev);
  } else if (Draw._parts_editing) {
    for (int bdID=0; bdID < edit.beads.size(); bdID++) {
      Bead bd = edit.beads.get(bdID);
      if (bd.c <2 && dist(bd.x, bd.y, mouseX, mouseY) < 10f) {//もしおひとりさまのノードが近くにある場合は
        mouse.prev = new PVector(mouseX, mouseY);
        mouse.trace.clear();
        mouse.trace.add(mouse.prev);
        mouse.dragged_BeadID= bdID;
        mouse.node_next_dragging=true; // ドラッグ開始
        println("start path.");
        break;
      }
    }
  }
}

void mouseDragged() {
  if (Draw._beads) {
    if (mouse.node_dragging) {
      float mX = disp.getX_fromWin(mouseX);
      float mY = disp.getY_fromWin(mouseY);

      float mouseDragmin_dist = dist(mouse.DragX, mouse.DragY, mX, mY);
      for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
        if (ndID != mouse.dragged_nodeID) {
          int ptID = graph.nodes.get(ndID).pointID;
          Bead pt = data.points.get(ptID);
          float x = pt.x;
          float y = pt.y;
          float d = dist(mX, mY, x, y);
          if (d < mouseDragmin_dist) {//ボロノイ領域を超えたら処理をしない。
            return;
          }
          if (d > 1000) {//あまり外側へ行ったら処理をしない。
            println("*外側へ行きすぎです。");
            return ;
          }
        }
      }
      //println(mX,mY);
      Node nd0 = graph.nodes.get(mouse.dragged_nodeID);
      nd0.x = mX;
      nd0.y = mY;
      Bead bd0 = data.points.get(nd0.pointID);
      bd0.x = mX;
      bd0.y = mY;
      // 図全体のmodify();
      graph.modify();
      graph.update_points();
      graph.add_close_point_Joint();
    } else if (mouse.node_next_dragging) {
      // ノードの隣をドラッグした場合。
      Node nd = graph.nodes.get(mouse.dragged_nodeID);
      nd.theta = mouse.nd_theta - (atan2(mouseY - nd.y, mouseX - nd.x) - mouse.dragged_theta)*0.4;
      graph.modify();
      graph.update_points();
      graph.add_close_point_Joint();
    }
  } else if (Draw._free_loop) {
    if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beads_interval-1) {
      mouse.prev = new PVector(mouseX, mouseY);
      mouse.trace.add(mouse.prev);
    }
  } else if (Draw._parts_editing) {
    if (mouse.node_next_dragging) {
      if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beads_interval-1) {
        mouse.prev = new PVector(mouseX, mouseY);
        mouse.trace.add(mouse.prev);
      }
    }
  }
}

void mouseReleased() {
  if (Draw._beads) {
    mouse.node_dragging=false;
    mouse.node_next_dragging = false;
    if (dist(mouseX, mouseY, mouse.PressX, mouse.PressY)<1.0) {// クリック
      println("click");
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
  } else if (Draw._free_loop) {
    mouse.free_dragging=false;
    if (mouse.trace.size()>3) {// ドラッグ終了
      PVector p0 = mouse.trace.get(0);
      if (dist(p0.x, p0.y, mouseX, mouseY)<30) {
        JPanel panel = new JPanel();    //パネルを作成
        BoxLayout layout = new BoxLayout( panel, BoxLayout.Y_AXIS );    //メッセージのレイアウトを決定
        panel.setLayout(layout);    //panelにlayoutを適用
        panel.add( new JLabel( "よろしいですか" ) );    //メッセージ内容を文字列のコンポーネントとしてパネルに追加
        int r = JOptionPane.showConfirmDialog( 
          null, //親フレームの指定
          panel, //パネルの指定
          "使用しますか？", //タイトルバーに表示する内容
          JOptionPane.YES_NO_OPTION, //オプションタイプをYES,NOにする
          JOptionPane.INFORMATION_MESSAGE   //メッセージタイプをInformationにする
          );
        if (r==0) {
          // mouse.trace を beadsのデータにする。
          mouse.trace_to_beads(data, graph);
          Draw.beads();
        }
      }
    }
  } else if (Draw._parts_editing) {
    if (dist(mouseX, mouseY, mouse.PressX, mouse.PressY)<1.0) {// クリック
      boolean hit = false;
      for (int bdID=0; bdID < edit.beads.size(); bdID++) {
        Bead bd = edit.beads.get(bdID);
        if (dist(bd.x, bd.y, mouseX, mouseY) < 10f) {//もしノードが近くにある場合は
          edit.deleteBead(bdID);// bdID 番のノードを無効にする。
          hit = true;
          break;
        } else if (dist(bd.x, bd.y, mouseX, mouseY) < 20f) {//もしノードが近くにある場合は
          hit = true;
        }
      }
      if (! hit) {//ノードが近くにない場合には
        //ノードを新設(ジョイント一つに周辺4つ。)
        edit.createJoint(mouseX, mouseY);//隣接関係を設定する。
      }
    } else { // ドラッグ終了
      if (mouse.node_next_dragging) {// おひとり様からドラッグを開始した場合。
        if (mouse.trace.size()>2) {// あまり近かったら何もしない。
          boolean OK = false;
          int endBdID=-1;
          for (int bdID=0; bdID<edit.beads.size(); bdID++) {
            Bead bd = edit.beads.get(bdID);
            if (dist(bd.x, bd.y, mouseX, mouseY)<20) {
              endBdID = bdID;
              OK = true;
              break;
            }
          }
          if (OK) {
            mouse.trace_to_parts_editing(data, graph, edit, endBdID);
          }
        }
        mouse.free_dragging=false;
      }
    }
  }
}
