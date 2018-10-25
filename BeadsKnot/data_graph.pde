class data_graph {
//データのグラフ構造
//nodeとedgeからなる

  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  data_extract de; 
  int[] table;
  display disp;
  boolean data_graph_complete=false;

  data_graph(data_extract _de) {
    nodes = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
    de = _de;
    disp = de.disp;
  }

  void make_data_graph() {//nodesやedgesを決める
    JointOrientation();
    add_half_point_Joint();
    add_close_point_Joint();
    getNodes();
    testFindNextJoint();
    set_nodes_edges();  
    println("data_graph_completeしました");    
    data_graph_complete=true;
    de.extraction_binalized = false;
    de.extraction_complete = false;
    de.extraction_beads = false;
  }
  void JointOrientation() {
    for (int i=0; i<de.points.size (); i++) {
      Bead vec=de.points.get(i);
      if (vec.Joint) {
        if (vec.u1<0||vec.u1>=de.points.size()||vec.u2<0||vec.u2>=de.points.size()) {
          return;
        }
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
  void add_half_point_Joint() {
    for (int i = 0; i < de.points.size(); i++) {
      Bead a = de.points.get(i);
      if (a.Joint) {
        int c=findtrueJointInPoints(i, a.n1);
        if (i<c) {
          int count = countNeighborJointInPoints(i, a.n1, 0);
          int half = get_half_position(i, a.n1, count / 2);
          de.points.get(half).midJoint=true;
        }
        c=findtrueJointInPoints(i, a.u1);
        if (i<c) {
          int count = countNeighborJointInPoints(i, a.u1, 0);
          int half = get_half_position(i, a.u1, count / 2);
          de.points.get(half).midJoint=true;
        }
        c=findtrueJointInPoints(i, a.n2);
        if (i<c) {
          int count = countNeighborJointInPoints(i, a.n2, 0);
          int half = get_half_position(i, a.n2, count / 2);
          de.points.get(half).midJoint=true;
        }
        c=findtrueJointInPoints(i, a.u2);
        if (i<c) {
          int count = countNeighborJointInPoints(i, a.u2, 0);
          int half = get_half_position(i, a.u2, count / 2);
          de.points.get(half).midJoint=true;
        }
      }
    }
  }

  void add_close_point_Joint() {//Ten Percent Neighborhood point
    for (int p_i = 0; p_i < de.points.size(); p_i++) {
      Bead b_a = de.points.get(p_i);
      if (b_a.Joint) {
        //int p_c=findtrueJointInPoints(p_i, b_a.n1);
        int count = countNeighborJointInPoints(p_i, b_a.n1, 0);
        int p_close = get_half_position(p_i, b_a.n1, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        //p_c=findtrueJointInPoints(p_i, b_a.u1);
        count = countNeighborJointInPoints(p_i, b_a.u1, 0);
        p_close = get_half_position(p_i, b_a.u1, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        //p_c=findtrueJointInPoints(p_i, b_a.n2);
        count = countNeighborJointInPoints(p_i, b_a.n2, 0);
        p_close = get_half_position(p_i, b_a.n2, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
        //p_c=findtrueJointInPoints(p_i, b_a.u2);
        count = countNeighborJointInPoints(p_i, b_a.u2, 0);
        p_close = get_half_position(p_i, b_a.u2, ceil(count*0.1));
        de.points.get(p_close).closeJoint=true;
      }
    }
  }

  int findtrueJointInPoints(int j, int c) {
    // for (int i = 0; i < de.points.size(); i++) {
    Bead p=de.points.get(c);
    if (p.Joint) {
      return c;
    }
    int d=0;
    if (p.n1==j) {
      d=p.n2;
    } else if (p.n2==j) {
      d=p.n1;
    } else {
      //println("間違っている");
    }
    return findtrueJointInPoints(c, d);
  }

  int findNeighborJointInPoints(int j, int c) {
    // for (int i = 0; i < de.points.size(); i++) {
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
      //println("間違っている");
    }
    return findNeighborJointInPoints(c, d);
  }

  private int countNeighborJointInPoints(int 
    j, int c, int count) {
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
      // Log.d("間違っている","");
    }
    return countNeighborJointInPoints(c, d, count+1);
  }
  int get_half_position(int j, int c, int count) {
    if (count==0) {
      return c;
    }
    Bead p=de.points.get(c);
    if (p.Joint) {
      //Log.d("エラー","");
    }
    int d=0;
    if (p.n1==j) {
      d=p.n2;
    } else if (p.n2==j) {
      d=p.n1;
    } else {
      // Log.d("間違っている","");
    }
    return get_half_position(c, d, count-1);
  }
  void getNodes() {
    int count=0;
    for (int i = 0; i < de.points.size(); i++) {
      Bead vec = de.points.get(i);
      if (vec.Joint||vec.midJoint) {
        count++;
      }
    }
    //        Log.d("countの数",""+count);
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
  private void testFindNextJoint() {//デバック
    for (int i=0; i<de.points.size(); i++) {
      Bead a=de.points.get(i);
      if (a.Joint||a.midJoint) {
        //Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
        // Bead b=points.get(a.n1);
        // Bead c=a.findNextJoint(points,b);
        int j=findNeighborJointInPoints(i, a.n1);
        int c=findJointInPoints(i, a.n1);
        int k=findk(de.points.get(c), j);
        //Log.d("0の行先は",""+getNodesFromPoint(c)+","+k);
        //b=points.get(a.n2);
        //c=a.findNextJoint(points,b);
        if (a.Joint) {
          j = findNeighborJointInPoints(i, a.u1);
          c = findJointInPoints(i, a.u1);
          k = findk(de.points.get(c), j);
          //Log.d("1の行先は", "" + getNodesFromPoint(c) + "," + k);
        }
        j=findNeighborJointInPoints(i, a.n2);
        c=findJointInPoints(i, a.n2);
        k=findk(de.points.get(c), j);
        //Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
        //b=points.get(a.u1);
        //c=a.findNextJoint(points,b);

        //b=points.get(a.u2);
        //c=a.findNextJoint(points,b);
        if (a.Joint) {
          j = findNeighborJointInPoints(i, a.u2);
          c = findJointInPoints(i, a.u2);
          k = findk(de.points.get(c), j);
          // Log.d("3の行先は", "" + getNodesFromPoint(c) + "," + k);
        }
      }
    }
  }
  int findJointInPoints(int j, int c) {
    // for (int i = 0; i < points.size(); i++) {
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
      //Log.d("間違っている","");
    }
    return findJointInPoints(c, d);
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

  void getEdges(ArrayList<Edge> edges) {
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
        if (j>h) {
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
          if (j > h) {
            edges.add(new Edge(h, 1, j, k));
          }
        }
        b=findNeighborJointInPoints(i, a.n2);
        c=findJointInPoints(i, a.n2);
        j=getNodesFromPoint(c);
        k=findk(de.points.get(c), b);
        //Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
        if (j>h) {
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
  void modifyArmsOfAlignments(Edge e) {
    Node n1 = nodes.get(e.getH());
    Node n2 = nodes.get(e.getJ());
    int a1 = e.getI();
    int a2 = e.getK();
    float r1;
    float r2;
    int count = 0;
    boolean loopGoOn;
    do {
      loopGoOn = false;
      float d1 = hypot(n1.getX() - n1.edge_x(a1), n1.getY() - n1.edge_y(a1));
      float d2 = hypot(n1.edge_x(a1) - n2.edge_x(a2), n1.edge_y(a1) - n2.edge_y(a2));
      float d3 = hypot(n2.getX() - n2.edge_x(a2), n2.getY() - n2.edge_y(a2));
      r1 = n1.getR(a1);
      if (d1 + 3.0 < d2) {
        n1.setR(a1, r1+3.0);
        loopGoOn = true;
      } else if (d1 - 3.0 > d2) {
        n1.setR(a1, r1-3.0);
        loopGoOn = true;
      }
      r2 = n2.getR(a2);
      if (d3 + 3.0 < d2) {
        n2.setR(a2, r2+3.0);
        loopGoOn = true;
      } else if (d3 - 3.0 > d2) {
        n2.setR(a2, r2-3.0);
        loopGoOn = true;
      }
    } while (loopGoOn && count++<50);
  }

  void modify() {
    //Nodeの座標も微調整したい。
    for (Edge i : edges) {
      i. scaling_shape_modifier(nodes);
    }
    rotation_shape_modifier(nodes, edges);
  }

  void rotation_shape_modifier(ArrayList<Node> nodes, ArrayList<Edge> edges) {//円を自動で回転させる
    float e0, e0p, e0m, e0r;
    for (int h = 0; h < nodes.size (); h ++) {
      /* Node node=nodes.get(h); */
      e0 = e0p = e0m = e0r = 0;
      for (int i = 0; i < 4; i ++) {
        // int i2=node.edges[j];
        int e1=-1, e2=-1, i1=-1, i2=-1;
        for (Edge e : edges) {
          if (h==e.h&&i==e.i) {
            i1=h;
            i2=e.j;
            e1=i;
            e2=e.k;
            break;
          } else if (h==e.j&&i==e.k) {
            i1=h;
            i2=e.h;
            e1=i;
            e2=e.i;
            break;
          }
        }
        if (i1!=-1&&i2!=-1&&e1!=-1&&e2!=-1) {
          Node a1 = nodes.get(i1);
          Node a2 = nodes.get(i2);
          float r1=a1.r[e1];
          float r2=a2.r[e2];
          float angle1 = (a1.theta+PI*e1/2);
          float angle2 = (a2.theta+PI*e2/2);
          float x1=a1.x;
          float y1=a1.y;
          float x4=a2.x;
          float y4=a2.y;
          float x2=(x1+r1*cos(angle1));
          float y2=(y1-r1*sin(angle1));
          float x2p=(x1+r1*cos(angle1+0.05));
          float y2p=(y1-r1*sin(angle1+0.05));
          float x2m=(x1+r1*cos(angle1-0.05));
          float y2m=(y1-r1*sin(angle1-0.05));
          float x2r=(x1+10*cos(angle1+PI));
          float y2r=(y1-10*sin(angle1+PI));
          float x3=(x4+r2*cos(angle2));
          float y3=(y4-r2*sin(angle2));
          float e11=get_rangewidth_angle(x1, y1, x2, y2, x3, y3, x4, y4);
          float e11p=get_rangewidth_angle(x1, y1, x2p, y2p, x3, y3, x4, y4);
          float e11m=get_rangewidth_angle(x1, y1, x2m, y2m, x3, y3, x4, y4);
          float e11r=get_rangewidth_angle(x1, y1, x2r, y2r, x3, y3, x4, y4);
          e0 += e11;
          e0p += e11p;
          e0m += e11m;
          e0r += e11r;
        }
      }
      /*if (e0r < e0) {
       nodes.get(h).theta += PI;
       } else */
      if (e0>e0p && e0m>e0) {
        nodes.get(h).theta +=0.05;
      } else if (e0>e0m && e0p>e0) {
        nodes.get(h).theta -=0.05;
      } /*else {
       Log.d("check","do nothing");
       }*/
    }
  }

  float get_rangewidth_angle(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    float ret0 = (PI);
    float ret1 = 0;
    float step=(0.05);// step is 1/20
    float cx = x1;
    float dx = coordinate_bezier(x1, x2, x3, x4, step);
    float cy = y1;
    float dy = coordinate_bezier(y1, y2, y3, y4, step);
    float ex, ey;
    for (float i = step*2; i<=1.0; i += step) {
      ex=coordinate_bezier(x1, x2, x3, x4, i);
      ey=coordinate_bezier(y1, y2, y3, y4, i);
      float ang = angle(cx, cy, dx, dy, ex, ey);
      if (ang < ret0) { // get minimum
        ret0 = ang;
      }
      if (ang > ret1) { // get maximum
        ret1 = ang;
      }
      cx = dx;
      cy = dy;
      dx = ex;
      dy = ey;
    }
    return ret1-ret0;
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


  void set_nodes_edges() {
    // 読み取りデータからAlignmentのデータを取り出す。
    for (int i = 0; i < de.points.size(); i++) {
      Bead vec = de.points.get(i);
      if (vec.Joint||vec.midJoint) {
        Node ali=new Node((float)vec.x, (float)vec.y);
        ali.theta=vec.getTheta(de.points);
        if (vec.Joint) {
          ali.Joint=true;
        }
        nodes.add(ali);
      }
    }
    //Log.d("nodesの長さ",""+nodes.size());
    //　Alignmentのデータからedgeのデータを整える。
    getEdges(edges);
    //  形を整える。
    for (Edge e : edges) {
      modifyArmsOfAlignments(e);
    }
    for (int i=0; i<100; i++) {
      // modify();
    }
  }

  void drawNodes() {
    for (Node n : nodes) {
      if (n.Joint) {
        fill(255, 255, 0);
      } else {
        fill(255, 0, 255);
      }
      /*
        if(n.drawOn) {*/
      noStroke();
      ellipse(disp.get_winX(n.x), disp.get_winY(n.y), n.radius, n.radius);
      //}
    }
    for (Edge e : edges) {
      draw_connect_nodes(e);
    }
  }  
  void draw_connect_nodes(Edge e) {
    // 旧関数名　connect_nodes
    //関数名をdrawEdgeBezierにしたい。
    // スタート地点を移動
    //Log.d("hとjを表示",""+h+"  "+j);
    //float wid = r-l;
    //float hei = b-t;
    //float rate;
    //if(wid>hei){
    //    rate = 1080/wid;
    //} else {
    //    rate = 1080/hei;
    //}
    Node a0=nodes.get(e.h);
    Node a1=nodes.get(e.j);
    // float hx=(a0.x-disp.left)*disp.rate;
    float hx=disp.get_winX(a0.x);
    //float hy=(a0.y-disp.top)*disp.rate;
    float hy=disp.get_winY(a0.y);
    if (e.i==1 ||e.i==3) {
      hx = disp.get_winX(a0.edge_rx(e.i, 30/disp.rate));
      hy = disp.get_winY(a0.edge_ry(e.i, 30/disp.rate));
    }
    //float ix=(a0.edge_x(e.i)-disp.left)*disp.rate;
    float ix=disp.get_winX(a0.edge_x(e.i));
    float iy=disp.get_winY(a0.edge_y(e.i));
    float jx=disp.get_winX(a1.x);
    float jy=disp.get_winY(a1.y);
    if (e.k==1 || e.k==3) {
      jx = disp.get_winX(a1.edge_rx(e.k, 30/disp.rate));
      jy = disp.get_winY(a1.edge_ry(e.k, 30/disp.rate));
    }
    float kx=disp.get_winX(a1.edge_x(e.k));
    float ky=disp.get_winY(a1.edge_y(e.k));

    stroke( 0, 0, 0);
    strokeWeight(5);
    noFill();
    bezier(hx, hy, ix, iy, kx, ky, jx, jy);
  }
  float hypot(float x, float y) {
    return sqrt(x*x+y*y);
  }
}
