class data_graph {
  //データのグラフ構造
  //nodeとedgeからなる

  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  data_extract de; 
  int[] table;
  display disp;
  //boolean data_graph_complete=false;//->いずれdrawOptionへ移動。

  // コンストラクタ
  data_graph(data_extract _de) {
    nodes = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
    de = _de;
    disp = de.disp;
  }

  // deのデータから
  //nodesやedgesを決める
  void make_data_graph() {
    nodes.clear();
    edges.clear();
    modify_Joint_orientation();
    add_half_point_Joint();
    add_close_point_Joint();// half_pointと合流できないか？
    get_node_table();
    get_data_nodes_edges();  
    println("data_graphを完了しました", nodes.size(), edges.size());    
    Draw.beads(); // draw option の変更
  }

  // deのデータから
  //nodesやedgesを決める（その１）
  //準備として、u1,u2の向きが適切なものにする。
  void modify_Joint_orientation() {
    for (int i=0; i<de.points.size (); i++) {
      Bead vec=de.points.get(i);
      if (vec.Joint) {
        if (vec.u1<0||vec.u1>=de.points.size()||vec.u2<0||vec.u2>=de.points.size()) {
          return;
        }
        //println(vec.n1, vec.u1, vec.n2, vec.u2);
        Bead vecn1=de.points.get(vec.n1);
        float x0=vecn1.x;
        float y0=vecn1.y;
        Bead vecu1=de.points.get(vec.u1);
        float x1=vecu1.x;
        float y1=vecu1.y;
        Bead vecn2=de.points.get(vec.n2);
        float x2=vecn2.x;
        float y2=vecn2.y;
        Bead vecu2=de.points.get(vec.u2);
        float x3=vecu2.x;
        float y3=vecu2.y;
        float x02=x0-x2;//a
        float y02=y0-y2;//b
        float x13=x1-x3;//c
        float y13=y1-y3;//d
        if (x02*y13-y02*x13>0) {
          int a=vec.u1;
          vec.u1=vec.u2;
          vec.u2=a;
        }
      }
    }
  }

  // deのデータから
  //nodesやedgesを決める（その２）
  //一度全体をクリアして、
  //　エッジの真ん中にあたるビーズをノードにする。
  void add_half_point_Joint() {
    for (int p = 0; p < de.points.size(); p++) {
      Bead bd = de.points.get(p);
      bd.midJoint = false;
    }
    for (int p = 0; p < de.points.size(); p++) {
      Bead bd = de.points.get(p);
      if (bd.Joint) {
        int nextJoint=find_next_Joint_in_points(p, bd.n1);
        if (p<=nextJoint) {
          int count = countNeighborJointInPoints(p, bd.n1);
          int half = get_half_position(p, bd.n1, int(count * 0.5));
          de.points.get(half).midJoint=true;
        }
        nextJoint=find_next_Joint_in_points(p, bd.u1);
        if (p<=nextJoint) {
          int count = countNeighborJointInPoints(p, bd.u1);
          int half = get_half_position(p, bd.u1, int(count * 0.5));
          de.points.get(half).midJoint=true;
        }
        nextJoint=find_next_Joint_in_points(p, bd.n2);
        if (p<=nextJoint) {
          int count = countNeighborJointInPoints(p, bd.n2);
          int half = get_half_position(p, bd.n2, int(count * 0.5));
          de.points.get(half).midJoint=true;
        }
        nextJoint=find_next_Joint_in_points(p, bd.u2);
        if (p<=nextJoint) {
          int count = countNeighborJointInPoints(p, bd.u2);
          int half = get_half_position(p, bd.u2, int(count * 0.5));
          de.points.get(half).midJoint=true;
        }
      }
    }
  }

  // deのデータから
  //nodesやedgesを決める（その３）
  //　エッジの端のほうにあるビーズをclosepointにする。
  //　これはPLinkファイルをつくるため。
  void add_close_point_Joint() {//Ten Percent Neighborhood point
    for (int p = 0; p < de.points.size(); p++) {
      Bead bd = de.points.get(p);
      bd.closeJoint = false;
    }
    for (int pt = 0; pt < de.points.size(); pt++) {
      Bead bd = de.points.get(pt);
      if (bd.Joint) {
        int count = countNeighborJointInPoints(pt, bd.n1);
        int p_close = get_half_position(pt, bd.n1, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        count = countNeighborJointInPoints(pt, bd.u1);
        p_close = get_half_position(pt, bd.u1, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        count = countNeighborJointInPoints(pt, bd.n2);
        p_close = get_half_position(pt, bd.n2, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        count = countNeighborJointInPoints(pt, bd.u2);
        p_close = get_half_position(pt, bd.u2, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
      }
    }
  }

  int find_next_Joint_in_points(int j, int c) {
    //print("find_next_Joint_in_points:", j, c);
    for (int count = 0; count < de.points.size(); count++) {
      Bead p=de.points.get(c);
      if (p.Joint) {
        //println();
        return c;
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("間違っている");
        return -1;
      }
      //print(" "+d);
      j = c;
      c = d;
    }
    return -1;
  }

  int findNeighborJointInPoints(int j, int c) {
    //print("findNeighborJointInPoints",j,c);
    for (int count = 0; count < de.points.size(); count++) {
      Bead p=de.points.get(c);
      if (p.Joint||p.midJoint) {
        return j;
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("間違っている");
        return -1;
      }
      j=c;
      c=d;
    }
    return -1;
  }

  private int countNeighborJointInPoints(int j, int c) {
    //print("countNeighborJointInPoints",j,c);
    for (int count = 1; count < de.points.size(); count++) {
      Bead p=de.points.get(c);
      if (p.Joint||p.midJoint) {
        return count;
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("間違っている");
        return 0;
      }
      j=c;
      c=d;
    }
    return 0;
  }
  
  int get_half_position(int j, int c, int number) {
    if (number==0) {
      return c;
    }
    for(int count=1; count<number; count++){
      Bead p=de.points.get(c);
      if (p.Joint) {
        println("get_half_position : エラー");
        return -1;
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("間違っている");
        return -1;
      }
      j=c;
      c=d;
    }
    return c;
  }


  int findJointInPoints(int j, int c) {
    for (int count = 0; count < de.points.size(); count++) {
      Bead p=de.points.get(c);
      if (p.Joint||p.midJoint) {
        return c;
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("間違っている","");
      } 
      j=c;
      c=d;
    }
    return -1;
  }

  int findk(Bead joint, int j) {
    if (joint.n1==j) {
      return 0;
    } else if (joint.u1==j) {
      return 1;
    } else   if (joint.n2==j) {
      return 2;
    } else   if (joint.u2==j) {
      return 3;
    } else {
      return -1;
    }
  }

  int getNodesFromPoint(int p) {
    for (int i = 0; i < table.length; i++) {
      if (table[i]==p) {
        return i;
      }
    }
    return -1;
  }

  //void get_node_table
  // deのデータからnodesやedgesを決める（その４）
  //Jointつきビーズの番号と、ノードの番号の対応表を作る
  void get_node_table() {
    int count=0;
    for (int i = 0; i < de.points.size(); i++) {
      Bead vec = de.points.get(i);
      if (vec.Joint||vec.midJoint) {
        count++;
      }
    }
    table=new int[count];
    count=0;
    for (int i = 0; i < de.points.size(); i++) {
      Bead vec = de.points.get(i);
      if (vec.Joint||vec.midJoint) {
        table[count]=i;
        count++;
      }
    }
  }

  // 形を整える。ただし、これが良いとは限らない。
  // ビーズに戻して物理モデルで整形するという考えもある。
  void modify() {
    //Nodeのr[]を最適化する
    for (Edge edge : edges) {
      edge.scaling_shape_modifier(nodes);
    }
    //Nodeのthetaを最適化する
    //for (int repeat=0; repeat < 1; repeat ++) {
    //  for (int n=0; n<nodes.size(); n++) {
    //    rotation_shape_modifier(n);
    //  }
    //}
    //Nodeの(x,y)を最適化する
    //nodeCoordinateModifier(nodes, edges);
    // 絵の範囲を求めて適切に描画する
    get_disp();
  }

  //Nodeのthetaを最適化する
  void rotation_shape_modifier(int id) {
    Node node = nodes.get(id);
    float totalRangeAngle=0f;
    float theta0 = node.theta;
    float Min = 0f, Max = 0f;
    Min = 9999f;
    Max = -9999f;
    for (int e=0; e<edges.size(); e++) {
      Edge ed = edges.get(e);
      if (ed.ANodeID == id || ed.BNodeID== id) {
        ed.set_bezier(nodes);
        PVector minmax = ed.bezier.get_curvature_range();
        if (Min>minmax.x) Min = minmax.x;
        if (Max<minmax.y) Max = minmax.y;
        //        totalRangeAngle += (minmax.y - minmax.x);
      }
    }
    totalRangeAngle = Max - Min;

    float totalRangeAngleP=0f;
    float thetaP = theta0 + 0.05f;
    node.theta = thetaP;
    Min = 9999f;
    Max = -9999f;
    for (int e=0; e<edges.size(); e++) {
      Edge ed = edges.get(e);
      if (ed.ANodeID == id || ed.BNodeID== id) {
        ed.set_bezier(nodes);
        PVector minmax = ed.bezier.get_curvature_range();
        if (Min>minmax.x) Min = minmax.x;
        if (Max<minmax.y) Max = minmax.y;
        //        totalRangeAngleP += (minmax.y - minmax.x);
      }
    }
    totalRangeAngleP = Max - Min;

    float totalRangeAngleM=0f;
    float thetaM = theta0 - 0.05f;
    node.theta = thetaM;
    Min = 9999f;
    Max = -9999f;
    for (int e=0; e<edges.size(); e++) {
      Edge ed = edges.get(e);
      if (ed.ANodeID == id || ed.BNodeID== id) {
        ed.set_bezier(nodes);
        PVector minmax = ed.bezier.get_curvature_range();
        if (Min>minmax.x) Min = minmax.x;
        if (Max<minmax.y) Max = minmax.y;
        //        totalRangeAngleM += (minmax.y - minmax.x);
      }
    }
    totalRangeAngleM = Max - Min;
    //println("RangeAngle= ", totalRangeAngle, totalRangeAngleP, totalRangeAngleM);
    if (totalRangeAngle  > totalRangeAngleP) {
      node.theta = thetaP;
    } else if (totalRangeAngle -1.0 > totalRangeAngleM) {
      node.theta = thetaM;
    } else {
      node.theta = theta0;
    }
    return ;
  }

  //絵のサイズをdisplayに格納する。→適切なサイズで表示される。
  void get_disp() {
    float l=0, t=0, r=0, b=0;
    for (int e=0; e<edges.size (); e++) {
      Edge ed = edges.get(e);
      Node ANode=nodes.get(ed.ANodeID);
      Node BNode=nodes.get(ed.BNodeID);
      float V1x = ANode.x;
      float V1y = ANode.y;
      float V2x = ANode.edge_x(ed.ANodeRID);
      float V2y = ANode.edge_y(ed.ANodeRID);
      float V3x = BNode.edge_x(ed.BNodeRID);
      float V3y = BNode.edge_y(ed.BNodeRID);
      float V4x = BNode.x;
      float V4y = BNode.y;
      for (float step=0.0; step<=1.0; step+=0.05) {    
        float xx = coordinate_bezier(V1x, V2x, V3x, V4x, step);
        float yy = coordinate_bezier(V1y, V2y, V3y, V4y, step);
        if (e==0 && step==0.0) {
          l=r=xx;
          t=b=yy;
        } else {
          if (xx<l) l=xx;
          if (r<xx) r=xx;
          if (yy<t) t=yy;
          if (b<yy) b=yy;
        }
      }
    }
    disp.left=l;
    disp.right=r;
    disp.top=t;
    disp.bottom=b;
    disp.set_rate();
  }



  float coordinate_bezier(float a, float c, float e, float g, float t) {
    float x1 = naibun(a, c, t);
    float x2 = naibun(c, e, t);
    float x3 = naibun(e, g, t);
    float x4 = naibun(x1, x2, t);
    float x5 = naibun(x2, x3, t);
    return naibun(x4, x5, t);
  }

  float angle(float ax, float ay, float bx, float by, float cx, float cy) {
    float ang1 = (atan2(ay-by, ax-bx));
    float ang2 = (atan2(by-cy, bx-cx));
    float ret = ang2-ang1;
    if (ret < 0.0) {
      ret = -ret;
    }
    if (ret > PI) {
      ret = (2*PI - ret);
    }
    return ret;
  }
  float naibun(float p, float q, float t) {
    return (p*(1.0-t)+q*t);
  }

  //deからnodesとedgesをつくる（５）
  void get_data_nodes_edges() {
    // nodesのデータを作る
    get_nodes();
    //edgesのデータを作る。
    get_edges(edges);
    //  形を整える。
    modify();
    // 形を整えた後に、pointsのデータを更新する
    update_points();
    add_close_point_Joint();
  }

  // nodesのデータを作る
  void get_nodes() {
    for (int p = 0; p < de.points.size(); p++) {
      Bead pt = de.points.get(p);
      if (pt.Joint || pt.midJoint) {// ここではtable[]を使っていないが・・・
        Node nd = new Node(pt.x, pt.y);
        nd.theta = pt.getTheta(de.points);
        nd.pointID = p; // これがtableのかわり。
        if (pt.Joint) {
          nd.Joint=true;
        }
        nodes.add(nd);
      }
    }
  }

  //edgesのデータを作る。このとき、edgeに付随するbeadのデータも残しておく。
  void get_edges(ArrayList<Edge> edges) {
    for (int i=0; i<de.points.size(); i++) {
      Bead a=de.points.get(i);
      if (a.Joint||a.midJoint) {
        // Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
        // Bead b=points.get(a.n1);
        // Bead c=a.findNextJoint(points,b);
        int b=findNeighborJointInPoints(i, a.n1);
        int c=findJointInPoints(i, a.n1);
        int j=getNodesFromPoint(c);
        int k=findk(de.points.get(c), b);
        int h=getNodesFromPoint (i);
        //Log.d("0の行先は",""+getNodesFromPoint(c)+","+k);
        if ((j > h) || (j==h && k>0)) {
          edges.add(new Edge(h, 0, j, k));
        }
        //b=points.get(a.n2);
        //c=a.findNextJoint(points,b);
        if (a.Joint) {
          b = findNeighborJointInPoints(i, a.u1);
          c = findJointInPoints(i, a.u1);
          j = getNodesFromPoint(c);
          k = findk(de.points.get(c), b);
          // Log.d("1の行先は",""+getNodesFromPoint(c)+","+k);
        if ((j > h) || (j==h && k>1)) {
            edges.add(new Edge(h, 1, j, k));
          }
        }
        b=findNeighborJointInPoints(i, a.n2);
        c=findJointInPoints(i, a.n2);
        j=getNodesFromPoint(c);
        k=findk(de.points.get(c), b);
        //Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
        if ((j > h) || (j==h && k>2)) {
          edges.add(new Edge(h, 2, j, k));
        }
        if (a.Joint) {
          //b=points.get(a.u1);
          //c=a.findNextJoint(points,b);
          //b=points.get(a.u2);
          //c=a.findNextJoint(points,b);
          b = findNeighborJointInPoints(i, a.u2);
          c = findJointInPoints(i, a.u2);
          j = getNodesFromPoint(c);
          k = findk(de.points.get(c), b);
          //Log.d("3の行先は",""+getNodesFromPoint(c)+","+k);
          if (j > h) {
            edges.add(new Edge(h, 3, j, k));
          }
        }
      }
    }
  }

  // nodesとedgesを描画する。
  void draw_nodes_edges() {
    //nodesが空なら直ちにreturnする
    if (nodes == null || edges == null) return ;
    for (Edge e : edges) {
      Node a0=nodes.get(e.ANodeID);
      Node a1=nodes.get(e.BNodeID);
      // float hx=(a0.x-disp.left)*disp.rate;
      float hx=disp.get_winX(a0.x);
      float hy=disp.get_winY(a0.y);
      if (e.ANodeRID==1 ||e.ANodeRID==3) {
        hx = disp.get_winX(a0.edge_rx(e.ANodeRID, 30/disp.rate));
        hy = disp.get_winY(a0.edge_ry(e.ANodeRID, 30/disp.rate));
      }
      float ix=disp.get_winX(a0.edge_x(e.ANodeRID));
      float iy=disp.get_winY(a0.edge_y(e.ANodeRID));
      float jx=disp.get_winX(a1.x);
      float jy=disp.get_winY(a1.y);
      if (e.BNodeRID==1 || e.BNodeRID==3) {
        jx = disp.get_winX(a1.edge_rx(e.BNodeRID, 30/disp.rate));
        jy = disp.get_winY(a1.edge_ry(e.BNodeRID, 30/disp.rate));
      }
      float kx=disp.get_winX(a1.edge_x(e.BNodeRID));
      float ky=disp.get_winY(a1.edge_y(e.BNodeRID));

      stroke( 0, 0, 0);
      strokeWeight(5);
      noFill();
      bezier(hx, hy, ix, iy, kx, ky, jx, jy);
    }
    for (Node n : nodes) {
      if (n.Joint) {
        fill(255, 255, 0);
      } else {
        fill(255, 0, 255);
      }
      stroke(0);
      strokeWeight(1);
      ellipse(disp.get_winX(n.x), disp.get_winY(n.y), n.radius, n.radius);
    }
  }

  void update_points()
  {
    for (int e=0; e<edges.size(); e++) {
      Edge ed = edges.get(e);
      float arclength = ed.get_real_arclength(nodes);
      int beads_number = int(arclength / beads_interval) - 2;
      // edgeの上にある現在のビーズの個数を数える。
      int beads_count = 0;
      Node NodeA = nodes.get(ed.ANodeID);
      Node NodeB = nodes.get(ed.BNodeID);
      int bead1 = NodeA.pointID;
      int bead2 = de.points.get(bead1).get_un12(ed.ANodeRID);// ANodeRIDに応じたビーズの番号
      int bead3 = -1;
      if(bead2 == NodeB.pointID){
        beads_count=0;// この行は不要だがつけておく。
      } else {
        do {
          int b = de.points.get(bead2).n1;
          if (b == bead1) {
            bead3 = de.points.get(bead2).n2;
          } else {
            bead3 = b;
          }
          bead1 = bead2;
          bead2 = bead3;
          beads_count ++;
        } while (bead3 != NodeB.pointID);
      }
      //println("必要数,現状数",beads_number, beads_count);
      if (beads_number > beads_count) {// 必要数のほうが多い→ビーズの追加が必要
        bead1 = NodeA.pointID;
        bead2 = de.points.get(bead1).get_un12(ed.ANodeRID);// ANodeRIDに応じたビーズの番号;
        for (int repeat=0; repeat < beads_number - beads_count; repeat++) {
          Bead newBd = new Bead(0, 0);
          newBd.n1 = bead1;
          newBd.n2 = bead2;
          newBd.c = 2;
          de.points.add(newBd);
          int newBdID= de.points.size()-1;
          de.points.get(bead1).set_un12(ed.ANodeRID, newBdID);
          if (de.points.get(bead2).n1 == bead1) de.points.get(bead2).n1 = newBdID;
          else de.points.get(bead2).n2 = newBdID;
          bead2 = newBdID;
        }
      } else if (beads_number < beads_count) {//現在数のほうが多い→ビーズの削除が必要
        bead1 = NodeA.pointID;
        for (int repeat=0; repeat < beads_count - beads_number; repeat++) {
          bead2 = de.points.get(bead1).get_un12(ed.ANodeRID);
          if (de.points.get(bead2).n1==bead1)
            bead3 = de.points.get(bead2).n2;
          else if (de.points.get(bead2).n2==bead1)
            bead3 = de.points.get(bead2).n1;
          else {
            println("error");
            break;
          }
          de.points.get(bead1).set_un12(ed.ANodeRID, bead3);
          if (de.points.get(bead3).n1 == bead2)
            de.points.get(bead3).n1 = bead1;
          else if (de.points.get(bead3).n2 == bead2) 
            de.points.get(bead3).n2 = bead1;
          de.points.get(bead2).n1 = de.points.get(bead2).n2 = -1;// 使わないもののデータを消す。
          de.points.get(bead2).x = de.points.get(bead2).y = 100;//ダミーデータ-> 不要
        }
      }
      //今一度、エッジに乗っているビーズの座標を計算しなおす。
      ed = edges.get(e);
      Node ANode=nodes.get(ed.ANodeID);
      Node BNode=nodes.get(ed.BNodeID);
      float V1x = ANode.x;
      float V1y = ANode.y;
      float V2x = ANode.edge_x(ed.ANodeRID);
      float V2y = ANode.edge_y(ed.ANodeRID);
      float V3x = BNode.edge_x(ed.BNodeRID);
      float V3y = BNode.edge_y(ed.BNodeRID);
      float V4x = BNode.x;
      float V4y = BNode.y;
      bead1 = nodes.get(ed.ANodeID).pointID;
      bead2 = de.points.get(bead1).get_un12(ed.ANodeRID);
      float step = arclength / (beads_number+1);
      int bd=0;
      float arclen=0f;
      float xx0 = V1x;
      float yy0 = V1y;
      float xx, yy;
      for (float repeat=0.01f; repeat<=1.0f; repeat += 0.01f) {
        xx = coordinate_bezier(V1x, V2x, V3x, V4x, repeat);
        yy = coordinate_bezier(V1y, V2y, V3y, V4y, repeat);
        arclen += dist(xx0, yy0, xx, yy);
        //println("update_points():",arclen,step);
        if (arclen >= step * (bd+1)) {
          de.points.get(bead2).x = xx; 
          de.points.get(bead2).y = yy;
          // println("update_points():",bead2,xx,yy);
          bd ++;
          int b = de.points.get(bead2).n1;
          if (b == bead1) {
            bead3 = de.points.get(bead2).n2;
          } else {
            bead3 = b;
          }
          bead1 = bead2;
          bead2 = bead3;
          if (bead2 == BNode.pointID)
            break;
        }
        xx0 = xx;
        yy0 = yy;
      }
    }
  }

  int is_PVector_on_Joint(float vecX, float vecY) {
    for (int nd=0; nd<nodes.size(); nd++) {
      int ndID = nodes.get(nd).pointID;
      Bead bd = de.points.get(ndID);
      if (dist(disp.get_winX(bd.x), disp.get_winY(bd.y), vecX, vecY)<10) {
        return nd;
      }
    }
    return -1;
  }

  int is_PVector_on_points(float vecX, float vecY) {
    for (int ptID=0; ptID<de.points.size(); ptID++) {
      Bead bd = de.points.get(ptID);
      if (dist(disp.get_winX(bd.x), disp.get_winY(bd.y), vecX, vecY)<10) {
        return ptID;
      }
    }
    return -1;
  }


  // クロスチェンジ
  void crosschange(int nodeID) {
    Node node = nodes.get(nodeID);// nodeIDが適正であるかどうかをチェックせよ。
    int pt = node.pointID;
    Bead bd = de.points.get(pt);
    int tmp = bd.n1;
    bd.n1 = bd.u2;
    bd.u2 = bd.n2;
    bd.n2 = bd.u1;
    bd.u1 = tmp;
    float tmpf = node.r[0];
    node.r[0] = node.r[3];
    node.r[3] = node.r[2];
    node.r[2] = node.r[1];
    node.r[1] = tmpf;
    node.theta -= (PI/2);
    for (int edgeID = 0; edgeID<edges.size(); edgeID++) {
      Edge ed = edges.get(edgeID);
      if (ed.ANodeID == nodeID) {
        ed.ANodeRID = (ed.ANodeRID+1)%4;
      } else 
      if (ed.BNodeID == nodeID) {
        ed.BNodeRID = (ed.BNodeRID+1)%4;
      }
    }
  }

  int next_to_node(int ptID) {
    int pt1ID = de.points.get(ptID).n1;
    Bead bd1 = de.points.get(pt1ID);
    if (bd1.Joint || bd1.midJoint) {
      for (int ndID=0; ndID < nodes.size(); ndID++) {
        if (nodes.get(ndID).pointID == pt1ID) { 
          return ndID;
        }
      }
    }
    int pt2ID = de.points.get(ptID).n2;
    Bead bd2 = de.points.get(pt2ID);
    if (bd2.Joint || bd2.midJoint) {
      for (int ndID=0; ndID < nodes.size(); ndID++) {
        if (nodes.get(ndID).pointID == pt2ID) { 
          return ndID;
        }
      }
    }
    return -1;
  }
}