class Thinning {      //<>// //<>// //<>// //<>// //<>// //<>//
  data_extract DE;
  int w, h;
  int d_new[][];

  ArrayList<Nbhd> cross;

  Thinning(data_extract _de) {
    DE=_de;
    w=DE.w;
    h=DE.h;
    d_new = new int[w][h];
    cross = new ArrayList<Nbhd>();
  }

  boolean getThinningExtraction() {
    w=DE.w;
    h=DE.h;
    DE.clearAllNbhd();
    DE.clearAllPoints();
    // int de.d[w][h] を仮定してよい。
    get_edge_data_thinning();

    DE.countNbhds();//NbhsからBeadsのn1,n2,u1,u2を決める。

    println("cancel_loop()"); 
    cancel_loop() ;

    println("remove_dust()"); 
    remove_dust();

    println("find_crossing()");
    find_crossing();    
    //DE.debugLogPoints("find_crossing.csv");

    println("画面サイズ調整");
    DE.getDisplayLTRB();
    println("jointに関しての線を追加");
    DE.addJointToNbhds();
    //DE.debugLogPoints("addJointToNbhds.csv");

    println(DE.points.size(), DE.nbhds.size());
    //もし問題なければtrueを返し、問題が残っていれば、parts_editingモードにする。

    if (thinning_finish()) {
      Draw.beads();// drawモードの変更
      println("成功");
      return true;
    } else {
      println("失敗なので、手作業モードへ移ります。");
      edit.points_to_beads(data);
      return false;
    }
  }

  boolean thinning_finish() {//みんなお二人様だったか確認
    for (int ptID = 0; ptID<DE.points.size(); ptID++) {
      Bead pt = DE.getBead(ptID);
      if (pt != null) {
        if (!pt.Joint && pt.c!=2) {
          return false;
        }     //<>// //<>// //<>// //<>//
      }
    }
    return true;
  }


  //////////////////////////////////
  void get_edge_data_thinning() {
    boolean cont=true;
    int contcount=0;
    do {
      cont = do_thinning();//
    } while ( contcount++ <50 && cont);//
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        if (DE.d[x][y]==1) {
          int c=0;
          if (x>0) {
            if (DE.d[x][y-1]==1) {
              c++;
            }
          }
          if (x<w-1) {
            if (DE.d[x][y+1]==1) {
              c++;
            }
          }
          if (y>0) {
            if (DE.d[x-1][y]==1) {
              c++;
            }
          }
          if (y<h-1) {
            if (DE.d[x+1][y]==1) {
              c++;
            }
          }
          if (c>=3 || c==1) {
            int cc = addToPoints(x, y);
            DE.getBead(cc).c = 2;
          }
        }
      }
    }
    // d_new is used in find_next_point_on_thinning_graph.
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        d_new[x][y]=DE.d[x][y];
      }
    }
    // DE.points.size() may increase in this loop
    for (int p=0; p<DE.points.size(); p++) {
      find_next_point_on_thinning_graph(p);
    }
  }

  ////////////////////////////
  boolean do_thinning() {
    boolean cont=false;
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        d_new[x][y]=DE.d[x][y];
      }
    }
    for (int p=0; p<4; p++) {
      for (int x=1; x<w-1; x++) {
        for (int y=1; y<h-1; y++) {
          if (DE.d[x][y]==1) {
            boolean c1=(DE.d[x-1][y-1]==1);
            boolean c2=(DE.d[x][y-1]==1);
            boolean c3=(DE.d[x+1][y-1]==1);
            boolean c4=(DE.d[x+1][y]==1);
            boolean c5=(DE.d[x+1][y+1]==1);
            boolean c6=(DE.d[x][y+1]==1);
            boolean c7=(DE.d[x-1][y+1]==1);
            boolean c8=(DE.d[x-1][y]==1);
            if (p==0) {
              if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
                d_new[x][y]=0;
              }
              if (!c8 && !c1 && !c2 && c4 && c5 && c6) {
                d_new[x][y]=0;
              }
              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
                d_new[x][y]=0;
              }
            }
            if (p==1) {
              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
                d_new[x][y]=0;
              }
              if (!c6 && !c7 && !c8 && c2 && c3 && c4) {
                d_new[x][y]=0;
              }
              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
                d_new[x][y]=0;
              }
            }
            if (p==2) {
              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
                d_new[x][y]=0;
              }
              if (!c4 && !c5 && !c6 && c8 && c1 && c2) {
                d_new[x][y]=0;
              }
              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
                d_new[x][y]=0;
              }
            }
            if (p==3) {
              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
                d_new[x][y]=0;
              }
              if (!c2 && !c3 && !c4 && c6 && c7 && c8) {
                d_new[x][y]=0;
              }
              if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
                d_new[x][y]=0;
              }
            }
          }
        }
      }
      cont=false;
      for (int x=0; x<w; x++) {
        for (int y=0; y<h; y++) {
          if (DE.d[x][y]!=d_new[x][y]) {
            DE.d[x][y]=d_new[x][y];
            cont=true;
          }
        }
      }
    }
    return cont;
  }


  void find_next_point_on_thinning_graph(int p) {
    Bead bd = DE.getBead(p);
    if (bd == null) {
      return ;
    }
    int vx = int(bd.x+0.1);
    int vy = int(bd.y+0.1);
    d_new[vx][vy]=0;
    step_on_thinning_graph(p, vx-1, vy, 0);
    step_on_thinning_graph(p, vx, vy-1, 0);
    step_on_thinning_graph(p, vx+1, vy, 0);
    step_on_thinning_graph(p, vx, vy+1, 0);
  }

  void step_on_thinning_graph(int p, int x, int y, int count) {
    if (x<0 || x>=w) {
      return;
    }
    if (y<0 || y>=h) {
      return;
    }
    if (!is_Beads_id(p)) {
      return ;
    }
    if (d_new[x][y]==0) {
      return ;
    }
    for (int q=0; q<DE.points.size(); q++) {
      Bead bd = DE.getBead(q);
      if (bd != null) {
        if (x==int(bd.x+0.1) && y==int(bd.y+0.1) ) {
          addToNbh_WithoutCheck(p, q);
          return ;
        }
      }
    }
    if (count==10) {
      int q = addToPoints(x, y);
      addToNbh_WithoutCheck(p, q);
      count=0;
      p=q;
      return;
    }
    d_new[x][y]=0;
    step_on_thinning_graph(p, x-1, y, count+1);
    step_on_thinning_graph(p, x, y-1, count+1);
    step_on_thinning_graph(p, x+1, y, count+1);
    step_on_thinning_graph(p, x, y+1, count+1);
  }

  boolean is_Beads_id(int num) {
    return (0 <= num && num < DE.points.size());
  }

  int addToPoints(int _x, int _y) {
    if (_y>=h || _x>=w) {
      return -1;
    }
    if (DE.d[_x][_y]==0) {
      return -1;
    }
    // for (int i=0; i<DE.points.size (); i++) {
    //   if (dist(_x, _y, DE.points.get(i).x, DE.points.get(i).y)<5) {
    //     return i;
    //   }
    // }
    int ret = DE.addBeadToPoint(_x, _y);
    //DE.points.add(new Bead(_x, _y));
    //return DE.points.size()-1;
    return ret;
  }

  boolean addToNbh_WithoutCheck(int i1, int i2) {
    if (!is_Beads_id(i1) || !is_Beads_id(i2)) {
      return false;
    }
    for (int nbID=0; nbID< DE.nbhds.size(); nbID++){
      Nbhd n = DE.getNbhd(nbID);
      if (n!=null){
        if ( n.a==i1 && n.b==i2 ) {
          return  false;
        } else if ( n.a==i2 && n.b==i1 ) {
          return  false;
        }
      }
    }
    if (i1==i2) {
      return  false;
    }
    //float d=abs(points.get(i1).x-points.get(i2).x)+abs(points.get(i1).y-points.get(i2).y);
    DE.nbhds.add(new Nbhd(i1, i2));
    return true;
  }

  ////////////////////////////////////////////
  //
  //      calcel_loop()
  //
  ////////////////////////////////////////////
  int[] pt_tag2 ;
  int[] pt_tag1 ;
  int[] pt_prev ;
  boolean[] pt_left ;
  boolean[] pt_treated ;
  boolean[] nbh_left ;
  int[][] pt_nhd ;
  int[][] pt_row ;
  int cancel_loop_phase=0;

  void cancel_loop() {
    cancel_loop1();
    cancel_loop2();
    cancel_loop3();
  }


  void cancel_loop1() {//
    cancel_loop_phase=1;
    int pointsSize = DE.points.size();
    pt_tag2 = new int[pointsSize];
    pt_tag1 = new int[pointsSize];
    pt_prev = new int[pointsSize];
    pt_left = new boolean[pointsSize];
    pt_treated = new boolean[pointsSize];
    nbh_left = new boolean[DE.nbhds.size()];
    pt_nhd = new int[pointsSize][4];
    pt_row = new int[pointsSize][4];
    for (int p=0; p<pointsSize; p++) {
      pt_tag2[p]=-1;
      pt_tag1[p]=-1;
      pt_prev[p]=-1;
      pt_left[p]=false;
      pt_treated[p]=false;
      pt_nhd[p][0]=pt_nhd[p][1]=pt_nhd[p][2]=pt_nhd[p][3]=-1;
      pt_row[p][0]=pt_row[p][1]=pt_row[p][2]=pt_row[p][3]=-1;
    }
    for (int n=0; n<DE.nbhds.size (); n++) {
      Nbhd u = DE.getNbhd(n);
      if(u != null){
        for (int i=0; i<4; i++) {
          if (pt_nhd[u.a][i]<0) {
            pt_nhd[u.a][i] = u.b;
            pt_row[u.a][i] = n;
            break;
          }
        }
        for (int i=0; i<4; i++) {
          if (pt_nhd[u.b][i]<0) {
            pt_nhd[u.b][i] = u.a;
            pt_row[u.b][i] = n;
            break;
          }
        }
        nbh_left[n]=false;
      }
    }
    for (int p=0; p<DE.points.size (); p++) {
      fill_pt_tag1(p, 1);
    }
  }

  void cancel_loop2() {//
    cancel_loop_phase=2;
    int max, maxp, countp=DE.points.size();
    do {
      countp--;
      max=0;
      maxp=-1;
      for (int p=0; p<DE.points.size (); p++) {
        if ( pt_tag2[p]<0 && pt_tag1[p]>max) {
          max = pt_tag1[p];
          maxp = p;
        }
      }
      fill_pt_tag2(maxp, 1, -1);
    } while (max>0 && countp>0);
  }

  void cancel_loop3() {//
    cancel_loop_phase=3;
    int max, maxp, countp=DE.points.size();
    do {
      countp--;
      max=0;
      maxp=-1;
      for (int p=0; p<DE.points.size (); p++) {
        if ( !pt_treated[p] && pt_tag2[p]>max) {
          max = pt_tag2[p];
          maxp = p;
        }
      }
      fill_pt_treated(maxp);
      Bead bdMaxp = DE.getBead(maxp);
      if (bdMaxp != null) {
        if ( bdMaxp.c>0) {
          for (int q=maxp; q!=-1; q=pt_prev[q]) {
            pt_left[q]=true;
          }
        }
      }
    } while (max>0 && countp>0);
    for (int p=DE.points.size ()-1; p>=0; p--) {
      if ( !pt_left[p] ) {
        removeBeadsWithAll(p);
      }
    }
  }

  void fill_pt_tag1(int p, int i) {
    if (! is_Beads_id(p)) {
      return ;
    }
    if (pt_tag1[p]>=0) {
      return ;
    } else {
      pt_tag1[p] = i;
      for (int k=0; k<4; k++) {
        fill_pt_tag1(pt_nhd[p][k], i+1);
      }
    }
  }

  void fill_pt_tag2(int p, int i, int prev) {
    if (! is_Beads_id(p)) {
      return ;
    }
    if (pt_tag2[p]>=0) {
      return ;
    } else {
      pt_tag2[p] = i;
      pt_prev[p] = prev;
      for (int k=0; k<4; k++) {
        fill_pt_tag2(pt_nhd[p][k], i+1, p);
      }
    }
  }


  void fill_pt_treated(int p) {
    if (! is_Beads_id(p)) {
      return ;
    }
    if (pt_treated[p]) {
      return ;
    }
    pt_treated[p] = true;
    for (int k=0; k<4; k++) {
      fill_pt_treated(pt_nhd[p][k]);
    }
  }

  void removeBeadsWithAll(int p) {
    Bead u = DE.getBead(p);
    if (u==null) {
      return ;
    }
    Bead uo = DE.getBead(u.n1);
    if (uo != null) {
      uo.c --;
      if (uo.n1==p) { 
        uo.n1=uo.n2; 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.n2==p) { 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.u1==p) { 
        uo.u1=uo.u2; 
        uo.u2=-1;
      }
    }
    uo = DE.getBead(u.n2);
    if (uo != null) {
      uo.c --;
      if (uo.n1==p) { 
        uo.n1=uo.n2; 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.n2==p) { 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.u1==p) { 
        uo.u1=uo.u2; 
        uo.u2=-1;
      }
    }
    uo = DE.getBead(u.u1);
    if (uo != null) {
      uo.c --;
      if (uo.n1==p) { 
        uo.n1=uo.n2; 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.n2==p) { 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.u1==p) { 
        uo.u1=uo.u2; 
        uo.u2=-1;
      }
    }
    uo = DE.getBead(u.u2);
    if (uo != null) {
      uo.c --;
      if (uo.n1==p) { 
        uo.n1=uo.n2; 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.n2==p) { 
        uo.n2=uo.u1; 
        uo.u1=uo.u2; 
        uo.u2=-1;
      } else if (uo.u1==p) { 
        uo.u1=uo.u2; 
        uo.u2=-1;
      }
    }
    DE.removeBeadFromPoint(p);
    for (int i=DE.nbhds.size ()-1; i>=0; i--) {
      Nbhd r = DE.getNbhd(i) ;
      if(r != null){
        if (r.a==p || r.b==p) {
          DE.nbhds.remove(i);
        }
      }
    }
  }

  ////////////////////////////////////////////
  //
  //      remove_dust()
  //
  ////////////////////////////////////////////

  void remove_dust() {
    int pointsSize = DE.points.size();
    pt_left = new boolean[pointsSize];
    for (int i=0; i<pointsSize; i++) {
      pt_left[i] = true;
    }
    for (int u=0; u<DE.points.size(); u++) {
      Bead vec0 = DE.getBead(u);
      if (vec0 != null) {
        if (vec0.c == 0) {
          pt_left[u]=false;
        } else 
        if (vec0.c == 1) {
          int a_prev = u;
          int a_now = vec0.n1;
          Bead bdANow = DE.getBead(a_now);
          if (bdANow != null) {
            if (bdANow.c == 1) {
              pt_left[a_prev]=false;
              pt_left[a_now]=false;
            }
          }
        }
      }
    }
    for (int p=DE.points.size()-1; p>=0; p--) {
      if ( !pt_left[p] ) {
        removeBeadsWithAll(p);
      }
    }
  }


  ////////////////////////////////////////////
  //
  //      find_crossing()
  //
  ////////////////////////////////////////////
  boolean find_crossing() {
    for (int i=0; i<DE.points.size (); i++) {
      Bead bdsi=DE.getBead(i);
      if (bdsi != null) {
        if (bdsi.c==1) {
          float min=9999;
          int minJ=-1;
          for (int j=0; j<DE.points.size (); j++) {
            Bead bdsj = DE.getBead(j);
            if (bdsj != null) {
              if (bdsj.c==2) {
                float d1=dist(bdsi.x, bdsi.y, DE.getBead(bdsj.n1).x, DE.getBead(bdsj.n1).y);
                float d=dist(bdsi.x, bdsi.y, bdsj.x, bdsj.y);
                float d2=dist(bdsi.x, bdsi.y, DE.getBead(bdsj.n2).x, DE.getBead(bdsj.n2).y);
                if (i!=j && d<min && d<d1 && d<d2) {
                  //if (j!=bdsi.n1 && DE.points.get(bdsi.n1).c == 2) {
                  if (!is_near_two_points(i, j, 5)) {
                    min=d;
                    minJ=j;
                  }
                }
              }
            }
          }
          if (minJ>=0) {
            cross.add(new Nbhd(i, minJ));
          }
        }
      }
    }
    find_crosspt_from_cross_new();
    return false;
  }

  boolean is_near_two_points(int p, int q, int cc) {
    if (p==q) {
      return true;
    }
    int a_prev = p;
    Bead bdP = DE.getBead(p);
    if (bdP == null) {
      return false;
    }
    int a_now = bdP.n1;
    if (is_Beads_id(a_now)) {
      for (int i=0; i<cc && a_now!=-1; i++) {
        if (a_now==q) {
          return true;
        }
        int a_next = find_next(a_prev, a_now);
        a_prev = a_now;
        a_now = a_next;
      }
    }
    a_prev = p;
    a_now = bdP.n2;
    if (is_Beads_id(a_now)) {
      for (int i=0; i<cc && a_now!=-1; i++) {
        if (a_now==q) {
          return true;
        }
        int a_next = find_next(a_prev, a_now);
        a_prev = a_now;
        a_now = a_next;
      }
    }
    return false;
  }

  int find_next(int prv, int nw) {
    Bead v = DE.getBead(nw);
    if (v != null) {
      if (v.n1 == prv) {
        return v.n2;
      } else if (v.n2 == prv) {
        return v.n1;
      } else if (v.u1 == prv) {
        return v.u2;
      } else if (v.u2 == prv) {
        return v.u1;
      }
    }
    return -1;
  }

  void find_crosspt_from_cross_new() {
    for (int j=0; j<cross.size (); j++) {
      Nbhd cj = cross.get(j);
      int m=0, max=DE.points.size();
      int maxk=-1;
      for (int k=0; k<cross.size (); k++) {
        if (j != k) {
          Nbhd ck = cross.get(k);
          m = find_near_points(cj.b, ck.b, 10);
          if (0<=m && m<max) {
            max = m;
            maxk = k;
          }
        }
      }
      if (j<maxk) {
        Nbhd ck = cross.get(maxk);
        Bead bdCkB=DE.getBead(ck.b);
        if (bdCkB!=null) {
          bdCkB.Joint=true;
          bdCkB.u1=cj.a;
          // TODO 向きを決めないといけない
          bdCkB.u2=ck.a;
        }
        Bead bdCjA= DE.getBead(cj.a);
        if (bdCjA != null) {
          bdCjA.c=2;
          bdCjA.n2=ck.b;
        }
        Bead bdCkA = DE.getBead(ck.a);
        if (bdCkA != null) {
          bdCkA.c=2;
          bdCkA.n2=ck.b;
        }
      }
    }
  }

  int find_near_points(int p, int q, int cc) {
    if (p==q) {
      return 0;
    }
    int a_prev = p;
    Bead bdP = DE.getBead(p);
    if (bdP == null) {
      return -1;
    }
    int a_now = bdP.n1;
    if (is_Beads_id(a_now)) {
      for (int i=0; i<cc && a_now!=-1; i++) {
        if (a_now==q) {
          return i;
        }
        int a_next = find_next(a_prev, a_now);
        a_prev = a_now;
        a_now = a_next;
      }
    }
    a_prev = p;
    a_now = bdP.n2;
    if (a_now>=0) {
      for (int i=0; i<cc && a_now!=-1; i++) {
        if (a_now==q) {
          return i;
        }
        int a_next = find_next(a_prev, a_now);
        a_prev = a_now;
        a_now = a_next;
      }
    }
    return -1;
  }
}