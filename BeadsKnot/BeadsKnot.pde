import java.awt.*;    //<>//
import javax.swing.*;

// globals
// image analysis
dataExtract data;// segment data obtained from an image
dataGraph graph;// graph data obtained from extraction

// display 
displayWorld disp;// display mode, in display.pde
displayMessage dispM; // show massage, in utils.pde

// constants and options
EdgeConst ec;// constants of edges
String fileName="test";// save/open filename
float beadsInterval = 15 ;// intervals between beads ( world coordinate)
drawOption Draw;// options for drawings

// class of dragging mouse
mouseDrag mouse;
// TODO: investigate why this is not the member of mouseDrag
int mousedragStartID;

// class of editing knot fragment
partsEditing edit;

// class of orientation of links
knotOrientation orie;

// class of region of knot diagram
//ArrayList <region> reg;

// class of seifert surface
seifert seif;

// ???? TODO check this constants
int count_for_distinguishing_edge=0;//edgeを消すためのcountの数
// end of globals

// initializing all things
void setup() {
  int extractSize=1000;
  size(1000, 1000);// pane size
  // initializing
  disp = new displayWorld(1000, 1000);
  dispM = new displayMessage();
  data = new dataExtract(extractSize, extractSize, disp);
  graph = new dataGraph(data);
  ec = new EdgeConst();
  Draw = new drawOption();
  mouse = new mouseDrag();
  edit = new partsEditing();
  // TODO: change variable name orientation and 
  // change class name knotOrientation
  orie=new knotOrientation(data, graph);
  // TODO: create a class for this purpose
  //reg=new ArrayList<region>();
  // TODO: change class name into seifertSurface
  seif=new seifert(data, graph, orie, mouse);
}


void draw() {
  background(255);
  if (Draw._menu) {
    dispM.showMenu();
  } else if (Draw._binarized_image) {// 二値化したデータを表示
    loadPixels();
    for (int x=0; x<data.w; x++) {
      for (int y=0; y<data.h; y++) {
        pixels[x + y*width] = color(255*(1-data.d[x][y]));
      }
    }
    updatePixels();
  }
  //dataExtractの内容を描画する場合。
  if (Draw._beads) {
    disp.modify();
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
  } else if (Draw._line_without_beads) {
    strokeWeight(5);
    data.drawNbhds();
    strokeWeight(1);
  } else if (Draw._beads_with_Seifelt) {
    disp.modify();
    for (region r : seif.reg) {
      r.paintRegion();
    }
    data.drawNbhds();
    data.drawPoints();
    if (mouse.new_curve) {
      mouse.draw_trace();
    }
  } else if (Draw._band_film) {
    disp.modify();
    data.drawNbhds();
    data.drawPoints();
    if (mouse.new_curve) {
      mouse.draw_trace();
    }
  }

  // 平面グラフのデータを表示
  else if (Draw._dataGraph) {
    graph.draw_nodes_edges();
  } else if (Draw._free_loop) {
    dispM.show("Draw a free loop.");
    mouse.draw_trace();
  } else if (Draw._partsEditing) {
    dispM.show("A crossing by a click, connecting two crossings by mouse-drag.");
    edit.draw_parts();
    mouse.draw_trace();
    //} else if (Draw._posinega) {
    //  //posinegaの関数を呼び出す
    //  data.drawNbhds();
    //  data.draw_posinega_Points();
  } else if (Draw._smoothing) {
    //smoothingの関数を呼び出す
    float mX=mouseX, mY=mouseY;
    for (int repeat = 0; repeat<10; repeat++) {
      Nbhd nearNb = data.get_near_nbhd(mX, mY);
      if (nearNb == null) {
        //println("break;");
        break;
      }
      int count = data.smoothingRegionContainsPt(mouseX, mouseY, nearNb, false);
      if (count<0) {
        // println("break;");
        break;
      }
      if (count%2 == 1) {
        data.draw_smoothing_region(nearNb);
        break;
      } else {
        mX = data.nearX+1f;
        //println(count, int(mX), " ");
      }
    }
    data.draw_smoothing_Nbhds();
    data.draw_smoothing_Points();
    //drawNbhdsを変える
  }
}

void saveFileSelect(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    int fileName_length= fileName.length();
    String extension=fileName.substring(fileName_length-3);
    if (extension.equals("png") || extension.equals("jpg") || extension.equals("gif")) {
      Draw.line_without_beads();
      redraw();
      delay(1000);
      save(fileName);// 画像として保存
      Draw.beads();
    } else if (extension.equals("lnk")) {
      PLink PL=new PLink(data, disp);
      PL.file_output();
    } else {
      PrintWriter file; 
      file = createWriter(fileName);
      file.println("BeadsKnot,0");
      file.println("Nodes,"+graph.nodes.size());
      for (int nodeID=0; nodeID<graph.nodes.size(); nodeID++) {
        Node nd = graph.nodes.get(nodeID);
        if (nd.inUse) {
          file.print(nd.x+","+nd.y+","+nd.theta+",");
          file.println(nd.r[0]+","+nd.r[1]+","+nd.r[2]+","+nd.r[3]);
        } else {
          file.print(0+","+0+","+0+",");
          file.println(10+","+10+","+10+","+10);
        }
      }
      file.println("Edges,"+graph.edges.size());
      for (int edgeID=0; edgeID<graph.edges.size(); edgeID++) {
        Edge ed = graph.edges.get(edgeID);
        file.println(ed.ANodeID+","+ed.ANodeRID+","+ed.BNodeID+","+ed.BNodeRID);
      }
      ////ここにregion関連のデータを入れる
      ////はじめに色情報、その次にedgeの番号
      ////色情報はcol_codeでいける?
      ////クリックされていない白い領域の部分のデータも必要？
      ////ただしnbhdがないとたどれないからそのデータを取得できない？
      //int count=0;
      //for (int i=0; i<data.points.size(); i++) {
      //  Bead vec=data.getBead(i);
      //  if (vec.Joint) {
      //    count++;
      //  }
      //}
      file.println("Region,"+seif.reg.size());
      //int col_code_num[]=new int[(count+1)];
      //for (int i=0; i<(count+1); i++) {
      //col_code_num[i]=-1;
      //}
      for (int b=0; b<seif.reg.size(); b++) {
        //////////col_codeが0の部分も描く必要ある？
        region r = seif.reg.get(b);
        file.print(r.col_code+",");
        //col_code_num[b]=int(r.col_code);
        //count+1分の行を作成し、0を入れる  
        for (int bb=0; bb<r.border.size(); bb++) {
          Edge e=r.border.get(bb);
          file.print(e.ANodeID+","+e.ANodeRID+","+e.BNodeID+","+e.BNodeRID);
          file.print(",");
        }
        file.println();
      }
      //for (int i=0; i<(count+1); i++) {
      //  if (col_code_num[i]==-1) {
      //    file.println(0);
      //  }
      //}
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
    fileName=selection.getAbsolutePath();
    int fileName_length= fileName.length();
    String extension=fileName.substring(fileName_length-3);
    if (extension.equals("png")==true||extension.equals("jpg")==true||extension.equals("gif")==true) {
      PImage image = loadImage(selection.getAbsolutePath());
      if (data.make_dataExtraction(image)) {//一発で成功した場合
        graph.make_dataGraph();
      }
      fileName=fileName.substring(0, fileName_length-4);
    } else if (extension.equals("dwk")==true) {
      // read from dowker file
      // file format: a sequence of even integers separated by spaces
      // 2 6 4 8
      BufferedReader reader = createReader(fileName); 
      String line = null;
      try {
        if ((line = reader.readLine()) != null) {
          String[] pieces = split(line, ' ' );
          dowker dk = new dowker(graph);
          dk.dowkerCount = pieces.length;
          for (int p=0; p< dk.dowkerCount; p++) {
            dk.dowker[p] = int(pieces[p]);
          }
          dk.Start();
        }
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    } else {// BeadsKnot (original) file
      BufferedReader reader = createReader(fileName); 
      String line = null;
      int version = -1;
      // TODO: make a deepcopy of the contents.
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
                bd.u1 = bd.u2 = -1;
                bd.Joint = bd.midJoint = false;
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
            //data.debugLogPoints("0123.csv");
            Draw.beads();// drawモードの変更
          }
          // about regions
          if ((line = reader.readLine()) != null) {
            String[] pieces = split(line, ',' );
            if (pieces[0].equals("Region")) {
              //ここから書く
              int region_number = int(pieces[1]);
              seif.reg.clear(); 
              region RG;
              //RG.border.clear();
              //RG.border=new ArrayList<Edge>();
              for (int i=0; i<region_number; i++) {
                RG=new region(data, graph, orie);
                line = reader.readLine(); 
                pieces = split(line, ',');
                Edge ed;
                for (int l=0; l<(pieces.length)/4; l++) {//piecesの長さはいくつか
                  ed = new Edge(int(pieces[l*4+1]), int(pieces[l*4+2]), int(pieces[l*4+3]), int(pieces[(l+1)*4]));
                  RG.col_code=int(pieces[0]);
                  if (RG.col_code!=0) {
                    RG.border.add(ed);
                  }
                }
                seif.reg.add(RG);
                //pieces[0]はcol_codeになる
                //ない行のpieces[0]のcol_codeは0(白)にする
              }
              if (seif.reg.size()!=0) {
                Draw.beads_with_Seifelt();
              }
              ///////RG.borderにデータは入っている
              // println(reg.size());
              //どこかでregにaddをしなくてはいけない
              //println(RG.border.size());
            }
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
  if (Draw._beads||Draw._smoothing||Draw._band_film) {
    int ptID = graph.is_PVector_on_points(mouseX, mouseY);
    int jointID = graph.is_PVector_on_Joints(mouseX, mouseY);
    if (ptID!=-1) {
      if (jointID != -1) {//nodeをドラッグする
        mouse.node_dragging = true;
        for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
          Node nd = graph.nodes.get(ndID); 
          if (nd.inUse && nd.pointID == jointID) {
            mouse.dragged_nodeID = ndID;
            int pt0ID = graph.nodes.get(mouse.dragged_nodeID).pointID;
            Bead pt0 = data.getBead(pt0ID);
            mouse.DragX = pt0.x;
            mouse.DragY = pt0.y;
            println("ノードのドラッグ開始");
            return;
          }
        }
      } else {//beadsをドラックし始めたけれどもJointでない場合
        int jt_ndID =graph.next_to_node(ptID); 
        if (jt_ndID==-1) {//ノードの隣でないところをドラッグした場合
          println("新規パス開始");
          mousedragStartID=graph.is_PVector_on_points(mouseX, mouseY);
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
  } else if (Draw._partsEditing) {
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
  } else if (Draw._beads_with_Seifelt) {
    //////////////////////////クリックした場所の領域が塗られる
    //////JointでないBeadsに近いところをクリックしたら
    int ptID = graph.is_PVector_on_points(mouseX, mouseY);
    int jointID = graph.is_PVector_on_Joints(mouseX, mouseY);
    if (ptID!=-1) {
      if (jointID==-1) {
        int jt_ndID =graph.next_to_node(ptID); 
        if (jt_ndID==-1) {//ノードの隣でないところをドラッグした場合
          println("新規パス開始");
          mousedragStartID=graph.is_PVector_on_points(mouseX, mouseY);
          mouse.prev = new PVector(mouseX, mouseY);
          mouse.trace.clear();
          mouse.trace.add(mouse.prev);
          mouse.new_curve=true;
          mouse.free_dragging = true;
        }
      } else {
        mouse.node_dragging = true;
        for (int ndID=0; ndID<graph.nodes.size(); ndID++) {
          Node nd = graph.nodes.get(ndID); 
          if (nd.inUse && nd.pointID == jointID) {
            mouse.dragged_nodeID = ndID;
            int pt0ID = graph.nodes.get(mouse.dragged_nodeID).pointID;
            Bead pt0 = data.getBead(pt0ID);
            mouse.DragX = pt0.x;
            mouse.DragY = pt0.y;
            println("ノードのドラッグ開始");
            return;
          }
        }
      }
      //ptIDが-1でなくてjointIDは-1のときにマウストラックを取りに行く
      //Jointクリックでは何もしない
      //ptIDは-1のときには領域を塗る
    } else {
      Nbhd nearNb = data.get_near_nbhd(mouseX, mouseY);
      region RG;
      RG=new region(data, graph, orie);
      RG.get_region_from_Nbhd(nearNb, false);
      boolean painted=false;
      for (int r=0; r<seif.reg.size(); r++) {
        if (seif.reg.get(r).match_region(RG)) {
          seif.reg.get(r).col_code=(seif.reg.get(r).col_code+1)%3;
          painted=true;
          //reg.get(r)の色に従って色を変える
        }
      }
      if (!painted) {
        seif.reg.add(RG);
      }
      seif.find_nbhd_region(RG);
    }
  }
}

void mouseDragged() {
  //if (Draw._beads) {
  if (Draw._beads||Draw._smoothing||Draw._beads_with_Seifelt||Draw._band_film) {
    if (mouse.node_dragging && mouse.dragged_nodeID!=-1) {//ドラッグされたらと同じ意味
      float mX = disp.getX_fromWin(mouseX);
      float mY = disp.getY_fromWin(mouseY);

      float mouseDragmin_dist = dist(mouse.DragX, mouse.DragY, mX, mY);
      for (int ndID=0; ndID<graph.nodes.size(); ndID++) {//beadsが近づきすぎない
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
              println("ジョイント"+mouse.dragged_nodeID+"がジョイント"+ndID+"に近づきすぎです。");
              return;
            }
            if (d > 1500/disp.rate) {//あまり外側へ行ったら処理をしない。
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
      for (int repeat=0; repeat<5; repeat++) {
        graph.rotation_shape_modifier(mouse.dragged_nodeID);
      }
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
      if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beadsInterval-1) {
        mouse.prev = new PVector(mouseX, mouseY);
        mouse.trace.add(mouse.prev);
      }
    }
  } else if (Draw._free_loop) {
    if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beadsInterval-1) {
      mouse.prev = new PVector(mouseX, mouseY);
      mouse.trace.add(mouse.prev);
    }
  } else if (Draw._partsEditing) {
    if (mouse.node_next_dragging) {
      if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beadsInterval-1) {
        mouse.prev = new PVector(mouseX, mouseY);
        mouse.trace.add(mouse.prev);
      }
    }
    //} else if (Draw._beads_with_Seifelt) {
    //  if (dist(mouseX, mouseY, mouse.prev.x, mouse.prev.y)>beadsInterval-1) {//////////////////////////////エラーでる
    //    mouse.prev = new PVector(mouseX, mouseY);
    //    mouse.trace.add(mouse.prev);
    //  }
  }
}

void mouseReleased() {
  if (Draw._menu) {
    int y=60;
    if (dist(mouseX, mouseY, mouse.PressX, mouse.PressY)<1.0) {// クリック
      if (mouseY < y) {// key 'e' と同じ
        Draw.partsEditing();
        mouse.trace.clear();
        edit.beads.clear();
        return ;
      }
      y += 40;
      if (mouseY < y) {// key 'n' と同じ
        Draw.free_loop();
        mouse.trace.clear();// 絵のクリア
        return;
      }
      y += 40;
      if (mouseY < y) {// key 'o' と同じ
        selectInput("Select a file to process:", "fileSelected");
        return ;
      }      
      y += 40;
      if (mouseY < y) {// key 's' と同じ
        selectInput("Select a file to save", "saveFileSelect");
        return;
      }
    }
  } else if (Draw._beads) {
    mouse.node_dragging=false;
    mouse.dragged_nodeID=-1;
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
                //エッジを合流し、一つをoedgesから消す。
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
            println(mousedragStartID, ptID);
            int i=data.findArcFromPoints(mousedragStartID, ptID);
            if (i==1||i==2) {
              println(count_for_distinguishing_edge);//間のbeadsの数。ただしstartIDとptIDは含まない
              data.extinguish_points(i, count_for_distinguishing_edge, mousedragStartID, ptID);
              data.extinguish(count_for_distinguishing_edge); 
              data.extinguish_startID_and_endID(i, mousedragStartID, ptID);
              mouse.trace_to_partsEditing2(data, mousedragStartID, ptID);//ここで線をビーズにする 
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
  } else if (Draw._partsEditing) {
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
            mouse.trace_to_partsEditing(data, graph, edit, endBdID);
          }
        }
        mouse.node_next_dragging=false; // ドラッグ終了
      }
    }
  } else if (Draw._beads_with_Seifelt) {
    mouse.node_dragging=false;
    mouse.dragged_nodeID=-1;
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
          }
        }
      }
    }
  } else if (Draw._band_film) {
    mouse.node_dragging=false;
    mouse.dragged_nodeID=-1;
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
            println(mousedragStartID, ptID);
            int i=data.findArcFromPoints(mousedragStartID, ptID);
            if (i==1||i==2) {
              println(count_for_distinguishing_edge);//間のbeadsの数。ただしstartIDとptIDは含まない
              data.extinguish_points(i, count_for_distinguishing_edge, mousedragStartID, ptID);
              data.extinguish(count_for_distinguishing_edge); 
              data.extinguish_startID_and_endID(i, mousedragStartID, ptID);
              mouse.trace_to_partsEditing2(data, mousedragStartID, ptID);//ここで線をビーズにする 
              //traceからもらってくればよい
            } else {
              Bead s=data.getBead(mousedragStartID);
              Bead e=data.getBead(ptID);
              /////////////////////////////sからでるedgeを探して同じnodeがあったらbandJointをtrueにする
              // println(data.condition_bandJoint(mousedragStartID, ptID));
              pairInt JointID_for_bandJoint=data.condition_bandJoint(mousedragStartID, ptID);
              if (JointID_for_bandJoint.a!=-1) {
                s.bandJoint=true;
                e.bandJoint=true;
                //bandJointは三本を許すJointっぽいものが必要
                //data.extinguish_points(i, count_for_distinguishing_edge, startID, ptID);
                //data.extinguish(count_for_distinguishing_edge); 
                //data.extinguish_startID_and_endID(i, startID, ptID);
                mouse.trace_to_partsEditing3(data, mousedragStartID, ptID);
                int s12=JointID_for_bandJoint.b;
                int e12=JointID_for_bandJoint.c;
                int su1=s.u1;
                int su2=s.u2;
                int eu1=e.u1;
                int eu2=e.u2;
                if (s12==1&&su1!=-1) {
                  s.u2=s.n1;
                  s.n1=s.u1;
                  s.u1=-1;
                  ///////////////n2が本線なのでfalse
                  s.bandJoint_flag=false;
                } else if (s12==1&&su2!=-1) {
                  s.u1=s.n1;
                  s.n1=s.u2;
                  s.u2=-1;
                  ///////////////n2が本線なのでfalse
                  s.bandJoint_flag=false;
                } else if (s12==2&&su1!=-1) {
                  s.u2=s.n2;
                  s.n2=s.u1;
                  s.u1=-1;
                  ///////////////n1が本線なのでtrue
                  s.bandJoint_flag=true;
                } else if (s12==2&&su2!=-1) {
                  s.u1=s.n2;
                  s.n2=s.u2;
                  s.u2=-1;
                  ///////////////n1が本線なのでtrue
                  s.bandJoint_flag=true;
                }
                if (e12==1&&eu1!=-1) {
                  e.u2=e.n1;
                  e.n1=e.u1;
                  e.u1=-1;
                  e.bandJoint_flag=false;
                } else if (e12==1&&eu2!=-1) {
                  e.u1=e.n1;
                  e.n1=e.u2;
                  e.u2=-1;
                  e.bandJoint_flag=false;
                } else if (e12==2&&eu1!=-1) {
                  e.u2=e.n2;
                  e.n2=e.u1;
                  e.u1=-1;
                  e.bandJoint_flag=true;
                } else if (e12==2&&eu2!=-1) {
                  e.u1=e.n2;
                  e.n2=e.u2;
                  e.u2=-1;
                  e.bandJoint_flag=true;
                }
                graph.make_dataGraph();
                //枝のすげ替え問題
                //bandっぽく見えるように
                //JointID_for_bandJoint
              }
            }
          }
        }
      }
    }
  }
}

class pairInt {
  int a, b, c;
  pairInt(int _a, int _b, int _c) {
    a=_a;
    b=_b;
    c=_c;
  }
  pairInt(int _a) {
    a=_a;
    b=0;
    c=0;
  }
}