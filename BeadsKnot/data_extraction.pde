class data_extract {       //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  // 画像からの読みとり
  // ビーズとそれをつなぐNbhからなる。
  int w, h;// 解析画面の大きさ
  int d[][];// ２値化された画像のデータ
  int s;//解析メッシュのサイズ
  display disp;
  int between_beads[];//消すためのbeadsのpointの番号を入れておく配列
  int pre_endID=0;//消すときにendIDにとってのn1を消すのかn2を消すのかを調べるために使う
  boolean over_crossing=true;//overならtrue,underならfalse

  ArrayList<Nbhd> nbhds=new ArrayList<Nbhd>();//線を登録
  ArrayList<Bead> points=new ArrayList<Bead>();//点を登録
  transform tf;
  Binarization bin;
  Square sq;
  Thinning th;
  float nearX;

  //コンストラクタ
  data_extract(int _h, int _w, display _disp) {
    w = _w;
    h = _h;
    tf=new transform(this);
    bin = new Binarization(this);
    sq = new Square(this);
    th = new Thinning(this);
    disp = _disp;
  }


  int addBeadToPoint(float _x, float _y) {// pointsにある「消去済み」を再利用する。
    for (int ptID=0; ptID<points.size (); ptID++) {
      Bead pt = points.get(ptID);
      if (pt!=null) {
        if (pt.inUse == false) {
          pt.x = _x;
          pt.y = _y;
          pt.inUse = true;
          pt.Joint=false;
          pt.midJoint=false;
          return ptID;
        }
      }
    }
    Bead pt = new Bead(_x, _y);
    pt.n1 = pt.n2 = 0;
    pt.inUse = true;
    points.add(pt);
    return points.size()-1;
  }

  Bead getBead(int ID) {
    if (0<=ID && ID<points.size()) {
      Bead pt = points.get(ID);
      if (pt == null) {
        return null;
      }
      if (pt.inUse) {
        return pt;
      }
    }
    return null;
  }

  void removeBeadFromPoint(int ID) {
    if (0<=ID && ID<points.size()) {
      Bead pt = points.get(ID);
      pt.n1 = pt.n2 = -1;
      pt.x = pt.y = -1;
      pt.c = 0;
      pt.inUse=false;
      pt.Joint = pt.midJoint = false;
    }
  }

  void clearAllPoints() {// points.clear()のかわり
    for (int ID = 0; ID < points.size (); ID++) {
      Bead bd = points.get(ID);
      bd.n1 = bd.n2 = -1;
      bd.x = bd.y = -1;
      bd.c = 0;
      bd.inUse=false;
      bd.Joint = bd.midJoint = false;
    }
  }

  int addNbhdToNbhds(int _a, int _b) {
    for (int nbID=0; nbID<points.size (); nbID++) {
      Nbhd nb = getNbhd(nbID);
      if (nb!=null) {
        if (nb.inUse == false) {
          nb.a = _a;
          nb.b = _b;
          nb.inUse = true;
          return nbID;
        }
      }
    }
    Nbhd nb = new Nbhd(_a, _b);
    nb.inUse = true;
    nbhds.add(nb);
    return nbhds.size()-1;
  }

  Nbhd getNbhd(int ID) {
    if (0<=ID && ID<nbhds.size()) {
      Nbhd nb = nbhds.get(ID);
      if (nb == null) {
        return null;
      }
      if (nb.inUse) {
        return nb;
      }
    }
    return null;
  }

  void removeNbhdFromNbhds(int ID) {
    Nbhd nb=getNbhd(ID);
    if (nb!=null) {
      nb.inUse=false;
      nb.a = -1;
      nb.b = -1;
    }
  }

  void clearAllNbhd() {
    nbhds.clear();
  }

  // imageデータの解析
  boolean make_data_extraction(PImage image) {
    //もと画像が横長の場合，縦長の場合に応じて変える。
    // オフセットを50 に取っている。
    float ratio = 1.0 * image.width / image.height;
    if (ratio >= 1.0) {
      h = int((w - 100)/ratio + 100);
    } else {
      w = int((h - 100)*ratio + 100);
    }
    image.resize(w - 100, h - 100);//リサイズする。

    bin.getBinarized(image);//２値化してd[][]に格納する

    int result = sq.getSquareExtraction();//正方形分割
    if (result == 1) {
      return true;
    }

    if (result == 0) {
      if (th.getThinningExtraction()) {//thinning ver.
        return true;
      }
    }
    // result = 2の時は手作業モードへと進む。
    return false;
  }

  int addToPoints(int u, int v, int threshold) {//点を追加する
    // (u,v)は点の座標なので，float型ではないか？
    for (int ptID=0; ptID<points.size (); ptID++) {
      Bead pt = getBead(ptID);
      if (pt!=null) {
        if (dist(u, v, pt.x, pt.y ) < threshold-1) {//近くに既存の点がある場合には追加しない
          return ptID;
        }
      }
    }
    int ret = addBeadToPoint(u, v);
    return ret;
  }

  void drawPoints() {//点をかく
    for (int pt=0; pt<points.size (); pt++) {
      float c = 2;
      Bead vec = getBead(pt);
      if (vec == null) {
        continue;
      }
      if (vec.Joint) {
        stroke(0);
        if (dist(mouseX, mouseY, disp.get_winX(vec.x), disp.get_winY(vec.y)) < 10 ) {
          fill(255, 80, 80);
        } else {
          fill(80, 255, 80);
        }
        c=4;
      } else if (vec.midJoint||vec.bandJoint) {
        stroke(0);
        if (dist(mouseX, mouseY, disp.get_winX(vec.x), disp.get_winY(vec.y)) < 10 ) {
          fill(255, 0, 180);
        } else {
          fill(180, 255, 0);
        }
        c=3;
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      if (vec.c<=0 || vec.c>=4 || vec.inUse == false || next_to_undercrossing(pt)) {
      } else {
        //dispをつかって表示を画面サイズに合わせるように座標変換する。
        ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), c*3+1, c*3+1);
        if (dist(mouseX, mouseY, disp.get_winX(vec.x), disp.get_winY(vec.y)) < 10 ) {
          fill(0);
          if (Draw._show_points_nb) {
            text(pt+" "+vec.n1+" "+vec.n2+" "+vec.u1+" "+vec.u2+" "+vec.Joint+" "+vec.midJoint+" "+vec.bandJoint, disp.get_winX(vec.x), disp.get_winY(vec.y));
          } else if (Draw._show_orientation_nb) {
            text(vec.orientation, disp.get_winX(vec.x), disp.get_winY(vec.y));
          } else if (Draw._show_node_nb){
            for(int nn=0; nn<graph.nodes.size(); nn++){
              if(graph.nodes.get(nn).pointID == pt){
                text(nn, disp.get_winX(vec.x), disp.get_winY(vec.y));
                break;
              }
            }
          }
          //if(vec.Joint){
          //  println("n1 = "+vec.n1+":u1 = "+vec.u1+":n2 = "+vec.n2+":u2 = "+vec.u2);
        }//}
        //println("点を消します");
      }
    }
  }

  void draw_smoothing_Points() {//交点を割いたバージョンの点をかく
    //positiveが赤色
    //negativeが青色
    for (int pt=0; pt<points.size (); pt++) {
      float c = 2;
      Bead vec=getBead(pt);
      if (vec == null) {
        continue;
      }
      int n1=vec.n1;
      int n2=vec.n2;
      int u1=vec.u1;
      int u2=vec.u2;
      Bead vecn1 = getBead(n1);
      Bead vecn2 = getBead(n2);
      Bead vecu1 = getBead(u1);
      Bead vecu2 = getBead(u2);
      if (vecn1==null || vecn2==null) {
        continue;
      }
      if (vec.Joint) {
        if (vecu1==null || vecu2==null) {
          continue;
        }
        //if (vecn1.orientation > vecn2.orientation) {
        if (orie.orientation_greater(vecn1.orientation, vecn2.orientation)==1) {
          if (orie.orientation_greater(vecu1.orientation, vecu2.orientation)==1) {
            //fill(255, 0, 0);//positive
            noStroke();
            fill(255, 0, 0, 25);
            ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), 100, 100);
          } else {
            //fill(0, 0, 255);//negative
            noStroke();
            fill(0, 0, 255, 25);
            ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), 100, 100);
          }
        } else {
          if (orie.orientation_greater(vecu1.orientation, vecu2.orientation)==1) {
            //fill(0, 0, 255);//negative
            noStroke();
            fill(0, 0, 255, 25);
            ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), 100, 100);
          } else {
            //fill(255, 0, 0);//positive
            noStroke();
            fill(255, 0, 0, 25);
            ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), 100, 100);
          }
        }
        stroke(0);
        fill(80, 255, 80);
        c=0;
        //} else if (vec.closeJoint) {
        //  //stroke(0, 255, 0);
        //  stroke(0);
        //  fill(255);
      } else if (vec.midJoint) {
        stroke(0);
        fill(180, 255, 0);
        c=3;
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      if (c<=0||vec.c<=0 || vec.c>=4 || vec.n1==-1 || vec.n2==-1) {
      } else {
        //dispをつかって表示を画面サイズに合わせるように座標変換する。
        ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), c*3+1, c*3+1);
        if (dist(mouseX, mouseY, disp.get_winX(vec.x), disp.get_winY(vec.y)) < 10 ) {
          fill(0);
          if (Draw._show_points_nb) {
            text(pt+" "+vec.n1+" "+vec.n2+" "+vec.u1+" "+vec.u2, disp.get_winX(vec.x), disp.get_winY(vec.y));
          } else if (Draw._show_orientation_nb) {
            text(vec.orientation, disp.get_winX(vec.x), disp.get_winY(vec.y));
          }
          //if(vec.Joint){
          //  println("n1 = "+vec.n1+":u1 = "+vec.u1+":n2 = "+vec.n2+":u2 = "+vec.u2);
        }//}
      }
    }
  }

  int addToNbhds(int nn, int mm) {//線を追加する
    if (nn!=mm && connected(nn, mm)==1) {
      nbhds.add(new Nbhd(nn, mm));
    }
    return 1;
  }

  int connected(int nn, int mm) {//線がつながっているかチェックする
    // nn,mmはpointsのなかの番号
    if ( duplicateNbhds(nn, mm)==1) {//重複したら
      return 0;
    }
    if (nn==mm) {
      return 0;
    }
    if (nn<0 || mm<0 || points.size()<=nn || points.size()<=mm) {
      return 0;
    }
    Bead bdN = getBead(nn);
    Bead bdM = getBead(mm);
    if (bdN==null || bdM==null) {
      return 0;
    }
    float xa=bdN.x;
    float ya=bdN.y;
    float xb=bdM.x;
    float yb=bdM.y;
    int l=int(min(xa, xb));
    int r=int(max(xa, xb));
    int t=int(min(ya, yb));
    int b=int(max(ya, yb));
    int [][]f=new int[r-l+1][b-t+1];
    int [][]g=new int[r-l+1][b-t+1];  
    for (int x=0; x<r-l+1; x++) {
      for (int y=0; y<b-t+1; y++) {
        f[x][y]=d[l+x][t+y];
      }
    }
    int fax=int(xa-l);
    int fay=int(ya-t);//f上でのAの位置
    int fbx=int(xb-l);
    int fby=int(yb-t);//f上でのBの位置

    //f上で黒だけを通って(fax,fay)~(fbx,fby)へいく
    for (int x=0; x<r-l+1; x++) {
      for (int y=0; y<b-t+1; y++) {
        g[x][y]=0;
      }
    }
    g[fax][fay]=1;
    boolean loop_end;
    do {
      loop_end=true;
      for (int x=0; x<r-l+1; x++) {
        for (int y=0; y<b-t+1; y++) {
          if (g[x][y]==1) {
            if (x!=0&&y!=0&&f[x-1][y-1]==1&&g[x-1][y-1]==0) {
              g[x-1][y-1]=1;
              loop_end=false;
            }
            if (y!=0&&f[x][y-1]==1&&g[x][y-1]==0) {
              g[x][y-1]=1;
              loop_end=false;
            }
            if (y!=0&&x!=r-l&&f[x+1][y-1]==1&&g[x+1][y-1]==0) {
              g[x+1][y-1]=1;
              loop_end=false;
            }
            if (x!=0&&f[x-1][y]==1&&g[x-1][y]==0) {
              g[x-1][y]=1;
              loop_end=false;
            }
            if (x!=r-l&&f[x+1][y]==1&&g[x+1][y]==0) {
              g[x+1][y]=1;
              loop_end=false;
            }
            if (x!=0&&y!=b-t&&f[x-1][y+1]==1&&g[x-1][y+1]==0) {
              g[x-1][y+1]=1;
              loop_end=false;
            }
            if (y!=b-t&&f[x][y+1]==1&&g[x][y+1]==0) {
              g[x][y+1]=1;
              loop_end=false;
            }
            if (x!=r-l&&y!=b-t&&f[x+1][y+1]==1&&g[x+1][y+1]==0) {
              g[x+1][y+1]=1;
              loop_end=false;
            }
            g[x][y]=2;//Aが1ならば2にする
          }
        }
      }
    } while (!loop_end);//1がなくなるまで繰り返す
    //もし1がなくなり、すべて2にすることができたら
    if (g[fbx][fby]==2) {
      return 1;//OKなら1を返す
    } else {
      return 0;
    }
  }

  void drawNbhds() {//線を書く
    for (int ptID=0; ptID<points.size (); ptID++) {
      if (!next_to_undercrossing(ptID)) {
        Bead pt=getBead(ptID);
        if (pt == null) {
          continue;
        }
        if ( 0<=pt.n1 && pt.n1<points.size() && !next_to_undercrossing(pt.n1)) {
          stroke(0);
          Bead pt2 = getBead(pt.n1);
          if (pt2 != null && ! pt2.Joint) {
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
        if (0<=pt.n2 && pt.n2<points.size() && !next_to_undercrossing(pt.n2)) {
          stroke(0);
          Bead pt2 = getBead(pt.n2);
          if (pt2 != null && ! pt2.Joint) {
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
      }
    }
  }

  void draw_smoothing_Nbhds() {//Jointの周りだけつなげ方を変える//jointも消す
    //positiveが赤色
    //negativeが青色
    for (int ptID=0; ptID<points.size (); ptID++) {
      Bead pt=getBead(ptID);
      if (pt==null) {
        continue;
      }
      if (pt.Joint) {
        int n1=pt.n1;
        int n2=pt.n2;
        int u1=pt.u1;
        int u2=pt.u2;
        Bead pt1=getBead(n1);
        Bead pt2=getBead(u2);
        Bead pt3=getBead(n2);
        Bead pt4=getBead(u1);
        if (pt1==null || pt2==null || pt3==null || pt4==null) {
          continue;
        }
        //if (pt1.orientation < pt3.orientation) {
        //  if (pt4.orientation < pt2.orientation) {
        if (orie.orientation_greater(pt1.orientation, pt3.orientation)==-1) {
          if (orie.orientation_greater(pt4.orientation, pt2.orientation)==-1) {
            float ax=disp.get_winX(pt1.x);
            float ay=disp.get_winY(pt1.y);
            float bx=disp.get_winX(pt2.x);
            float by=disp.get_winY(pt2.y);
            float cx=disp.get_winX(pt3.x);
            float cy=disp.get_winY(pt3.y);
            float dx=disp.get_winX(pt4.x);
            float dy=disp.get_winY(pt4.y);
            stroke(0);
            strokeWeight(1);
            line(ax, ay, bx, by);
            line(cx, cy, dx, dy);
            stroke(255, 0, 0);//positive
            strokeWeight(3);
            line((ax+bx)/2, (ay+by)/2, (cx+dx)/2, (cy+dy)/2);//Hの横棒
          } else {
            //Bead pt1=getBead(n1);
            //Bead pt2=getBead(u1);
            //Bead pt3=getBead(n2);
            //Bead pt4=getBead(u2);
            float ax=disp.get_winX(pt1.x);
            float ay=disp.get_winY(pt1.y);
            float bx=disp.get_winX(pt4.x);
            float by=disp.get_winY(pt4.y);
            float cx=disp.get_winX(pt3.x);
            float cy=disp.get_winY(pt3.y);
            float dx=disp.get_winX(pt2.x);
            float dy=disp.get_winY(pt2.y);
            stroke(0);
            strokeWeight(1);
            line(ax, ay, bx, by);
            line(cx, cy, dx, dy);
            stroke(0, 0, 255);//negtive
            strokeWeight(3);
            line((ax+bx)/2, (ay+by)/2, (cx+dx)/2, (cy+dy)/2);//Hの横棒
          }
        } else {
          //if (pt4.orientation < pt2.orientation) {
          if (orie.orientation_greater(pt4.orientation, pt2.orientation)==-1) {
            //Bead pt1=getBead(n2);
            //Bead pt2=getBead(u2);
            //Bead pt3=getBead(n1);
            //Bead pt4=getBead(u1);
            float ax=disp.get_winX(pt3.x);
            float ay=disp.get_winY(pt3.y);
            float bx=disp.get_winX(pt2.x);
            float by=disp.get_winY(pt2.y);
            float cx=disp.get_winX(pt1.x);
            float cy=disp.get_winY(pt1.y);
            float dx=disp.get_winX(pt4.x);
            float dy=disp.get_winY(pt4.y);
            stroke(0);
            strokeWeight(1);
            line(ax, ay, bx, by );
            line(cx, cy, dx, dy );
            stroke(0, 0, 255);//negative
            strokeWeight(3);
            line((ax+bx)/2, (ay+by)/2, (cx+dx)/2, (cy+dy)/2);//Hの横棒
          } else {
            //Bead pt1=getBead(n2);
            //Bead pt2=getBead(u1);
            //Bead pt3=getBead(n1);
            //Bead pt4=getBead(u2);
            float ax=disp.get_winX(pt3.x);
            float ay=disp.get_winY(pt3.y);
            float bx=disp.get_winX(pt4.x);
            float by=disp.get_winY(pt4.y);
            float cx=disp.get_winX(pt1.x);
            float cy=disp.get_winY(pt1.y);
            float dx=disp.get_winX(pt2.x);
            float dy=disp.get_winY(pt2.y);
            stroke(0);
            strokeWeight(1);
            line(ax, ay, bx, by );
            line(cx, cy, dx, dy );
            stroke(255, 0, 0);//positive
            strokeWeight(3);
            line((ax+bx)/2, (ay+by)/2, (cx+dx)/2, (cy+dy)/2);//Hの横棒
          }
        }
      } else {
        if (0<=pt.n1 && pt.n1<points.size()) {
          stroke(0);
          Bead pt2 = getBead(pt.n1);
          if (pt2!=null && ! pt2.Joint) {
            strokeWeight(1);
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
        if (0<=pt.n2 && pt.n2<points.size()) {
          stroke(0);
          Bead pt2 = getBead(pt.n2);
          if (pt2!=null && ! pt2.Joint) {
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
      }
    }
  }

  void countNbhds() {//線を数える
    for (int vecID=0; vecID<points.size(); vecID++) {
      Bead vec = getBead(vecID);
      if (vec!=null) {
        vec.c=0;
        vec.n1=vec.n2=vec.u1=vec.u2=-1;//正常でない値
      }
    }
    for (int nbID=0; nbID<nbhds.size(); nbID++) {
      Nbhd n = getNbhd(nbID);
      if (n!=null) {
        // getBead(n.a).c++;
        //getBead(n.b).c++;
        if (n.inUse) {
          Bead vec_1=getBead(n.a);
          if (vec_1!=null) {
            if (vec_1.c==0) {
              vec_1.n1=n.b;
              vec_1.c++;
            } else if (vec_1.c==1) {
              vec_1.n2=n.b;
              vec_1.c++;
            } else if (vec_1.c==2) {
              vec_1.u1=n.b;
              vec_1.c++;
            } else if (vec_1.c==3) {
              vec_1.u2=n.b;
              vec_1.c++;
            }
          }
          Bead vec_2=getBead(n.b);
          if (vec_2!=null) {
            if (vec_2.c==0) {
              vec_2.n1=n.a;
              vec_2.c++;
            } else if (vec_2.c==1) {
              vec_2.n2=n.a;
              vec_2.c++;
            } else if (vec_2.c==2) {
              vec_2.u1=n.a;
              vec_2.c++;
            } else if (vec_2.c==3) {
              vec_2.u2=n.a;
              vec_2.c++;
            }
          }
        }
      }
    }
  }


  void getDisplayLTRB() {
    float l, t, r, b;
    l=t=r=b=0;
    for (int u=0; u<points.size (); u++) {
      Bead pt=getBead(u);
      if (pt != null) {
        if (u==0) {
          l=r=pt.x;
          t=b=pt.y;
        } else {
          if (pt.x<l) l=pt.x;
          if (r<pt.x) r=pt.x;
          if (pt.y<t) t=pt.y;
          if (b<pt.y) b=pt.y;
        }
      }
    }
    disp.left=l;
    disp.right=r;
    disp.top=t;
    disp.bottom=b;
    disp.set_rate();
  }

  void addJointToNbhds() {//jointに関しての線を追加
    for (int u=0; u<points.size (); u++) {
      Bead vec=getBead(u);
      if (vec != null && vec.Joint) {
        if (duplicateNbhds(u, vec.u1)==0) {
          nbhds.add(new Nbhd(u, vec.u1));
        }
        if (duplicateNbhds(u, vec.u2)==0) {
          nbhds.add(new Nbhd(u, vec.u2));
        }
      }
    }
  }

  int duplicateNbhds(int ptID1, int ptID2) {//線が重複しているかどうかを調べる
    for (int nbID=0; nbID<nbhds.size(); nbID++) {
      Nbhd nb = getNbhd(nbID);
      if (nb!=null) {
        if (nb.inUse && ptID1==nb.a && ptID2==nb.b) {
          return 1;
        }
        if (nb.inUse && ptID1==nb.b&& ptID2==nb.a) {
          return 1;
        }
      }
    }
    return 0;
  }

  void removePoint(int ptID) {//点を消す
    removeBeadFromPoint(ptID);
    for (int nbID=nbhds.size ()-1; nbID>=0; nbID--) {
      Nbhd nb=nbhds.get(nbID);
      if (nb != null) {
        if (nb.a==ptID || nb.b==ptID) {
          nb.inUse = false;
        }
      }
    }
  }

  void removePoint2(int u) {
    for (int i=0; i<points.size (); i++) {
      Bead vec_po=getBead(i);
      if (vec_po.n1>u) {
        vec_po.n1--;
      }
      if (vec_po.n2>u) {
        vec_po.n2--;
      }
      if (vec_po.u1>u) {
        vec_po.u1--;
      }
      if (vec_po.u2>u) {
        vec_po.u2--;
      }
    }
  }

  void removeThrone() {//とげを除く
    for (int u=0; u<points.size (); u++) {
      Bead bdU = getBead(u);
      if (bdU==null) {
        continue;
      }
      if ( getBead(u).c==1) {
        for (int i=nbhds.size ()-1; i>=0; i--) {
          Nbhd n=getNbhd(i);
          if (n!=null) {
            if (n.a==u) {
              Bead bdNB = getBead(n.b); 
              if (bdNB!=null && bdNB.c==3) {
                removePoint(u);
                bdNB.c=2;
              }
            } 
            if (n.b==u) {
              Bead bdNA = getBead(n.a);
              if (bdNA!=null && bdNA.c==3) {
                removePoint(u);
                bdNA.c=2;
              }
            }
          }
        }
      }
    }
  }

  void fillGap() {//点と点の距離の最小を記録し、最小の距離の点が1本さんならばその点と点をつなげる
    for (int u=0; u<points.size (); u++) {
      Bead bdU = getBead(u);
      if (bdU!=null) {
        if ( bdU.c==1) {// まず「自分」がおひとりさまの場合のみ調べる
          float min=w;//大きな値から始める。
          int num=-1;//最小の距離の点の番号を記録するための変数
          for (int v=0; v<points.size (); v++) {
            Bead bdV = getBead(v);
            if (bdV != null && u != v) {
              if (bdU.n1!=v) {//おひとりさまの相手は近くにいるに決まっているので探索対象から除外
                float d=dist(bdU.x, bdU.y, bdV.x, bdV.y);
                if (min>d) {
                  min=d;
                  num=v;
                }
              }
            }
          }
          Bead bdNum = getBead(num);
          if (bdNum!=null) {
            if (bdNum.c==1) {//最小の距離の点がおひとりさま
              addToNbhds(u, num);
              //なにかする//TODO 「なにかする」という古いメッセージの意味を考える。
              bdNum.c++;
              bdU.c++;
            } else if (bdNum.c==0) {//最小の距離の点が孤立
              addToNbhds(u, num);
              bdNum.c++;
              bdU.c++;
            }
          }
        }
      }
    }
  }

  void FindJoint() {//jointを探す
    for (int u=0; u<points.size (); u++) {
      Bead bdU = getBead(u);
      if (bdU!=null &&  bdU.c==1) {
        float min=w;
        int num = 0;
        int un1=bdU.n1;
        Bead bdun1 = getBead(un1);
        int un1n1=-1, un1n2=-1;
        if (bdun1!=null) {
          un1n1 = bdun1.n1;
          un1n2 = bdun1.n2;
        }
        for (int v=0; v<points.size (); v++) {
          Bead bdV = getBead(v);
          if (bdV!=null) {
            if (v!=u && v!=un1 && v!=un1n1 && v!=un1n2) {
              float d=dist(bdU.x, bdU.y, bdV.x, bdV.y);
              if (min>d) {
                min=d;
                num=v;
              }
            }
          }
        }
        Bead bdNum = getBead(num);
        if (bdNum!=null && getBead(num).c==2) {
          bdNum.Joint=true;
          if (bdNum.u1==-1) {
            bdNum.u1=u;
          } else {
            bdNum.u2=u;
            int numU1 = bdNum.u1;
            int numU2 = u;//bdNum.u2;
            Bead bdNumU1 = getBead(numU1);
            Bead bdNumU2 = getBead(numU2);
            if (bdNumU1 != null) {
              bdNumU1.n2=num;
              bdNumU1.c++;
            }
            if (bdNumU2 != null) {
              bdNumU2.n2=num;
              bdNumU2.c++;
            }
            continue;
          }
          int numN1=bdNum.n1;
          Bead bdNumN1 = getBead(numN1);
          if (bdNumN1 != null && bdNumN1.Joint) {//隣だったとき
            bdNumN1.Joint = false;
            bdNum.u2 = bdNumN1.u1;
            bdNumN1.u1=-1;
            Bead bdNumU1 = getBead(bdNum.u1);
            Bead bdNumU2 = getBead(bdNum.u2);
            if (bdNumU1 != null) {
              bdNumU1.n2 = num;
              bdNumU1.c ++;
            }
            if (bdNumU2 != null) {
              bdNumU2.n2 = num;
              bdNumU2.c ++;
            }
            continue;
          } 
          int numN2=bdNum.n2;
          Bead bdNumN2 = getBead(numN2);
          if (bdNumN2 != null && bdNumN2.Joint) {
            bdNumN2.Joint=false;
            bdNum.u2 = bdNumN2.u1;
            bdNumN2.u1=-1;
            Bead bdNumU1 = getBead(bdNum.u1);
            Bead bdNumU2 = getBead(bdNum.u2);
            if (bdNumU1!=null) {
              bdNumU1.n2=num;
              bdNumU1.c++;
            }
            if (bdNumU2 !=null) {
              bdNumU2.n2=num;
              bdNumU2.c++;
            }
          }
          //隣の隣
          if (bdNumN1 != null && bdNumN2 != null) {
            int numN1N1 = bdNumN1.n1;
            Bead bdNumN1N1 = getBead(numN1N1);
            if (bdNumN1N1!=null && num != numN1N1 && bdNumN1N1.Joint) {
              bdNumN1N1.Joint=false;
              bdNumN1.Joint=true;
              bdNum.Joint=false;
              bdNumN1.u1=bdNum.u1;
              bdNum.u1=-1;
              bdNumN1.u2=bdNumN1N1.u1;
              bdNumN1N1.u1=-1;
              Bead bdNumN1U1 = getBead(bdNumN1.u1);
              if (bdNumN1U1 != null) {
                bdNumN1U1.n2=numN1;
                bdNumN1U1.c++;
              }
              Bead bdNumN1U2 = getBead(bdNumN1.u2);
              if (bdNumN1U2 != null) {
                bdNumN1U2.n2=numN1;
                bdNumN1U2.c++;
              }
              continue;
            } 
            int numN1N2 = bdNumN1.n2;
            Bead bdNumN1N2 = getBead(numN1N2);
            if (bdNumN1N2!=null && num != numN1N2 && bdNumN1N2.Joint) {
              bdNumN1N2.Joint=false;
              bdNumN1.Joint=true;
              bdNum.Joint=false;
              bdNumN1.u1=bdNum.u1;
              bdNum.u1=-1;
              bdNumN1.u2=bdNumN1N2.u1;
              bdNumN1N2.u1=-1;
              Bead bdNumN1U1 = getBead(bdNumN1.u1);
              if (bdNumN1U1 != null) {
                bdNumN1U1.n2=numN1;
                bdNumN1U1.c++;
              }
              Bead bdNumN1U2 = getBead(bdNumN1.u2);
              if (bdNumN1U2 != null) {
                bdNumN1U2.n2=numN1;
                bdNumN1U2.c++;
              }
              continue;
            } 
            int numN2N1 = bdNumN2.n1;
            Bead bdNumN2N1 = getBead(numN2N1);
            if (bdNumN2N1!=null && num != numN2N1 && bdNumN2N1.Joint) {
              bdNumN2N1.Joint=false;
              bdNumN2.Joint=true;
              bdNum.Joint=false;
              bdNumN2.u1=bdNum.u1;
              bdNum.u1=-1;
              bdNumN2.u2=bdNumN2N1.u1;
              bdNumN2N1.u1=-1;
              Bead bdNumN2U1 = getBead(bdNumN2.u1);
              if (bdNumN2U1 != null) {
                bdNumN2U1.n2=numN2;
                bdNumN2U1.c++;
              }
              Bead bdNumN2U2 = getBead(bdNumN2.u2);
              if (bdNumN2U2 != null) {
                bdNumN2U2.n2=numN2;
                bdNumN2U2.c++;
              }
              continue;
            } 
            int numN2N2 = bdNumN2.n2;
            Bead bdNumN2N2 = getBead(numN2N2);
            if (bdNumN2N2!=null && num != numN2N2 && bdNumN2N2.Joint) {
              bdNumN2N2.Joint=false;
              bdNumN2.Joint=true;
              bdNum.Joint=false;
              bdNumN2.u1=bdNum.u1;
              bdNum.u1=-1;
              bdNumN2.u2=bdNumN2N2.u1;
              bdNumN2N2.u1=-1;
              Bead bdNumN2U1 = getBead(bdNumN2.u1);
              if (bdNumN2U1 != null) {
                bdNumN2U1.n2=numN2;
                bdNumN2U1.c++;
              }
              Bead bdNumN2U2 = getBead(bdNumN2.u2);
              if (bdNumN2U2 != null) {
                bdNumN2U2.n2=numN2;
                bdNumN2U2.c++;
              }
              continue;
            }
          }
        }
      }
    }
  }

  boolean Ofutarisama() {//みんなお二人様だったか確認
    int countNG0=0;
    int countNG1=0;
    int countNG2=0;
    for (int bdID=0; bdID< points.size (); bdID++) {
      Bead bd = getBead(bdID);
      if (bd==null) {
        countNG0 ++;
        continue;
      }
      if (bd.inUse==false) {
        countNG1 ++;
        continue;
      }
      if (bd.c!=2) {
        countNG2 ++;
        continue;
        //return false;
      }
    }
    println("size="+points.size ()+":null="+countNG0+":not inUse="+countNG1+":not 2="+countNG2);
    if (countNG2>0) {
      return false;
    }
    return true;
  }

  int thickness() {//線の太さの平均を計算してくれる
    int count=0;
    int sum=0;
    int num=1;
    boolean flag=false;
    for (int y=100; y<h; y+=100) {
      for (int x=0; x<w; x++) {
        if (d[x][y]==1) {
          flag=true;
          count++;
        }
        if (flag==true&&d[x][y]==0) {
          flag=false;
          if (count>=5) {
            sum+=count;
            num++;
          }
          count=0;
        }
      }
    }
    println("thickness = "+sum/num);
    return max(3, int(sum/num));
  }

  Nbhd find_Joint_midJoint(Nbhd nbhd) {
    int j=nbhd.a;
    int c=nbhd.b;
    for (int count = 0; count < points.size (); count++) {
      Bead p=getBead(c);
      if (p==null) {
        return new Nbhd(0, 0);
      }
      if (p.Joint || p.midJoint) {
        return new Nbhd(j, c);
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("find_Joint_midJoint : ビーズがつながっていない"+j+":"+c+":"+d);
        return new Nbhd(0, 0);
      }
      j = c;
      c = d;
    }
    return new Nbhd(0, 0);
  }

  Nbhd turn_left(Nbhd nbhd) {
    Bead p=getBead(nbhd.b);
    if (p==null) {
      return new Nbhd(0, 0);
    }
    if (p.Joint) {
      if (p.n1==nbhd.a) {
        return new Nbhd(nbhd.b, p.u2);
      } else 
      if (p.u1==nbhd.a) {
        return new Nbhd(nbhd.b, p.n1);
      } else 
      if (p.n2==nbhd.a) {
        return new Nbhd(nbhd.b, p.u1);
      } else 
      if (p.u2==nbhd.a) {
        return new Nbhd(nbhd.b, p.n2);
      }
    }
    return new Nbhd(0, 0);
  }


  void draw_region(Nbhd nbhd) {
    int a = nbhd.a;
    int b = nbhd.b;
    int c = -1;
    if (a==-1 || b==-1) return;

    int repeatmax = points.size();
    Bead ptA = getBead(a);
    if (ptA==null) {
      return ;
    }
    fill(120, 120, 255, 50);
    beginShape();
    vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
    for (int repeat=0; repeat < repeatmax; repeat++) {
      // go straight
      if ( ! ptA.Joint) {
        if (ptA.n1 == b) {
          c = ptA.n2;
        } else 
        if (ptA.n2 == b) {
          c = ptA.n1;
        } else {
          println("draw_region : error");
          return ;
        }
        b = a;
        a = c;
      }      
      // if on joint, go left
      else {
        if (ptA.n1 == b) {
          c = ptA.u2;
        } else 
        if (ptA.u1 == b) {
          c = ptA.n1;
        } else 
        if (ptA.n2 == b) {
          c = ptA.u1;
        } else 
        if (ptA.u2 == b) {
          c = ptA.n2;
        } else {
          println("draw_region : error");
          return ;
        }
        b = a;
        a = c;
      }
      ptA = getBead(a);
      if (ptA==null) {
        return;
      }
      vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
      if (nbhd.a == a) {
        break;
      }
    }
    endShape();
  }

  int count_old=0;

  int smoothingRegionContainsPt(float mX, float mY, Nbhd nbhd, boolean debug) {
    if (nbhd == null) {
      return -1;
    }
    int a = nbhd.a;
    Bead ptA = getBead(a);
    int b = nbhd.b;
    Bead ptB = getBead(b);
    int c = -1;
    if (ptA == null || ptB == null) {
      return -1;
    }
    if (ptA.Joint) {
      int n1 = ptB.n1;
      int n2 = ptB.n2;
      if (n1 == a) {
        a = n2;
      } else if (n2 == a) {
        a = n1;
      } else {
        return -1;
      }
      ptA = getBead(a);
      if (ptA==null) {
        return -1;
      }
    }
    if (ptB.Joint) {
      int n1 = ptA.n1;
      int n2 = ptA.n2;
      if (n1 == b) {
        b = n2;
      } else if (n2 == b) {
        b = n1;
      } else {
        return -1;
      }
      ptB = getBead(b);
      if (ptB==null) {
        return -1;
      }
    }

    //if (ptA.orientation < ptB.orientation) {
    if (orie.orientation_greater(ptA.orientation, ptB.orientation)==-1) {
      ptA=getBead(b);
      ptB=getBead(a);
      c=a;
      a=b;
      b=c;
    }
    int start_a = a;
    int count = 0;
    nearX = mX;
    float x0, y0, x1, y1, xxx;
    int repeatmax = points.size();
    for (int repeat=0; repeat < repeatmax; repeat++) {
      // go straight
      if ( ! ptA.Joint) {
        if (ptA.n1 == b) {
          c = ptA.n2;
        } else if (ptA.n2 == b) {
          c = ptA.n1;
        } else {
          println("smoothingRegionContainsPt 1: error");
          return -1;
        }
        b = a;
        a = c;
        if (debug) {
          print("("+b+">"+a+")");
        }
        ptA= getBead(a);
        if (ptA==null) {
          return -1;
        }
        ptB = getBead(b);
        if (ptB==null) {
          return -1;
        }
        x0 = disp.get_winX(ptA.x);
        y0 = disp.get_winY(ptA.y);
        x1 = disp.get_winX(ptB.x);
        y1 = disp.get_winY(ptB.y);
        xxx = segmentIsInRight(mX, mY, x0, y0, x1, y1); 
        if (debug) {
          println(mX, mY, x0, y0, x1, y1, ":", xxx);
        }
        if (mX < xxx) {
          nearX = Math.max(nearX, xxx+1f);
          count ++;
        }
      }
      // go along smoothing curve 
      else {
        int n1=ptA.n1;
        int n2=ptA.n2;
        int u1=ptA.u1;
        int u2=ptA.u2;
        Bead bdN1=getBead(n1), bdN2=getBead(n2), bdU1=getBead(u1), bdU2=getBead(u2);
        if (bdN1==null || bdN2==null || bdU1==null || bdU2==null) {
          break;
        }
        int n1o=bdN1.orientation;
        int n2o=bdN2.orientation;
        int u1o=bdU1.orientation;
        int u2o=bdU2.orientation;
        if (orie.orientation_greater(n1o, n2o)==-1 && orie.orientation_greater(u1o, u2o)==-1) {
          if (ptA.n1 == b) {
            c = ptA.u2;
          } else if (ptA.u1 == b) {
            c = ptA.n2;
          } else {
            println("smoothingRegionContainsPt 2: error", ptA.n1, ptA.u1, ptA.n2, ptA.u2, b);
            println("smoothingRegionContainsPt 2: error", n1o, u1o, n2o, u2o);
            return -1;
          }
          b = a;
          a = c;
        } else if (orie.orientation_greater(n1o, n2o)==-1&&orie.orientation_greater(u1o, u2o)==1) {
          if (ptA.n1 == b) {
            c = ptA.u1;
          } else  if (ptA.u2 == b) {
            c = ptA.n2;
          } else {
            println("smoothingRegionContainsPt 3: error", ptA.n1, ptA.u2, ptA.n2, ptA.u1, b);
            println("smoothingRegionContainsPt 3: error", n1o, u2o, n2o, u1o);
            return -1;
          }
          b = a;
          a = c;
        } else if (orie.orientation_greater(n1o, n2o)==1 && orie.orientation_greater(u1o, u2o)==-1) {
          if (ptA.n2 == b) {
            c = ptA.u2;
          } else if (ptA.u1 == b) {
            c = ptA.n1;
          } else {
            println("smoothingRegionContainsPt 4: error", ptA.n2, ptA.u1, ptA.n1, ptA.u2, b);
            println("smoothingRegionContainsPt 4: error", n2o, u1o, n1o, u2o);
            return -1;
          }
          b = a;
          a = c;
        } else if (orie.orientation_greater(n1o, n2o)==1 && orie.orientation_greater(u1o, u2o)==1 ) {
          if (ptA.n2 == b) {
            c = ptA.u1;
          } else if (ptA.u2 == b) {
            c = ptA.n1;
          } else {
            println("smoothingRegionContainsPt 5: error", ptA.n2, ptA.u2, ptA.n1, ptA.u1, b);
            println("smoothingRegionContainsPt 5: error", n2o, u2o, n1o, u1o);
            return -1;
          }
          b = a;
          a = c;
        }
        if (debug) {
          print("["+b+">"+a+"]");
        }
        ptA= getBead(a);
        if (ptA==null) {
          return -1;
        }
        ptB = getBead(b);
        if (ptB==null) {
          return -1;
        }
        x0 = disp.get_winX(ptA.x);
        y0 = disp.get_winY(ptA.y);
        x1 = disp.get_winX(ptB.x);
        y1 = disp.get_winY(ptB.y);
        xxx = segmentIsInRight(mX, mY, x0, y0, x1, y1);
        if (debug) {
          println(mX, mY, x0, y0, x1, y1, ":", xxx);
        }
        if (mX < xxx) {
          count ++;
          nearX = Math.max(nearX, xxx+1f);
        }
      }
      if (start_a == a) {
        break;
      }
    }
    return count;
  }

  void draw_smoothing_region(Nbhd nbhd) {
    int a = nbhd.a;
    int b = nbhd.b;
    int c = -1;
    if (a==-1 || b==-1) {
      return;
    }
    int repeatmax = points.size();
    Bead ptA = getBead(a);
    Bead ptB = getBead(b);
    if (ptA==null || ptB==null) {
      return;
    }
    if (ptA.Joint) {
      int n1 = ptB.n1;
      int n2 = ptB.n2;
      if (n2 == a) {
        a = n1;
      } else if (n1 == a) {
        a = n2;
      } else {
        return ;
      }
      ptA = getBead(a);
      if (ptA==null) {
        return ;
      }
    } else if (ptB.Joint) {
      int n1 = ptA.n1;
      int n2 = ptA.n2;
      if (n2 == b) {
        b = n1;
      } else if (n1 == b) {
        b = n2;
      }
      ptB = getBead(b);
      if (ptB==null) {
        return ;
      }
    }

    if (orie.orientation_greater(ptA.orientation, ptB.orientation)==-1) {
      ptA=getBead(b);
      ptB=getBead(a);
      c=a;
      a=b;
      b=c;
    }
    int start_a = a;
    fill(120, 120, 255, 50);
    beginShape();
    vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
    for (int repeat=0; repeat < repeatmax; repeat++) {
      // go straight
      if ( ! ptA.Joint) {
        if (ptA.n1 == b) {
          c = ptA.n2;
        } else if (ptA.n2 == b) {
          c = ptA.n1;
        } else {
          println("draw_smoothing_region 1: error");
          return ;
        }
        b = a;
        a = c;
        // ptA = getBead(a);
        vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
        if (nbhd.a == a) {
          break;
        }
      }
      // if on joint, go left
      else {
        int n1=ptA.n1;
        int n2=ptA.n2;
        int u1=ptA.u1;
        int u2=ptA.u2;
        Bead bdN1=getBead(n1), bdN2=getBead(n2), bdU1=getBead(u1), bdU2=getBead(u2);
        if (bdN1==null || bdN2==null || bdU1==null || bdU2==null) {
          break;
        }
        int n1o=bdN1.orientation;
        int n2o=bdN2.orientation;
        int u1o=bdU1.orientation;
        int u2o=bdU2.orientation;
        if (orie.orientation_greater(n1o, n2o)==-1 && orie.orientation_greater(u1o, u2o)==-1) {
          if (ptA.n1 == b) {
            c = ptA.u2;
          } else if (ptA.u1 == b) {
            c = ptA.n2;
          } else {
            println("draw_smoothing_region 2: error", ptA.n1, ptA.u1, ptA.n2, ptA.u2, b);
            return ;
          }
          b = a;
          a = c;
        }
        if (orie.orientation_greater(n1o, n2o)==-1 && orie.orientation_greater(u1o, u2o)==1) {
          if (ptA.n1 == b) {
            c = ptA.u1;
          } else  if (ptA.u2 == b) {
            c = ptA.n2;
          } else {
            println("draw_smoothing_region 3: error", ptA.n1, ptA.u2, ptA.u1, ptA.n2, b);
            return ;
          }
          b = a;
          a = c;
        }
        if (orie.orientation_greater(n1o, n2o)==1 && orie.orientation_greater(u1o, u2o)==-1) {
          if (ptA.n2 == b) {
            c = ptA.u2;
          } else if (ptA.u1 == b) {
            c = ptA.n1;
          } else {
            println("draw_smoothing_region 4: error", ptA.n2, ptA.u1, ptA.n1, ptA.u2, b);
            return ;
          }
          b = a;
          a = c;
        }
        if (orie.orientation_greater(n1o, n2o)==1 && orie.orientation_greater(u1o, u2o)==1 ) {
          if (ptA.n2 == b) {
            c = ptA.u1;
          } else if (ptA.u2 == b) {
            c = ptA.n1;
          } else {
            println("draw_smoothing_region 5: error", ptA.n2, ptA.u2, ptA.n1, ptA.u1, b);
            return ;
          }
          b = a;
          a = c;
        }
        //vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
      }
      ptA = getBead(a);
      if (ptA==null) {
        break;
      }
      if (start_a == a) {
        break;
      }
    }
    endShape();
  }

  float segmentIsInRight(float mX, float mY, float x0, float y0, float x1, float y1) {
    if (mX < x0 || mX< x1) {
      if ( y0 < y1 && mY >= y0 && mY < y1) {
        float xx = x0 + (mY - y0)*(x1-x0)/(y1-y0);
        if (xx>mX) {
          return xx;
        }
      } else if ( y1 <= y0 && mY >= y1 && mY < y0) {
        float xx = x0 + (mY - y0)*(x1-x0)/(y1-y0);
        if (xx>mX) {
          return xx;
        }
      }
    }
    return mX-1f;
  }

  Nbhd get_near_nbhd(float mX, float mY) {//（マウスポジションの真右にあって）マウスの位置に近いNbhdを見つける。
    int a=-1, b=-1;
    float maxX=9999f;
    for (int p = 0; p<points.size (); p++) {
      Bead bead = getBead(p);
      if (bead==null) {
        continue;
      }
      float x0 = disp.get_winX(bead.x);
      float y0 = disp.get_winY(bead.y);
      //if (bead.Joint) {
      //} else {
      int n1 = bead.n1;// n2, u1, u2についても同じことをする。
      //if (n1 != -1) {
      Bead bead1 = getBead(n1);
      if (bead1 == null) {
        continue;
      }
      float x1 = disp.get_winX(bead1.x);
      float y1 = disp.get_winY(bead1.y);
      float xx = segmentIsInRight(mX, mY, x0, y0, x1, y1);
      if (mX < xx && xx < maxX) {
        maxX = xx;
        a = n1;
        b = p;
      }
      //}
      int n2 = bead.n2;// n2, u1, u2についても同じことをする。
      //if (n2 != -1) {
      Bead bead2 = getBead(n2);
      if (bead2 == null) {
        continue;
      }
      float x2 = disp.get_winX(bead2.x);
      float y2 = disp.get_winY(bead2.y);
      float xx2 = segmentIsInRight(mX, mY, x0, y0, x2, y2);
      if (xx2>mX && xx2<maxX) {
        maxX = xx2;
        a = n2;
        b = p;
      }
      //}
      int u1 = bead.u1;// n2, u1, u2についても同じことをする。
      //if (u1 != -1) {
      Bead bead3 = getBead(u1);
      if (bead3 == null) {
        continue;
      }
      float x3 = disp.get_winX(bead3.x);
      float y3 = disp.get_winY(bead3.y);
      float xx3 = segmentIsInRight(mX, mY, x0, y0, x3, y3);
      if (xx3>mX && xx3<maxX) {
        maxX = xx3;
        a = u1;
        b = p;
      }
      //}
      int u2 = bead.u2;// n2, u1, u2についても同じことをする。
      //if (u2 != -1) {
      Bead bead4 = getBead(u2);
      if (bead4 == null) {
        continue;
      }
      float x4 = disp.get_winX(bead4.x);
      float y4 = disp.get_winY(bead4.y);
      float xx4 = segmentIsInRight(mX, mY, x0, y0, x4, y4);
      if (xx4>mX && xx4<maxX) {
        maxX = xx4;
        a = u2;
        b = p;
      }
      //}
      //}
    }
    if (a==-1 && b==-1) {
      return null;
    } else {
      return new Nbhd(b, a);
    }
  }

  int findArcFromPoints(int startID, int endID) {
    //引数はpointのID
    Bead st = getBead(startID);
    if (st==null) {
      return -1;
    }
    //Bead en = getBead(endID);
    int a=st.n1;
    int b=st.n2;
    Bead node1=st;
    Bead node2=st;
    int prev_a=startID;
    int prev_b=startID;
    int pre_prev_a=startID;
    int pre_prev_b=startID;
    int repeatmax = points.size();
    boolean J1_over=false;
    boolean J1_under=false;
    boolean J2_over=false;
    boolean J2_under=false;
    int counta=0;
    int countb=0;
    int self_crossing_a=0;
    int self_crossing2_a=0;
    int self_crossing_b=0;
    int self_crossing2_b=0;
    for (int repeat=0; repeat < repeatmax; repeat++) {
      //startIDのビーズから初めてn1方向とn2方向の両方を調べる
      // go straight

      pre_prev_a=prev_a;
      pre_prev_b=prev_b;
      prev_a=a;
      prev_b=b;

      if (a==endID) {
        //println("self_crossing="+self_crossing, "self_crossing2="+self_crossing2);
        if (J1_over&&J1_under) {
          if (self_crossing_a==self_crossing2_a) {
            println("フリーループです");
            count_for_distinguishing_edge=counta;
            return 1;
          } else {
            ///////////////////////ここでライデⅠをしたあとにできたループなのかを判断する
            return -1;
          }
        } else {
          count_for_distinguishing_edge=counta;
          return 1;
        }
      } else if (b==endID) {
        if ((J2_over&&J2_under)) {
          if ( self_crossing_b==self_crossing2_b) {
            println("フリーループです");
            count_for_distinguishing_edge=countb;
            return 2;
          } else {
            //////////////////////////ここでライデⅠをしたあとにできたループなのかを判断する
            return -1;
          }
        } else {
          count_for_distinguishing_edge=countb;
          return 2;
        }
      } else {//aもbもendIDでないとき
        ////////////////////////////////////////この辺でエラーが出やすい
        //aが-1になるとエラーがでる
        if (node1!= null) {
          node1=getBead(a);/////////////////////////何が怒っているのか
          counta++;
        }
        if (node2!=null) {
          node2=getBead(b);
          countb++;
        }
      }

      if (node1 != null ) {
        if (node1.Joint) {
          if (node1.n1==pre_prev_a) {
            a=node1.n2;
            J1_over=true;
            self_crossing_a=prev_a;
            println("self_crossing_a="+self_crossing_a);
          } else if (node1.n2==pre_prev_a) {
            a=node1.n1;
            J1_over=true;
            self_crossing_a=prev_a;
            println("self_crossing_a="+self_crossing_a);
          } else if (node1.u1==pre_prev_a) {
            a=node1.u2;
            J1_under=true;
            self_crossing2_a=prev_a;
            println("self_crossing2_a="+self_crossing2_a);
          } else if (node1.u2==pre_prev_a) {
            a=node1.u1;
            J1_under=true;
            self_crossing2_a=prev_a;
            println("self_crossing2_a="+self_crossing2_a);
          }
        } else {
          a=node1.n1;
          if (pre_prev_a==a) {
            a=node1.n2;
          }
        }
      }
      if (node2 != null) {
        if (node2.Joint) {
          if (node2.n1==pre_prev_b) {
            b=node2.n2;
            J2_over=true;
            self_crossing_b=prev_b;
            println("self_crossing_b="+self_crossing_b);
          } else if (node2.n2==pre_prev_b) {
            b=node2.n1;
            J2_over=true;
            self_crossing_b=prev_b;
            println("self_crossing_b="+self_crossing_b);
          } else if (node2.u1==pre_prev_b) {
            b=node2.u2;
            J2_under=true;
            self_crossing2_b=prev_b;
            println("self_crossing2_b="+self_crossing2_b);
          } else if (node2.u2==pre_prev_b) {
            b=node2.u1;
            J2_under=true;
            self_crossing2_b=prev_b;
            println("self_crossing2_b="+self_crossing2_b);
          }
        } else {
          b=node2.n2;
          if (pre_prev_b==b) {
            b=node2.n1;
          }
        }
      }
      // if on joint, n1->n2, u1->u2, n2->n1, u2->u1
      //Jointだったときに何かしらの処理をすることで自己交差をしているか判定

      // println("pre_prev_a="+pre_prev_a, "prev_a="+prev_a, "a="+a, "pre_prev_b="+pre_prev_b, "prev_b="+prev_b, "b="+b);
    }
    //startIDのビーズから初めてn1方向とn2方向の両方を調べる
    //自己交差があればやめる
    //両方ダメなら-1を返す
    //成功すればn1は1、n2は2を返す
    //両方成功したら1を返す
    //たどる途中でovercrossingとundercrossingが混ざったらやめる
    //たどっているときにoverなのかunderなのかを保存しておく必要がある
    return -1;
  }


  void extinguish_points(int i, int count, int startID, int endID) {
    //    n1=-1,n2=-1,u1=-1,u2=-1にする
    int j=0;
    Bead st = getBead(startID);
    if (st==null) {
      return ;
    }
    int a=st.n1;
    int b=st.n2;
    Bead node1=st;
    Bead node2=st;
    int prev_a=startID;
    int prev_b=startID;
    int pre_prev_a=startID;
    int pre_prev_b=startID;
    int repeatmax = points.size();

    between_beads=new int[count];

    for (int repeat=0; repeat < repeatmax; repeat++) {
      //startIDのビーズから初めてn1方向とn2方向の両方を調べる
      // go straight

      pre_prev_a=prev_a;
      pre_prev_b=prev_b;
      prev_a=a;
      prev_b=b;

      if (i==1) {
        if (a==endID) {
          pre_endID=pre_prev_a;
          return;
        } else {
          if (node1 != null) {
            node1=getBead(a);
          }
        }
        if (node1 != null) {
          if (node1.Joint) {
            if (node1.n1==pre_prev_a) {
              a=node1.n2;
            } else if (node1.n2==pre_prev_a) {
              a=node1.n1;
            } else if (node1.u1==pre_prev_a) {
              a=node1.u2;
            } else if (node1.u2==pre_prev_a) {
              a=node1.u1;
            }
          } else {
            a=node1.n1;
            if (pre_prev_a==a) {
              a=node1.n2;
            }
          }
          between_beads[j]=prev_a;
          j=j+1;
        }
        //if (j==count-1) {
        //  return;
        //}
      } else if (i==2) {
        if (b==endID) {
          pre_endID=pre_prev_b;
          return;
        } else {
          if (node2 != null) {
            node2=getBead(b);
          }
        }
        if (node2 != null) {
          if (node2.Joint) {
            if (node2.n1==pre_prev_b) {
              b=node2.n2;
            } else if (node2.n2==pre_prev_b) {
              b=node2.n1;
            } else if (node2.u1==pre_prev_b) {
              b=node2.u2;
            } else if (node2.u2==pre_prev_b) {
              b=node2.u1;
            }
          } else {
            b=node2.n2;
            if (pre_prev_b==b) {
              b=node2.n1;
            }
          }  
          between_beads[j]=prev_b;
          j=j+1;
        }
        //if (j==count-1) {
        //  return;
        //}
      }
    }
  }

  void extinguish(int count) {//between_beadsの情報をもとにbeadsを消す
    for (int ii=0; ii<count; ii++) {
      println("between_beads["+ii+"]"+data.between_beads[ii]);
      int a=between_beads[ii];
      Bead pt=getBead(a);
      if (pt!=null) {
        if (pt.Joint) {
          if (ii>0) {
            int pre_a=between_beads[ii-1];
            if (pt.u1==pre_a||pt.u2==pre_a) {//undercrossingだったら
              pt.u1=-1;
              pt.u2=-1;
              pt.Joint=false;
              pt.c=2;
              over_crossing=false;
              println("通過したJointはUnderCrossingでした");
            } else {//overcrossingだったら
              pt.n1=pt.u1;
              pt.n2=pt.u2;
              pt.Joint=false;
              pt.c=2;
              over_crossing=true;
              println("通過したJointはOverCrossingでした");
            }
          } else {
            return;
          }
        } else {
          removeBeadFromPoint(a);
        }
      }
    }
  }

  void extinguish_startID_and_endID(int i, int startID, int endID) {
    Bead bds=data.getBead(startID);
    Bead bde=data.getBead(endID);
    if (bds==null || bde==null) {
      return;
    }
    bds.c=1;
    bde.c=1;
    if (i==1) {
      bds.n1=bds.n2;
      bds.n2=-1;
      //bds.c=1;
      if (bde.n2==pre_endID) {
        bde.n2=-1;
      } else {
        bde.n1=bde.n2;
        bde.n2=-1;
      }
    } else if (i==2) {
      bds.n2=-1;
      //bds.c=1;
      if (bde.n2==pre_endID) {
        bde.n2=-1;
      } else {
        bde.n1=bde.n2;
        bde.n2=-1;
      }
    }
  }


  boolean next_to_undercrossing(int ptID) {
    if (0> ptID || ptID>=points.size()) {
      return false;
    }
    Bead bd = getBead(ptID);
    if (bd != null) {
      int pt1ID = bd.n1;
      if (0<=pt1ID && pt1ID<points.size()) {
        Bead bd1 = getBead(pt1ID);
        if (bd1!=null && bd1.Joint && (bd1.u1==ptID || bd1.u2==ptID) ) {
          return true;
        }
      }
      int pt2ID = bd.n2;
      if (0<=pt2ID && pt2ID<points.size()) {
        Bead bd2 = getBead(pt2ID);
        if (bd2!=null && bd2.Joint  && (bd2.u1==ptID || bd2.u2==ptID)) {
          return true;
        }
      }
    }
    return false;
  }

  void debugLogPoints(String filename) {
    PrintWriter file; 
    file = createWriter(filename);
    file.println("ID,X,Y,c,n1,n2,u1,u2,inUse,Joint,midJoint");
    for (int ptID=0; ptID<points.size(); ptID++) {
      Bead pt = points.get(ptID);
      if (pt==null) {
        file.println("null");
      } else {
        file.print(ptID+",");
        file.print(pt.x+","+pt.y+",");
        file.print(pt.c+",");
        file.print(pt.n1+",");
        file.print(pt.n2+",");
        file.print(pt.u1+",");
        file.print(pt.u2+",");
        file.print(pt.inUse+",");
        file.print(pt.Joint+",");
        file.print(pt.midJoint);
      }
      file.println();
    }
    file.flush();
    file.close();
  }

  void rotatePoints(float theta) {
    for (int p=0; p<points.size(); p++) {
      Bead pp = points.get(p);
      float x0 = pp.x - width/2;
      float y0 = pp.y - height/2;
      float x = cos(theta) * x0 - sin(theta) * y0; 
      float y = sin(theta) * x0 + cos(theta) * y0;
      pp.x = x + width/2;
      pp.y = y + height/2;
    }
  }
  int getNextBead(int aID, int bID) {
    Bead b=getBead(bID);
    if (b==null) {
      return -1;
    } else {
      if (b.n1==aID) {
        return b.n2;
      } else if (b.n2==aID) {
        return b.n1;
      } else {
        return -1;
      }
    }
  }
  pairInt condition_bandJoint(int startID, int endID) {
    ///bandJointにする条件に必要な関数
    //startIDとendIDについて両方向n1n2調べる
    //midJointは無視
    //bandJointだとNGなので-1を返す
    //Jointのときに番号を返す
    //共通のJointの番号があればそれを返す
    Bead startBead=getBead(startID);
    if (startBead==null) {
      return new pairInt(-1);
    }
    int s1=findJoint_for_bandJoint(startID, startBead.n1);
    int s2=findJoint_for_bandJoint(startID, startBead.n2);
    Bead endBead=getBead(endID);
    if (endBead==null) {
      return new pairInt(-1);
    }
    int e1=findJoint_for_bandJoint(endID, endBead.n1);
    int e2=findJoint_for_bandJoint(endID, endBead.n2);
    if (s1!=-1&&(s1==e1)) {
      return new pairInt(s1, 1, 1);
    }
    if (s1!=-1&&(s1==e2)) {
      return new pairInt(s1, 1, 2);
    }
    if (s2!=-1&&(s2==e1)) {
      return new pairInt(s2, 2, 1);
    }
    if (s2!=-1&&(s2==e2)) {
      return new pairInt(s2, 2, 2);
    }
    return new pairInt(-1);
  }

  int findJoint_for_bandJoint(int p, int c) {
    int pID=p;
    int cID=c;
    int nID=-1;
    for (int repeat=0; repeat<points.size(); repeat++) {
      nID=getNextBead(pID, cID);
      if (nID==-1) {
        return -1;
      }
      Bead n=getBead(nID);
      if (n==null) {
        return -1;
      } else if (n.bandJoint) {
        return -1;
      } else if (n.Joint) {
        return nID;
      } else {
        pID=cID;
        cID=nID;
      }
    }
    return -1;
  }
}