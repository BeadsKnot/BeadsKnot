class data_extract {

  int w, h;// 解析画面の大きさ
  int d[][];// ２値化された画像のデータ
  int s;//解析メッシュのサイズ
  display disp;
  boolean extraction_binalized;
  boolean extraction_beads;
  boolean extraction_complete;
  boolean data_graph_complete;

  ArrayList<Nbh> nbhs=new ArrayList<Nbh>();//線を登録
  ArrayList<Beads> points=new ArrayList<Beads>();//点を登録
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
    extraction_binalized = false;
    extraction_complete = false;
    extraction_beads = false;
    data_graph_complete=false;
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

  //TODO メソッドをabc順に並べるかどうか，検討する。

  int addToPoints(int u, int v, int threshold) {//点を追加する
    // (u,v)は点の座標なので，float型ではないか？
    for (int i=0; i<points.size (); i++) {
      if (dist(u, v, points.get(i).x, points.get(i).y ) < threshold-1) {//近くに既存の点がある場合には追加しない
        return i;
      }
    }
    points.add(new Beads(u, v));
    return points.size()-1;
  }

  void drawPoints() {//点をかく
    stroke(255, 0, 0);
    for (int i=0; i<points.size (); i++) {
      Beads vec=points.get(i);
      if (vec.Joint) {
        stroke(0, 0, 255);
      } else if (vec.closeJoint) {
        stroke(0, 255, 0);
      } else if (vec.midJoint) {
        stroke(255, 255, 0);
      } else {
        stroke(255, 0, 0);
      }
      if (vec.c<=0||vec.c>=4) {
      } else {
        //dispをつかって表示を画面サイズに合わせるように座標変換する。
        ellipse(disp.get_winX(vec.x), disp.get_winY(vec.y), vec.c*3+1, vec.c*3+1);//vec.cは1or2or3のはず
      }
    }
  }

  int addToNbhs(int nn, int mm) {//線を追加する
    if (nn!=mm && connected(nn, mm)==1) {
      nbhs.add(new Nbh(nn, mm));
    }
    return 1;
  }

  int connected(int nn, int mm) {//線がつながっているかチェックする
    // nn,mmはpointsのなかの番号
    if ( duplicateNbhs(nn, mm)==1) {//重複したら
      return 0;
    }
    if (nn==mm) {
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

  //TODO disp を使って画像を画面に収めるように変数変換する。
  void drawNbhs() {//線を書く
    for (int i=0; i<points.size (); i++) {
      Beads vec=points.get(i);
      if (vec.n1!=-1) {
        stroke(255, 0, 0);
        try { 
          if (!points.get(vec.n1).Joint) {
            line(disp.get_winX(vec.x), disp.get_winY(vec.y), disp.get_winX(points.get(vec.n1).x), disp.get_winY(points.get(vec.n1).y));//エラーがでる
          }
        }
        catch (IndexOutOfBoundsException e) {
        }
      }
      if (vec.n2!=-1) {
        stroke(255, 0, 0);
        try { 
          if (!points.get(vec.n2).Joint) {
            line(disp.get_winX(vec.x), disp.get_winY(vec.y), disp.get_winX(points.get(vec.n2).x), disp.get_winY(points.get(vec.n2).y));//エラーがでる
          }
          /* process */
        } 
        catch (IndexOutOfBoundsException e) {
        }
      }
      // if (vec.u1!=-1) {
      //stroke(0, 255, 0);
      //line(vec.x, vec.y, points.get(vec.u1).x, points.get(vec.u1).y);//エラーがでる
      //}
      //if (vec.u2!=-1) {
      //stroke(255, 255, 0);
      //line(vec.x, vec.y, points.get(vec.u2).x, points.get(vec.u2).y);
      //}
    }
  }

  void countNbhs() {//線を数える
    for (Beads vec : points) {
      vec.c=0;
      vec.n1=vec.n2=vec.u1=vec.u2=-1;//正常でない値
    }
    for (Nbh n : nbhs) {
      // points.get(n.a).c++;
      //points.get(n.b).c++;
      Beads vec_1=points.get(n.a);
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
      Beads vec_2=points.get(n.b);
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
      Beads pt=points.get(u);
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

  void addJointToNbhs() {//jointに関しての線を追加
    for (int u=0; u<points.size (); u++) {
      Beads vec=points.get(u);
      if (vec.Joint) {
        if (duplicateNbhs(u, vec.u1)==0) {
          nbhs.add(new Nbh(u, vec.u1));
        }
        if (duplicateNbhs(u, vec.u2)==0) {
          nbhs.add(new Nbh(u, vec.u2));
        }
        // addToNbhs(u, vec.u1);
        //addToNbhs(u, vec.u2);
        // println(u, vec.u1);
      }
    }
  }

  int duplicateNbhs(int nn, int mm) {//線が重複しているかどうかを調べる
    for (Nbh n : nbhs) {
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
    for (int i=nbhs.size ()-1; i>=0; i--) {
      Nbh n=nbhs.get(i);
      if (n.a==u||n.b==u) {
        nbhs.remove(i);
      }
    }
    for (int i=nbhs.size ()-1; i>=0; i--) {
      Nbh n=nbhs.get(i);
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
      Beads vec_po=points.get(i);
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
        for (int i=nbhs.size ()-1; i>=0; i--) {
          Nbh n=nbhs.get(i);
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
          addToNbhs(u, num);
          //なにかする//TODO 「なにかする」という古いメッセージの意味を考える。
          points.get(num).c++;
          points.get(u).c++;
        } else if (points.get(num).c==0) {//最小の距離の点が孤立
          addToNbhs(u, num);
          points.get(num).c++;
          points.get(u).c++;
        }
      }
    }
  }
  /*
  void get_nbh() {//となりの隣の内容をgetする
   //for (Nbh n : nbhs) {
   for (int i=0; i<nbhs.size (); i++) {
   Nbh n=nbhs.get(i);
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
    for (Beads vec : points) {
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
}