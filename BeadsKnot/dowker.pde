class dowker { //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  //    未整備
  
  //このような感じでドウカーコードを準備しておく．
  //int dowker[]={6, 10, 12, 2, 4, 8};
  //int dowker[]={4,8,14,16,2,18,20,22,10,12,6};
  //int dowker[]={4, 10, -12, 14, 22, 2, 18, 20, 8, 6, 16};
  //int dowker[]={6, 8, 16, 14, 4, 18, 20, 2, 22, 12, 10};
  //int dowker[] = {6, 10, 16, 18, 14, 2, 20, 4, 22, 12, 8};
  //int dowker[] = {6, 12, 16, 18, 14, 4, 20, 22, 2, 8, 10};
  //int dowker[] = {40, 24, 10, 30, 22, 52, 32, 64, 46, 12, 6 ,42, 60, 2, 8, 50, 66, 16, 62, 58, 28, 4, 54, 34, 14, 20, 68, 36, 72, 26, 70, 56, 48, 18, 44, 38};

  data_graph dg;
  
  int dowker[];
  int dowkerCount;
  ArrayList<DNode> nodes;
  ArrayList<DEdge> edges;
  int outer[];
  int outerCount=0;

  dowker(data_graph _dg){
    dg = _dg;
    dowker = new int[100];
    dowkerCount=0;
  }

  void Start() {
    nodes = new ArrayList<DNode>();
    edges = new ArrayList<DEdge>();
    int len = dowkerCount;
    for (int i=0; i<len; i++) {
      nodes.add(new DNode(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len), 2*i+1, abs(dowker[i]), i, 0, (dowker[i]>0)));// center
      nodes.add(new DNode(400+200*cos(PI*2*i/len)+30, 400-200*sin(PI*2*i/len), 2*i+1, abs(dowker[i]), i, 1, (dowker[i]>0)));// right
      nodes.add(new DNode(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len)-30, 2*i+1, abs(dowker[i]), i, 2, (dowker[i]>0)));// top
      nodes.add(new DNode(400+200*cos(PI*2*i/len)-30, 400-200*sin(PI*2*i/len), 2*i+1, abs(dowker[i]), i, 3, (dowker[i]>0)));// left
      nodes.add(new DNode(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len)+30, 2*i+1, abs(dowker[i]), i, 4, (dowker[i]>0)));// bottom
      edges.add(new DEdge(5*i, 5*i+1, true)); 
      edges.add(new DEdge(5*i, 5*i+2, true)); 
      edges.add(new DEdge(5*i, 5*i+3, true)); 
      edges.add(new DEdge(5*i, 5*i+4, true)); 
      edges.add(new DEdge(5*i+1, 5*i+2, false)); 
      edges.add(new DEdge(5*i+2, 5*i+3, false)); 
      edges.add(new DEdge(5*i+3, 5*i+4, false)); 
      edges.add(new DEdge(5*i+4, 5*i+1, false));
    }
    // a,b は１始まり
    for (int i=0; i<len; i++) {
      for (int j=i+1; j<len; j++) {
        DNode n1 = nodes.get(5*i);
        DNode n2 = nodes.get(5*j);
        if (n2.b == n1.a-1 || n2.b == n1.a+2*len-1) {
          edges.add(new DEdge(5*i+1, 5*j+4, true));
        } else if (n2.b == n1.a+1 ) {
          edges.add(new DEdge(5*i+3, 5*j+2, true));
        }
        if (n1.b == n2.a-1 || n1.b == n2.a+2*len-1) {
          edges.add(new DEdge(5*i+4, 5*j+1, true));
        } else if (n1.b == n2.a+1 ) {
          edges.add(new DEdge(5*i+2, 5*j+3, true));
        }
      }
    }
    outer= new int[20];
    //一度，三角形の外周で計算する．
    findTriangle();
    modify();
    // 改めて外周を探しなおす．
    findOuter();
    modify();
    //この点データでdata_graphを構成する．
    outputData(); //<>// //<>// //<>// //<>//
  }

  class DNode {
    int a, b;
    float x, y;
    int nodeID;//奇数
    int branchID;// 1: 奇数-1, 2:偶数-1, 3:奇数+1, 4:偶数+1
    boolean ou;// true: 奇数が上， false: 偶数が上
    DNode(float _x, float _y, int _i, int _j, int _nID, int _bID, boolean _ou) {
      x=_x;
      y=_y;
      a=_i;
      b=_j;
      nodeID = _nID;
      branchID = _bID;
      ou = _ou;
    }
  }

  DNode getDNode( int _nID, int _bID) {
    return nodes.get(_nID*5 + _bID);
  }

  class DEdge {
    int s, t;
    boolean visible;
    DEdge(int _s, int _t, boolean _v) {
      s=_s;
      t=_t;
      visible = _v;
    }
  }

  void findTriangle() {
    int nSize = nodes.size();
    outer= new int[nSize];
    for (int a=0; a<nSize; a++) {
      outer[a] = -1;
    }
    int forSize = nSize/5;
    for (int a=0; a<forSize; a++) {
      for (int b=a+1; b<forSize; b++) {
        for (int c=b+1; c<forSize; c++) {
          int eAB_a = -1, eAB_b = -1;
          int eBC_b = -1, eBC_c = -1;
          int eCA_c = -1, eCA_a = -1;
          for (int e=0; e<edges.size(); e++) {
            DEdge ee = edges.get(e);
            int s = int(ee.s / 5);
            int t = int(ee.t / 5);
            if (s == a && t == b ) {
              eAB_a = ee.s;
              eAB_b = ee.t;
            } else if (s == b && t == a ) {
              eAB_b = ee.s;
              eAB_a = ee.t;
            } else if (s == b && t == c ) {
              eBC_b = ee.s; 
              eBC_c = ee.t;
            } else if (s == c && t == b ) {
              eBC_c = ee.s; 
              eBC_b = ee.t;
            } else if (s == c && t == a ) {
              eCA_c = ee.s; 
              eCA_a = ee.t;
            } else if (s == a && t == c ) {
              eCA_a = ee.s; 
              eCA_c = ee.t;
            }
          }
          if (eAB_a!=-1 && eBC_b!=-1 && eCA_c!=-1) {
            println("三角形見つけた！");
            println(eAB_a, eAB_b, eBC_b, eBC_c, eCA_c, eCA_a);
            outer[0]=eCA_a;
            outer[1]=eAB_a;
            outer[2]=eAB_b;
            outer[3]=eBC_b;
            outer[4]=eBC_c;
            outer[5]=eCA_c;
            outerCount=6;
            return ;
          }
        }
      }
    }
  }

  int findNext(int p, int q) {
    if (q%5 ==0) {
      float xp=nodes.get(p).x - nodes.get(q).x;
      float yp=nodes.get(p).y - nodes.get(q).y;
      int p1 = p+1;
      if (p1-q>=5) {
        p1 -= 4;
      }
      float xp1=nodes.get(p1).x - nodes.get(q).x;
      float yp1=nodes.get(p1).y - nodes.get(q).y;
      int p3 = p+3;
      if (p3-q>=5) {
        p3 -= 4;
      }
      float xp3=nodes.get(p3).x - nodes.get(q).x;
      float yp3=nodes.get(p3).y - nodes.get(q).y;
      float ax = xp1 - xp;
      float ay = yp1 - yp;
      float bx = xp3 - xp;
      float by = yp3 - yp;
      float orientation = ax*by - ay*bx;
      if (orientation>0) {
        return p3;
      } else {
        return p1;
      }
    } else {
      for (int e=0; e<edges.size(); e++) {
        DEdge ee = edges.get(e);
        if (ee.visible) {
          if (ee.s==q && ee.t!=p) {
            return ee.t;
          }
          if (ee.t==q && ee.s!=p) {
            return ee.s;
          }
        }
      }
    }
    return -1;
  }

  void findOuter() {
    int outer_sub[] = new int[nodes.size()];
    int outer_sub_count=0;
    for (int pp=0; pp<nodes.size(); pp+=5) {
      for (int qq=pp+1; qq<pp+5; qq++) {
        int p=pp;
        int q=qq;
        outer_sub_count=0;
        outer_sub[outer_sub_count] = q;
        outer_sub_count++;
        for (int repeat=0; repeat<nodes.size(); repeat++) {
          int r=findNext(p, q);
          if (r==pp) {
            break;
          } else {
            p=q;
            q=r;
            if (q%5 != 0) {
              outer_sub[outer_sub_count] = q;
              outer_sub_count++;
            }
          }
        }
        if (outer_sub_count>outerCount) {//  マックスの場合がいいとは限らない．
          for (int k=0; k<outer_sub_count; k++) {
            outer[k] = outer_sub[k];
            print(outer_sub[k]+" ");
          }
          outerCount = outer_sub_count;
          println("("+outer_sub_count+")");
        }
      }
    }
    return ;
  }

  void modify() {
    int len = nodes.size();
    //外周は固定する
    for (int a=0; a<outerCount; a++) {
      nodes.get(outer[a]).x = 400 + 300*cos(PI*2*a/outerCount);
      nodes.get(outer[a]).y = 400 - 300*sin(PI*2*a/outerCount);
    }
    float dx[] = new float [len];
    float dy[] = new float [len];
    for (int repeat=0; repeat<2000; repeat++) {
      for (int n=0; n<len; n++) {
        dx[n] = dy[n] = 0f;
      }
      for (int n=0; n<len; n++) {
        DNode nn = nodes.get(n);
        float zx=0;
        float zy=0;
        int count=0;
        for (int e=0; e<edges.size(); e++) {
          DEdge ee = edges.get(e);
          if (ee.s == n) {
            zx += nodes.get(ee.t).x;
            zy += nodes.get(ee.t).y;
            count++;
          } else if (ee.t == n) {
            zx += nodes.get(ee.s).x;
            zy += nodes.get(ee.s).y;
            count++;
          }
        }
        zx /= count;
        zy /= count;
        float ax = zx - nn.x;
        float ay = zy - nn.y;
        ax *= 0.1;
        ay *= 0.1;
        dx[n] = ax;
        dy[n] = ay;
      }
      for (int n=0; n<len; n++) {
        boolean OK=true;
        for (int a=0; a<outerCount; a++) {
          if (n==outer[a]) {
            OK=false;
            break;
          }
        }
        if (OK) {
          DNode nn = nodes.get(n);
          nn.x += dx[n];
          nn.y += dy[n];
        }
      }
    }
  }


  void outputData() {
    int nodeNumber=0; //<>// //<>// //<>// //<>//
    nodeNumber = nodes.size();
    dg.nodes.clear();
    dg.de.clearAllPoints();
    for (int n=0; n<nodeNumber; n++) {
      DNode nn = nodes.get(n);
      Node nd = new Node(nn.x, nn.y);
      if (n%5 == 0) {
        if (nn.ou) {
          nd.theta = -atan2(nodes.get(n+1).y-nodes.get(n).y, nodes.get(n+1).x-nodes.get(n).x);
        } else {
          nd.theta = -atan2(nodes.get(n+2).y-nodes.get(n).y, nodes.get(n+1).x-nodes.get(n).x);
        }
      } else {
        int n0 = (int(n/5)*5);
        nd.theta = -atan2(nodes.get(n0).y-nodes.get(n).y, nodes.get(n0).x-nodes.get(n).x);
      }
      nd.r[0] = nd.r[1] = nd.r[2] = nd.r[3] = 10.0f;
      nd.pointID = n;
      nd.Joint=false;
      dg.nodes.add(nd);
      int bdID = dg.de.addBeadToPoint(nn.x, nn.y);
      Bead bd = data.getBead(bdID); 
      bd.c = 2;
      bd.n1 = bd.n2 = -1;
      bd.u1 = bd.u2 = -1;
      bd.Joint = bd.midJoint = false;
    } 
    // edges
    int edgeNumber=0;
    for (int e=0; e<edges.size(); e++) {
      DEdge ee = edges.get(e);
      if (ee.visible) {
        edgeNumber ++;
      }
    }
    dg.edges.clear();
    int A=-1, AR=-1, B=-1, BR=-1;
    int eCount=0;
    for (int e=0; e<edges.size(); e++) {
      DEdge ee = edges.get(e);
      if (ee.visible) {
        if (ee.s%5==0) {
          int s0 = ee.s; 
          float aX = nodes.get(s0+2).x - nodes.get(s0+1).x;
          float aY = nodes.get(s0+2).y - nodes.get(s0+1).y;
          float bX = nodes.get(s0+4).x - nodes.get(s0+1).x;
          float bY = nodes.get(s0+4).y - nodes.get(s0+1).y;
          float orientation = aX*bY - aY*bX;
          int t=ee.t-ee.s;
          A = ee.s;
          if (orientation<0) {
            if (nodes.get(ee.s).ou) {
              t = (t+7)%4;
            } else {
              t = (t+6)%4;
            }
          } else {
            if (nodes.get(ee.s).ou) {
              t = (5-t)%4;
            } else {
              t = (6-t)%4;
            }
          }
          AR = t;
          B = ee.t;
          BR = 0;
        } else {
          A = ee.s;
          AR = 2;
          B = ee.t;
          BR = 2;
        }
        Edge ed = new Edge(A,AR,B,BR);
        dg.edges.add(ed);
        
        int bdID = dg.de.addBeadToPoint(0f, 0f);
        Bead bd = dg.de.getBead(bdID);
        bd.n1 = ed.ANodeID;
        bd.n2 = ed.BNodeID;
        bd.c = 2;
        Bead bdA = dg.de.getBead(ed.ANodeID);
        if (bdA!=null) {
          bdA.set_un12(ed.ANodeRID, nodeNumber+eCount);
        }
        Bead bdB = dg.de.getBead(ed.BNodeID);
        if (bdB!=null) {
          bdB.set_un12(ed.BNodeRID, nodeNumber+eCount);
        }
        eCount++;
      }
    }
    for (int n=0; n<nodeNumber; n++) { //<>// //<>// //<>// //<>//
      Bead bd = dg.de.getBead(n);
      if (bd.n1==-1 && bd.n2==-1) {
        data.removeBeadFromPoint(n);// これはない
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
    dg.modify(); //<>// //<>// //<>// //<>//
    dg.update_points();
    dg.add_close_point_Joint();
    Draw.beads();// drawモードの変更
  }
}
    
//参考文献
//https://www2.cs.arizona.edu/~kpavlou/Tutte_Embedding.pdf
//これはかなりわかりやすい！！