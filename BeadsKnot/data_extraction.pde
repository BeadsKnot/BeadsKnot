class data_extract {
  // 画像からの読みとり
  // ビーズとそれをつなぐNbhからなる。
  int w, h;// 解析画面の大きさ
  int d[][];// ２値化された画像のデータ
  int s;//解析メッシュのサイズ
  display disp;

  ArrayList<Nbhd> nbhds=new ArrayList<Nbhd>();//線を登録
  ArrayList<Bead> points=new ArrayList<Bead>();//点を登録
  transform tf;
  Binarization bin;
  Square sq;
  Thinning th;

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

  // imageデータの解析
  void make_data_extraction(PImage image) {
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

    sq.getSquareExtraction();//正方形分割をするときにコメントアウトをはずす
    //th.getThinningExtraction();//thinning ver.にするときにコメントアウトをはずす
  }

  int addToPoints(int u, int v, int threshold) {//点を追加する
    // (u,v)は点の座標なので，float型ではないか？
    for (int pt=0; pt<points.size (); pt++) {
      if (dist(u, v, points.get(pt).x, points.get(pt).y ) < threshold-1) {//近くに既存の点がある場合には追加しない
        return pt;
      }
    }
    points.add(new Bead(u, v));
    return points.size()-1;
  }

  void drawPoints() {//点をかく
    for (int pt=0; pt<points.size (); pt++) {
      float c = 2;
      Bead vec=points.get(pt);
      if (vec.Joint) {
        stroke(0);
        fill(80, 255, 80);
        c=4;
      } else if (vec.closeJoint) {
        stroke(0, 255, 0);
        fill(255);
      } else if (vec.midJoint) {
        stroke(0);
        fill(180, 255, 0);
        c=3;
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      if (vec.c<=0 || vec.c>=4 || vec.n1==-1 || vec.n2==-1) {
      } else {
        //dispをつかって表示を画面サイズに合わせるように座標変換する。
        ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), c*3+1, c*3+1);
        if (dist(mouseX, mouseY, disp.get_winX(vec.x), disp.get_winY(vec.y)) < 10 ) {
          fill(0);
          //text(pt, disp.get_winX(vec.x), disp.get_winY(vec.y));
          text(vec.orientation, disp.get_winX(vec.x), disp.get_winY(vec.y)); 
          //if(vec.Joint){
          //  println("n1 = "+vec.n1+":u1 = "+vec.u1+":n2 = "+vec.n2+":u2 = "+vec.u2);
        }//}
      }
    }
  }

  void draw_smoothing_Points() {//点をかく
    for (int pt=0; pt<points.size (); pt++) {
      float c = 2;
      Bead vec=points.get(pt);
      if (vec.Joint) {
        stroke(0);
        fill(80, 255, 80);
        c=0;
      } else if (vec.closeJoint) {
        stroke(0, 255, 0);
        fill(255);
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
          //text(pt, disp.get_winX(vec.x), disp.get_winY(vec.y));
          text(vec.orientation, disp.get_winX(vec.x), disp.get_winY(vec.y)); 
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
    float xa=points.get(nn).x;
    float ya=points.get(nn).y;
    float xb=points.get(mm).x;
    float yb=points.get(mm).y;
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
      Bead pt=points.get(ptID);
      if (0<=pt.n1 && pt.n1<points.size()) {
        stroke(0);
        Bead pt2 = points.get(pt.n1);
        if (! pt2.Joint) {
          line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
            disp.get_winX(pt2.x), disp.get_winY(pt2.y));
        }
      }
      if (0<=pt.n2 && pt.n2<points.size()) {
        stroke(0);
        Bead pt2 = points.get(pt.n2);
        if (! pt2.Joint) {
          line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
            disp.get_winX(pt2.x), disp.get_winY(pt2.y));
        }
      }
    }
  }

  void draw_smoothing_Nbhds() {//Jointの周りだけつなげ方を変える//jointも消す
    for (int ptID=0; ptID<points.size (); ptID++) {
      Bead pt=points.get(ptID);
      if (pt.Joint) {
        int n1=pt.n1;
        int n2=pt.n2;
        int u1=pt.u1;
        int u2=pt.u2;
        if (points.get(n1).orientation<points.get(n2).orientation) {
          if (points.get(u1).orientation<points.get(u2).orientation) {
            Bead pt1=points.get(n1);
            Bead pt2=points.get(u2);
            line(disp.get_winX(pt1.x), disp.get_winY(pt1.y), disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
      } else {
        if (0<=pt.n1 && pt.n1<points.size()) {
          stroke(0);
          Bead pt2 = points.get(pt.n1);
          if (! pt2.Joint) {
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
        if (0<=pt.n2 && pt.n2<points.size()) {
          stroke(0);
          Bead pt2 = points.get(pt.n2);
          if (! pt2.Joint) {
            line(disp.get_winX(pt.x), disp.get_winY(pt.y), 
              disp.get_winX(pt2.x), disp.get_winY(pt2.y));
          }
        }
      }
    }
  }

  void countNbhds() {//線を数える
    for (Bead vec : points) {
      vec.c=0;
      vec.n1=vec.n2=vec.u1=vec.u2=-1;//正常でない値
    }
    for (Nbhd n : nbhds) {
      // points.get(n.a).c++;
      //points.get(n.b).c++;
      Bead vec_1=points.get(n.a);
      if (vec_1.c==0) {
        vec_1.n1=n.b;
      } else if (vec_1.c==1) {
        vec_1.n2=n.b;
      } else if (vec_1.c==2) {
        vec_1.u1=n.b;
      } else if (vec_1.c==3) {
        vec_1.u2=n.b;
      }
      vec_1.c++;
      Bead vec_2=points.get(n.b);
      if (vec_2.c==0) {
        vec_2.n1=n.a;
      } else if (vec_2.c==1) {
        vec_2.n2=n.a;
      } else if (vec_2.c==2) {
        vec_2.u1=n.a;
      } else if (vec_2.c==3) {
        vec_2.u2=n.a;
      }
      vec_2.c++;
    }
  }


  void getDisplayLTRB() {
    float l, t, r, b;
    l=t=r=b=0;
    for (int u=0; u<points.size (); u++) {
      Bead pt=points.get(u);
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
    disp.left=l;
    disp.right=r;
    disp.top=t;
    disp.bottom=b;
    disp.set_rate();
  }

  void addJointToNbhds() {//jointに関しての線を追加
    for (int u=0; u<points.size (); u++) {
      Bead vec=points.get(u);
      if (vec.Joint) {
        if (duplicateNbhds(u, vec.u1)==0) {
          nbhds.add(new Nbhd(u, vec.u1));
        }
        if (duplicateNbhds(u, vec.u2)==0) {
          nbhds.add(new Nbhd(u, vec.u2));
        }
        // addToNbhs(u, vec.u1);
        //addToNbhs(u, vec.u2);
        // println(u, vec.u1);
      }
    }
  }

  int duplicateNbhds(int nn, int mm) {//線が重複しているかどうかを調べる
    for (Nbhd n : nbhds) {
      if (nn==n.a&&mm==n.b) {
        return 1;
      }
      if (nn==n.b&&mm==n.a) {
        return 1;
      }
    }
    return 0;
  }

  void removePoint(int u) {//点を消す
    points.remove(u);
    for (int i=nbhds.size ()-1; i>=0; i--) {
      Nbhd n=nbhds.get(i);
      if (n.a==u||n.b==u) {
        nbhds.remove(i);
      }
    }
    for (int i=nbhds.size ()-1; i>=0; i--) {
      Nbhd n=nbhds.get(i);
      if (n.a>u) {
        n.a--;
      }
      if (n.b>u) {
        n.b--;
      }
    }
  }

  void removePoint2(int u) {
    for (int i=0; i<points.size (); i++) {
      Bead vec_po=points.get(i);
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
      if ( points.get(u).c==1) {
        for (int i=nbhds.size ()-1; i>=0; i--) {
          Nbhd n=nbhds.get(i);
          if (n.a==u) {
            if (points.get(n.b).c==3) {
              removePoint(u);
              removePoint2(u);
              points.get(n.b).c=2;
            }
          } else if (n.b==u) {
            if (points.get(n.a).c==3) {
              removePoint(u);
              removePoint2(u);
              points.get(n.a).c=2;
            }
          }
        }
      }
    }
  }

  void fillGap() {//点と点の距離の最小を記録し、最小の距離の点が1本さんならばその点と点をつなげる
    for (int u=0; u<points.size (); u++) {
      if ( points.get(u).c==1) {// まず「自分」がおひとりさまの場合のみ調べる
        float min=w;//大きな値から始める。
        int num=-1;//最小の距離の点の番号を記録するための変数
        for (int v=0; v<points.size (); v++) {
          if (u!=v) {
            if (points.get(u).n1!=v) {//おひとりさまの相手は近くにいるに決まっているので探索対象から除外
              float d=dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
              if (min>d) {
                min=d;
                num=v;
              }
            }
          }
        }
        if (points.get(num).c==1) {//最小の距離の点がおひとりさま
          addToNbhds(u, num);
          //なにかする//TODO 「なにかする」という古いメッセージの意味を考える。
          points.get(num).c++;
          points.get(u).c++;
        } else if (points.get(num).c==0) {//最小の距離の点が孤立
          addToNbhds(u, num);
          points.get(num).c++;
          points.get(u).c++;
        }
      }
    }
  }
  /*
  void get_nbhd() {//となりの隣の内容をgetする
   //for (Nbhd n : nbhds) {
   for (int i=0; i<nbhds.size (); i++) {
   Nbh n=nbhds.get(i);
   if (n.a!=n.b) {
   if (points.get(n.a).n1==-1) {
   points.get(n.a).n1=n.b;
   } else {
   points.get(n.a).n2=n.b;
   }
   if (points.get(n.b).n1==-1) {
   points.get(n.b).n1=n.a;
   } else {
   points.get(n.b).n2=n.a;
   }
   }
   }
   }
   */

  void FindJoint() {//jointを探す
    for (int u=0; u<points.size (); u++) {
      if ( points.get(u).c==1) {
        float min=w;
        int num=0;
        for (int v=0; v<points.size (); v++) {
          if (u!=v) {
            int pgu1=points.get(u).n1;
            // println(pgu1);
            if (v!=pgu1) {
              //print("pgu1="+pgu1);
              if (pgu1!=-1&&v!=points.get(pgu1).n1&&v!=points.get(pgu1).n2) {
                float d=dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
                if (min>d) {
                  min=d;
                  num=v;
                }
              }
            }
          }
        }
        if (points.get(num).c==2) {
          points.get(num).Joint=true;

          if (points.get(num).u1==-1) {
            points.get(num).u1=u;
          } else {
            points.get(num).u2=u;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          }
          int pgn1=points.get(num).n1;
          int pgn2=points.get(num).n2;
          if (pgn1!=-1&&points.get(pgn1).Joint) {//隣だったとき
            points.get(pgn1).Joint=false;
            points.get(num).u2=points.get(pgn1).u1;
            points.get(pgn1).u1=-1;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          } else if (pgn2!=-1&&points.get(pgn2).Joint) {
            points.get(pgn2).Joint=false;
            points.get(num).u2=points.get(pgn2).u1;
            points.get(pgn2).u1=-1;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          }
          //隣の隣
          if (pgn1!=-1&&pgn2!=-1) {
            int pgn1_1=points.get(pgn1).n1;
            int pgn1_2=points.get(pgn1).n2;
            int pgn2_1=points.get(pgn2).n1;
            int pgn2_2=points.get(pgn2).n2;
            if (num!=pgn1_1&&points.get(pgn1_1).Joint) {
              points.get(pgn1_1).Joint=false;
              points.get(pgn1).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn1).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn1).u2=points.get(pgn1_1).u1;
              points.get(pgn1_1).u1=-1;
              points.get(points.get(pgn1).u1).n2=pgn1;
              points.get(points.get(pgn1).u2).n2=pgn1;
              points.get(points.get(pgn1).u1).c++;
              points.get(points.get(pgn1).u2).c++;
            } else if (pgn1_2!=-1&&num!=pgn1_2&&points.get(pgn1_2).Joint) {
              points.get(pgn1_2).Joint=false;
              points.get(pgn1).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn1).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn1).u2=points.get(pgn1_2).u1;
              points.get(pgn1_2).u1=-1;
              points.get(points.get(pgn1).u1).n2=pgn1;
              points.get(points.get(pgn1).u2).n2=pgn1;
              points.get(points.get(pgn1).u1).c++;
              points.get(points.get(pgn1).u2).c++;
            } else  if (num!=pgn2_1&&points.get(pgn2_1).Joint) {
              points.get(pgn2_1).Joint=false;
              points.get(pgn2).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn2).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn2).u2=points.get(pgn2_1).u1;
              points.get(pgn2_1).u1=-1;
              points.get(points.get(pgn2).u1).n2=pgn2;
              points.get(points.get(pgn2).u2).n2=pgn2; 
              points.get(points.get(pgn2).u1).c++;
              points.get(points.get(pgn2).u2).c++;
            } else if (pgn2_2!=-1&&num!=pgn2_2&&points.get(pgn2_2).Joint) {
              points.get(pgn2_2).Joint=false;
              points.get(pgn2).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn2).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn2).u2=points.get(pgn2_2).u1;
              points.get(pgn2_2).u1=-1;
              if (points.get(pgn2).u1!=-1&&points.get(pgn2).u2!=-1) {
                points.get(points.get(pgn2).u1).n2=pgn2;
                points.get(points.get(pgn2).u2).n2=pgn2;
                points.get(points.get(pgn2).u1).c++;
                points.get(points.get(pgn2).u2).c++;
              }
            }
          }
        }
      }
    }
  }
  boolean Ofutarisama() {//みんなお二人様だったか確認
    for (Bead vec : points) {
      if (vec.c!=2) {
        return false;
      }
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
    for (int count = 0; count < points.size(); count++) {
      Bead p=points.get(c);
      if (p.Joint || p.midJoint) {
        return new Nbhd(j, c);
      }
      int d=0;
      if (p.n1==j) {
        d=p.n2;
      } else if (p.n2==j) {
        d=p.n1;
      } else {
        println("find_Joint_midJoint : 間違っている");
        return new Nbhd(0, 0);
      }
      j = c;
      c = d;
    }
    return new Nbhd(0, 0);
  }

  Nbhd turn_left(Nbhd nbhd) {
    Bead p=points.get(nbhd.b);
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
    int repeatmax = points.size();
    Bead ptA = points.get(a);
    fill(120, 120, 255);
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
          c = ptA.n1;
        } else {
          println("draw_region : error");
          return ;
        }
        b = a;
        a = c;
      }
      ptA = points.get(a);
      vertex(disp.get_winX(ptA.x), disp.get_winY(ptA.y));
      if (nbhd.a == a) {

        break;
      }
    }
    endShape(CLOSE);
  }

  Nbhd get_near_nbhd() {//（マウスポジションの真右にあって）マウスの位置に近いNbhdを見つける。
    int a=-1, b=-1;
    float maxX=9999f;
    for (int p = 0; p<points.size(); p++) {
      Bead bead = points.get(p);
      float x0 = disp.get_winX(bead.x);
      float y0 = disp.get_winY(bead.y);
      if (bead.Joint) {
      } else {
        int n1 = bead.n1;// n2, u1, u2についても同じことをする。
        Bead bead1 = points.get(n1);
        float x1 = disp.get_winX(bead1.x);
        float y1 = disp.get_winY(bead1.y);
        if (mouseX < x0 || mouseX< x1) {
          if ( y0 < y1 && mouseY > y0-0.1 && mouseY < y1+0.1) {
            float xx = x0 + (mouseY - y0)*(x1-x0)/(y1-y0);
            if (xx>mouseX && xx<maxX) {
              maxX = xx;
              a = n1;
              b = p;
            }
          } else if ( y1 < y0 && mouseY > y1-0.1 && mouseY < y0+0.1) {
            float xx = x0 + (mouseY - y0)*(x1-x0)/(y1-y0);
            if (xx>mouseX && xx<maxX) {
              maxX = xx;
              a = p;
              b = n1;
            }
          }
        }
      }
    }
    return new Nbhd(a, b);
  }
}