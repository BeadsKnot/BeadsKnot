import java.awt.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>//
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
orientation orie;
String file_name="test";// 読み込んだファイル名を使って保存ファイル名を生成する
float beads_interval = 15 ;// ビーズの間隔
int startID;
int count_for_distinguishing_edge=0;//edgeを消すためのcountの数


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
  orie=new orientation(data, graph);
}



void message(String msg) {
  textSize(28);
  fill(80);
  text(msg, 0, 30);
}

void draw() {
  background(255);
  if (Draw._menu) {
    textSize(28);
    fill(0);
    int y = 60;
    text("e : input by editor", 30, y);
    y += 40;
    text("n : input by free loop", 30, y);
    y += 40;
    text("o : open file (png, jpg, gif, txt)", 30, y);
    y += 40;
    text("s : save file (png, txt, lnk)", 30, y);
    y += 40;
    text("m : see menu", 30, y);
    y += 40;
  } else if (Draw._binarized_image) {// 二値化したデータを表示
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
    /////////////////////////////////////////////////////Nbhd nh = data.get_near_nbhd();
    //////////////////////////////////////////////////// data.draw_region(nh);
    data.drawNbhds();
    data.drawPoints();
    //    data.tf.spring();// ばねモデルで動かしたものを表示
    if (mouse.node_next_dragging) {
      //ビーズ周りのガイドを表示する。
      Node nd = graph.nodes.get(mouse.dragged_nodeID);
      if (nd.inUse) {
        float x = disp.get_winX(nd.x);
        float y = disp.get_winY(nd.y);
        float t = nd.theta;
        stroke(255, 0, 0);
        strokeWeight(1);
        line(x+100*sin(t), y+100*cos(t), x-100*sin(t), y-100*cos(t));
        line(x+100*cos(t), y-100*sin(t), x-100*cos(t), y+100*sin(t));
      }
    } else if (mouse.new_curve) {
      mouse.draw_trace();
    }
  } 
  // 平面グラフのデータを表示
  else if (Draw._data_graph) {
    graph.draw_nodes_edges();
  } else if (Draw._free_loop) {
    message("Draw a free loop.");
    mouse.draw_trace();
  } else if (Draw._parts_editing) {
    message("A crossing by a click, connecting two crossings by mouse-drag.");
    edit.draw_parts();
    mouse.draw_trace();
    //} else if (Draw._posinega) {
    //  //posinegaの関数を呼び出す
    //  data.drawNbhds();
    //  data.draw_posinega_Points();
  } else if (Draw._smoothing) {
    //smoothingの関数を呼び出す
    Nbhd nh = data.get_near_nbhd();
    data.draw_smoothing_region(nh);
    data.draw_smoothing_Nbhds();
    data.draw_smoothing_Points();
    //drawNbhdsを変える
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
    mouse.trace.clear();
    edit.beads.clear();
  } 
  //else if(key == 'r'){
  // data.draw_region(new Nbhd(4,5));
  //}

  if (keyCode==ENTER) {
    orie.decide_orientation();
    Draw.smoothing();
  } else if (keyCode==SHIFT) {
    Draw._beads=true;
  } else if (key=='d') {
    println("ドーカーコードを表示します");
    orie.decide_orientation();
    orie.dowker_notation();  ///////////////////////////////////////////////ここで関数を呼ぶ
  }
  //if (keyCode==SHIFT) {
  //  orie.decide_orientation();
  //  Draw.posinega();
  //}
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
        if (nd.inUse) {
          file.print(nd.x+","+nd.y+","+nd.theta+",");
          file.println(nd.r[0]+","+nd.r[1]+","+nd.r[2]+","+nd.r[3]);
        }
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
      if (data.make_data_extraction(image)) {//一発で成功した場合
        graph.make_data_graph();
      }
      file_name=file_name.substring(0, file_name_length-4);
    } else {// BeadsKnot オリジナルファイル形式の場合
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
              data.clearAllPoints();
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
                nd.Joint=false;
                graph.nodes.add(nd);
                int bdID = data.addBeadToPoint(float(pieces[0]), float(pieces[1]));
                Bead bd = data.getBead(bdID); 
                bd.c = 2;
                bd.n1 = bd.n2 = -1;
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
                //Bead bd = new Bead(0f, 0f);// id = nodeNumber+n
                int bdID = data.addBeadToPoint(0f, 0f);
                Bead bd = data.getBead(bdID);
                bd.n1 = ed.ANodeID;
                bd.n2 = ed.BNodeID;
                bd.c = 2;
                Bead bdA = data.getBead(ed.ANodeID);
                if (bdA!=null) {
                  bdA.set_un12(ed.ANodeRID, nodeNumber+n);
                }
                Bead bdB = data.getBead(ed.BNodeID);
                if (bdB!=null) {
                  bdB.set_un12(ed.BNodeRID, nodeNumber+n);
                }
              }
              for (int n=0; n<nodeNumber; n++) {
                Bead bd = data.getBead(n);
                if (bd.n1==-1 && bd.n2==-1) {
                  data.removeBeadFromPoint(n);
                }
                if (bd.u1==-1 && bd.u2==-1) {
                  bd.midJoint=true;
                } else {
                  bd.Joint = true;
                  Node ndN = graph.nodes.get(n);
                  if (ndN.inUse) {
                    ndN.Joint = true;
                  }
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
  //if (Draw._beads) {
  if (Draw._beads||Draw._smoothing) {
    int ptID = graph.is_PVector_on_points(mouseX, mouseY);
    int jointID = graph.is_PVector_on_Joints(mouseX, mouseY);
    if (ptID!=-1) {
      if (jointID != -1) {//nodeをドラッグする
        mouse.node_dragging = true;
        for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
          Node nd = graph.nodes.get(ndID); 
          if (nd.inUse && nd.pointID == ptID) {
            mouse.dragged_nodeID = ndID;
            int pt0ID = graph.nodes.get(mouse.dragged_nodeID).pointID;
            Bead pt0 = data.getBead(pt0ID);
            mouse.DragX = pt0.x;
            mouse.DragY = pt0.y;
            println("ノードのドラッグ開始");
            return;
          }
        }
      } else {
        int jt_ndID =graph.next_to_node(ptID); 
        if (jt_ndID==-1) {//ノードの隣でないところをドラッグした場合
          println("新規パス開始");
          startID=graph.is_PVector_on_points(mouseX, mouseY);
          mouse.prev = new PVector(mouseX, mouseY);
          mouse.trace.clear();
          mouse.trace.add(mouse.prev);
          mouse.new_curve=true;
          mouse.free_dragging = true;
        }
      }
    }
  } else if (Draw._free_loop) {
    mouse.prev = new PVector(mouseX, mouseY);
    mouse.trace.add(mouse.prev);
    mouse.free_dragging = true;
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
  //if (Draw._beads) {
  if (Draw._beads||Draw._smoothing) {
    if (mouse.node_dragging) {
      float mX = disp.getX_fromWin(mouseX);
      float mY = disp.getY_fromWin(mouseY);

      float mouseDragmin_dist = dist(mouse.DragX, mouse.DragY, mX, mY);
      for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
        if (ndID != mouse.dragged_nodeID) {
          Node nd = graph.nodes.get(ndID);
          if (nd.inUse) {
            int ptID = nd.pointID;
            Bead pt = data.getBead(ptID);
            if (pt==null) {
              return;
            }
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
      }
      //println(mX,mY);
      Node nd0 = graph.nodes.get(mouse.dragged_nodeID);
      if (nd0.inUse) {
        nd0.x = mX;
        nd0.y = mY;
        Bead bd0 = data.getBead(nd0.pointID);
        if (bd0 != null) {
          bd0.x = mX;
          bd0.y = mY;
        }
      }
      // 図全体のmodify();
      graph.modify();
      graph.update_points();
      graph.add_close_point_Joint();
      //} else if (mouse.node_next_dragging) {
      //  // ノードの隣をドラッグした場合。
      //  Node nd = graph.nodes.get(mouse.dragged_nodeID);
      //  //println(atan2(mouseY - disp.get_winY(nd.y), mouseX - disp.get_winX(nd.x)));
      //  float atanPre = atan2(pmouseY - disp.get_winY(nd.y), pmouseX - disp.get_winX(nd.x));
      //  float atanNow = atan2(mouseY - disp.get_winY(nd.y), mouseX - disp.get_winX(nd.x));
      //  if (atanPre>atanNow+PI*3/2) mouse.nd_theta_branch += (2*PI);
      //  else if (atanPre+PI*3/2<atanNow) mouse.nd_theta_branch -= (2*PI);
      //  nd.theta = mouse.nd_theta - (mouse.nd_theta_branch + atan2(mouseY - disp.get_winY(nd.y), mouseX - disp.get_winX(nd.x)) - mouse.dragged_theta)*0.25;
      //  graph.modify();
      //  graph.update_points();
      //  graph.add_close_point_Joint();
    } else if (mouse.new_curve) {
      if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beads_interval-1) {
        mouse.prev = new PVector(mouseX, mouseY);
        mouse.trace.add(mouse.prev);
      }
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
      println("beads-mode : click");
      // ノードをクリックしている場合には、クロスチェンジする。
      for (int nodeID=0; nodeID<graph.nodes.size(); nodeID++) {
        Node node = graph.nodes.get(nodeID);
        if (node.inUse) {
          float mX = disp.getX_fromWin(mouseX);
          float mY = disp.getY_fromWin(mouseY);
          if (dist(mX, mY, node.x, node.y)<10) {
            if (node.Joint) {
              println("cross change");
              graph.crosschange(nodeID);
            }
            break;
          }
        }
      }
      // Joint以外をクリックした場合には、miJointの増減を行う。
      for (int beadID=0; beadID<data.points.size(); beadID++) {
        Bead bd = data.getBead(beadID);
        if (bd==null) {
          continue;
        }
        float mX = disp.getX_fromWin(mouseX);
        float mY = disp.getY_fromWin(mouseY);
        if (dist(mX, mY, bd.x, bd.y)<10) {
          if ( ! bd.Joint ) {  
            if ( ! bd.midJoint ) {// 普通のビーズの場合には、両端を調べたうえでmidJointにする。
              int bdn1ID = bd.n1;
              int bdn2ID = bd.n2;
              // 両端がJointかmidJointだったら何もしない。
              Bead bdn1 = data.getBead(bdn1ID);
              Bead bdn2 = data.getBead(bdn2ID);
              if (bdn1 == null || bdn2 == null) {
                break;
              }
              if (bdn1.Joint || bdn1.midJoint || bdn2.Joint || bdn2.midJoint) {
                break ;
              }
              // bdをmidJointにする
              bd.midJoint = true;
              // ノードを一つ新規追加する
              Node newNd = new Node(bd.x, bd.y);
              newNd.theta = -atan2(bdn1.y - bd.y, bdn1.x - bd.x);
              newNd.pointID = beadID;
              graph.nodes.add(newNd);
              int newNdID = graph.nodes.size()-1;
              // bdからn1方向に次のJoint, midJointを探す。
              int nodeBeadN1 = graph.findJointInPoints(beadID, bdn1ID);
              // bdからn2方向に次のJoint, midJointを探す。
              int nodeBeadN2 = graph.findJointInPoints(beadID, bdn2ID);
              int nodeN1=-1, nodeN2 = -1;
              // 対応するノードの番号を探す
              for (int nodeID=0; nodeID<graph.nodes.size(); nodeID++) {
                Node nd = graph.nodes.get(nodeID);
                if (nd.inUse) {
                  if (nd.pointID == nodeBeadN1) {
                    nodeN1 = nodeID;
                  }
                  if (nd.pointID == nodeBeadN2) {
                    nodeN2 = nodeID;
                  }
                }
              }
              //このノードを両端とするエッジを探す。
              //int thisEdgeID = -1;

              for (int edgeID=0; edgeID<graph.edges.size(); edgeID++) {
                Edge ed = graph.edges.get(edgeID);

                if (ed.ANodeID == nodeN1 && ed.BNodeID == nodeN2) {
                  //thisEdgeID = edgeID;
                  //エッジを新規追加する。
                  Edge newEdge = new Edge(newNdID, 2, ed.BNodeID, ed.BNodeRID);
                  graph.edges.add(newEdge);
                  //このエッジの情報を書き直す。
                  ed.BNodeID = newNdID;
                  ed.BNodeRID = 0;
                  graph.modify();
                  println("midJoint追加完了1");
                  break;
                } else if (ed.ANodeID == nodeN2 && ed.BNodeID == nodeN1) {
                  //thisEdgeID = edgeID;
                  //エッジを新規追加する。
                  Edge newEdge = new Edge(newNdID, 0, ed.BNodeID, ed.BNodeRID);
                  graph.edges.add(newEdge);
                  //このエッジの情報を書き直す。
                  ed.BNodeID = newNdID;
                  ed.BNodeRID = 2;
                  // modifyする。
                  graph.modify();
                  println("midJoint追加完了2");
                  break;
                }
              }
            } else {//ミッドジョイントの場合には、普通のビーズへ変更する。
              // 　クリックしたビーズのIDを得る。
              //Bead bd = data.points.get(beadID);
              //そのビーズのノード番号を得る nodeID
              int nodeID = -1;
              for (int ndID = 0; ndID<graph.nodes.size(); ndID ++) {
                Node nd = graph.nodes.get(ndID); 
                if (nd.inUse && nd.pointID == beadID) {
                  nodeID = ndID;
                  break;
                }
              }
              //bdからn1方向にたどったJoint,midJointoを探す。そしてそのノード番号を探す。 nodeN1
              int bdn1ID = bd.n1;
              int nodeBeadN1 = graph.findJointInPoints(beadID, bdn1ID);
              //bdからn2方向にたどったJoint,midJointoを探す。そしてそのノード番号を探す。 nodeN2
              int bdn2ID = bd.n2;
              int nodeBeadN2 = graph.findJointInPoints(beadID, bdn2ID);
              int nodeN1=-1, nodeN2 = -1;
              // 対応するノードの番号を探す
              for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
                Node nd = graph.nodes.get(ndID);
                if (nd.inUse) {
                  if (nd.pointID == nodeBeadN1) {
                    nodeN1 = ndID;
                  }
                  if (nd.pointID == nodeBeadN2) {
                    nodeN2 = ndID;
                  }
                }
              }
              //nodeIDとnodeN1IDを両端とするエッジedgeN1をみつける
              //nodeIDとnodeN2を両端とするエッジedgeN2とを見つける。
              Edge edgeN1= null;
              int edgeN2ID = -1;
              int ANode=-1, ANodeR=-1, BNode=-1, BNodeR=-1;
              for (int edgeID=0; edgeID<graph.edges.size(); edgeID++) {
                Edge ed = graph.edges.get(edgeID);
                if (ed.ANodeID == nodeID && ed.BNodeID == nodeN1) {
                  edgeN1 = ed;
                  ANode = ed.BNodeID;
                  ANodeR = ed.BNodeRID;
                } else if (ed.BNodeID == nodeID && ed.ANodeID == nodeN1) {
                  edgeN1 = ed;
                  ANode = ed.ANodeID;
                  ANodeR = ed.ANodeRID;
                } else if (ed.ANodeID == nodeID && ed.BNodeID == nodeN2) {
                  edgeN2ID = edgeID;
                  BNode = ed.BNodeID;
                  BNodeR = ed.BNodeRID;
                } else if (ed.BNodeID == nodeID && ed.ANodeID == nodeN2) {
                  edgeN2ID = edgeID;
                  BNode = ed.ANodeID;
                  BNodeR = ed.ANodeRID;
                }
              }
              if (edgeN1 != null) {
                //そのビーズのmidJointをfalseにする。
                bd.midJoint = false;
                //エッジを合流し、一つをedgesから消す。
                edgeN1.ANodeID = ANode;
                edgeN1.ANodeRID = ANodeR;
                edgeN1.BNodeID = BNode;
                edgeN1.BNodeRID = BNodeR;
                graph.edges.remove(edgeN2ID);
                graph.removeNode(nodeID);//ノードを消す代わりに未使用状態にする。
                println("ミッドジョイント消去完了");
              }
            }
            break;
          }
        }
      }
    } else {
      //クリックでなくドラッグの場合
      //jointでないところで終わりにする
      if (mouse.new_curve) {
        mouse.new_curve=false;
        //endIDをptIDとしている
        int ptID = graph.is_PVector_on_points(mouseX, mouseY);
        if (ptID==-1) {
          return;
        } else {
          Bead pt=data.getBead(ptID);
          if (pt.Joint) {////////////////////////////////midJointやJointの隣も含むか要検討
            return;
          } else {
            //println("ここで作業をする");
            println(startID, ptID);
            int i=data.findArcFromPoints(startID, ptID);
            //if (i==1) {
            //  println("1");
            //} else if (i==2) {
            //  println("2");
            //} else if (i==-1) {
            //  println("できませんでした");
            //} else {//0のとき
            //  println("ここで作業をする");
            //}
            if (i==1||i==2) {
              println(count_for_distinguishing_edge);//間のbeadsの数。ただしstartIDとptIDは含まない
              data.extinguish_points(i, count_for_distinguishing_edge, startID, ptID);
              data.extinguish(count_for_distinguishing_edge); 
              data.extinguish_startID_and_endID(i, startID, ptID);
              mouse.trace_to_parts_editing2(data, startID, ptID);//ここで線をビーズにする 
              //traceからもらってくればよい
            } else {
              println("できませんでした");
            }
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
        } else if (dist(bd.x, bd.y, mouseX, mouseY) < 35f) {//もしノードが近くにある場合は
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
            if (bd.c<2 && dist(bd.x, bd.y, mouseX, mouseY)<15) {
              endBdID = bdID;//終了地点のビーズIDを特定する。
              OK = true;
              break;
            }
          }
          if (OK) {
            mouse.trace_to_parts_editing(data, graph, edit, endBdID);
          }
        }
        mouse.node_next_dragging=false; // ドラッグ終了
      }
    }
  }
}