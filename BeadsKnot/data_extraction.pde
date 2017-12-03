class data_extract {

  int w , h;// 解析画面の大きさ
  int d[][];// 画像の2値化データ
  int s;//解析メッシュのサイズ
  display disp;

  ArrayList<Nbh> nbhs=new ArrayList<Nbh>();//線を登録
  ArrayList<Beads> points=new ArrayList<Beads>();//点を登録
  transform tf;

  //コンストラクタ
  data_extract(int _h, int _w, PImage _img,display _disp) {
    w = _w;
    h = _h;
    tf=new transform(this);
    disp = _disp;
  }

  // imageデータの解析
  void make_data_extraction(PImage image) {
    //もと画像が横長の場合，縦長の場合に応じて変える。
    // オフセットを50 に取っている。
    image.resize(w - 100, h - 100);//リサイズする。
    
    getBinalized(image);//２値化してd[][]に格納する
    
    s=thickness();//d[][]から線の太さを見積もる
    
    boolean ofutarisama_flag;
    int loopLimit = min(10,s);
    int kaisa = 0;
    do { 
      if (kaisa % 2 == 0) {
        s -= kaisa;
      } else {
        s += kaisa;
      }
      kaisa++;

      nbhs.clear();
      points.clear();

      for (int y=0; y<h; y+=s) {
        for (int x=0; x<w; x+=s) {
          copy_area(x, y);
        }
      }

      //cancelLoop();がいるらしい。
      countNbhs();
      removeThrone();
      countNbhs();
      fillGap();
      countNbhs();
      FindJoint();
      ofutarisama_flag=Ofutarisama();
      //println(ofutarisama_flag, s);
      tf.ln=s;
      if(ofutarisama_flag) break;
    } while (kaisa < loopLimit);

    if (ofutarisama_flag) {
      // Joint用のNbhの設置
      addJointToNbhs();
      // dispのデータを書き換える。
      getDisplayLTRB();
      // バネモデルの初期化
      tf.spring_setup();
    } else {
      println("読み取り失敗");
    }
  }

  //TODO メソッドをabc順に並べるかどうか，検討する。

  int addToPoints(int u, int v) {//点を追加する
    // (u,v)は点の座標なので，float型ではないか？
    for (int i=0; i<points.size (); i++) {
      if (dist(u, v, points.get(i).x, points.get(i).y )<s-1) {//近くに既存の点がある場合には追加しない
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
    if (nn!=mm&&connected(nn, mm)==1) {
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

  void getBinalized(PImage image){
    image.loadPixels();
    d=new int [w][h];
    //loadPixels();//画面を更新しないので、多分無意味。
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        if (x>=50&&x<(w-50)&&y>=50&&y<(h-50)) {
          color c = image.pixels[(y-50) * image.width + (x-50)];
          if (red(c)>128&&green(c)>128&&blue(c)>128) {
            d[x][y]=0;
          } else {
            d[x][y]=1;
          }
        } else {
          d[x][y]=0;
        }
      }
    }
    //updatePixels();//画面を更新しないので、多分無意味。
  }

  void getDisplayLTRB(){
    float l,t,r,b;
    l=t=r=b=0;
    for (int u=0; u<points.size (); u++) {
      Beads pt=points.get(u);
      if(u==0){
        l=r=pt.x;
        t=b=pt.y;
      } else {
        if(pt.x<l) l=pt.x;
        if(r<pt.x) r=pt.x;
        if(pt.x<t) t=pt.y;
        if(b<pt.y) b=pt.y;
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
      if ( points.get(u).c==1) {
        float min=w;
        int num=0;
        for (int v=0; v<points.size (); v++) {
          if (u!=v) {
            /*
            boolean OK=true;
             for (Nbh n : nbhs) {
             if (n.a==u&&n.b==v) {
             OK=false;
             }
             if (n.a==v&&n.b==u) {
             OK=false;
             }
             }
             */
            //if (OK) {
            if (points.get(u).n1!=v) {
              float d=dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
              if (min>d) {
                min=d;
                num=v;
              }
            }
          }
        }
        if (points.get(num).c==1) {
          addToNbhs(u, num);
          //なにかする
          points.get(num).c++;
          points.get(u).c++;
        } else if (points.get(num).c==0) {
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




  void copy_area(int x, int y) {//
    int e[][]=new int[s][s];
    if (x+s>w||y+s>h) {
      return;
    }
    for (int j=0; j<s; j++) {
      for (int i=0; i<s; i++) {
        e[i][j]=d[x+i][y+j];
      }
    }
    float XY=0, X=0, Y=0, XX=0, YY=0;
    int num=0;
    for (int j=0; j<s; j++) {
      for (int i=0; i<s; i++) {
        if ( e[i][j]==1) {
          XY+=i*j;
          X+=i;
          Y+=j;
          XX+=i*i;
          YY+=j*j;
          num++;
        }
      }
    }
    int v1=0;
    int v2=0;
    int v3=0;
    int v4=0;

    if (num>(s*s)/10) {//1割以上だったら
      if ((num*XX)-(X*X)>(num*YY)-(Y*Y)) {
        float a=(num*XY-X*Y)/((num*XX)-(X*X));
        float b=(XX*Y-XY*X)/((num*XX)-(X*X));
        boolean p1=(b>=0&&b<=s&&d[x][(int)(y+b)]==1);//p1が辺上に乗っているならば
        float k=a*s+b;
        boolean p2=(k>=0&&k<=s&&d[x+s][(int)(y+k)]==1); //p2が辺上に載っているならば
        float h=-b/a;
        //if(a==0)何か処理が必要
        boolean p3=(h>=0&&h<=s&&d[(int)(x+h)][y]==1); //p3が辺上に載っているならば
        float l=(s-b)/a;
        boolean p4=(l>=0&&l<=s&&d[(int)(x+l)][y+s]==1); //p4が辺上に載っているならば
        if (p1) {
          v1=addToPoints(x, (int)(y+b));
        }
        if (p2) {
          v2=addToPoints(x+s, (int)(y+k));
        }
        if (p3) {
          v3=addToPoints((int)(x+h), y);
        }
        if (p4) {
          v4=addToPoints((int)(x+l), y+s);
        }
        if (p1&&p2) {
          addToNbhs(v1, v2);
        }
        if (p2&&p3) {
          addToNbhs(v2, v3);
        }
        if (p1&&p4) {
          addToNbhs(v1, v4);
        }
        if (p1&&p3) {
          addToNbhs(v1, v3);
        }
        if (p2&&p4) {
          addToNbhs(v2, v4);
        }
      } else {
        float a=(num*XY-X*Y)/((num*YY)-(Y*Y));
        float b=(YY*X-XY*Y)/((num*YY)-(Y*Y));
        boolean p1=(b>=0&&b<=s&&d[(int)(x+b)][y]==1);//p1が辺上に乗っているならば
        float k=a*s+b;
        boolean p2=(k>=0&&k<=s&&d[(int)(x+k)][y+s]==1); //p2が辺上に載っているならば
        float h=-b/a;
        //if(a==0)何か処理が必要
        boolean p3=(h>=0&&h<=s&&d[x][(int)(y+h)]==1); //p3が辺上に載っているならば
        float l=(s-b)/a;
        boolean p4=(l>=0&&l<=s&&d[x+s][(int)(y+l)]==1); //p4が辺上に載っているならば
        if (p1) {
          v1=addToPoints((int)(x+b), y);
        }
        if (p2) {
          v2=addToPoints((int)(x+k), y+s);
        }
        if (p3) {
          v3=addToPoints(x, (int)( y+h));
        }
        if (p4) {
          v4=addToPoints(x+s, (int)(y+l));
        }
        if (p1&&p2) {
          addToNbhs(v1, v2);
        }
        if (p2&&p3) {
          addToNbhs(v2, v3);
        }
        if (p1&&p4) {
          addToNbhs(v1, v4);
        }
        if (p1&&p3) {
          addToNbhs(v1, v3);
        }
        if (p2&&p4) {
          addToNbhs(v2, v4);
        }
      }
    }

    boolean OKy=true;
    int flagy;
    int i1=0;
    int i2=s-1;
    int i3=0;
    int i4=0;
    for (int j=0; j<s; j++) {
      flagy=0;
      for (int i=0; i<s; i++) {
        if (flagy==0&&e[i][j]==0) {
          flagy=1;
        } else if (flagy==0&&e[i][j]==1) {
          flagy=2;
          i1=i;
        } else if (flagy==1&&e[i][j]==1) {
          flagy=2;
          i1=i;
        } else if (flagy==2&&e[i][j]==0) {
          flagy=3;
          i2=i;
        } else if (flagy==3&&e[i][j]==1) {
          flagy=4;
        }
      }
      if (j==0) {
        i3=((i1+i2)/2);
      }
      if (j==s-1) {
        i4=((i1+i2)/2);
      }
      if (flagy!=3&&flagy!=2) {
        OKy=false;
      }
    }
    if (OKy) {
      for (int j=0; j<s; j++) {
        for (int i=0; i<s; i++) {
          if ( e[i][j]==1) {
            stroke(0, 255, 0);
          } else {
            stroke(0, 0, 255);
          }
        }
      }
      stroke(0);
    }

    boolean OKx=true;
    int flagx;
    int j1=0;
    int j2=s-1;
    int j3=0;
    int j4=0;
    for (int i=0; i<s; i++) {
      flagx=0;
      for (int j=0; j<s; j++) {
        if (flagx==0&&e[i][j]==0) {
          flagx=1;
        } else if (flagx==0&&e[i][j]==1) {
          flagx=2;
          j1=j;
        } else if (flagx==1&&e[i][j]==1) {
          flagx=2;
          j1=j;
        } else if (flagx==2&&e[i][j]==0) {
          flagx=3;
          j2=j;
        } else if (flagx==3&&e[i][j]==1) {
          flagx=4;
        }
      }
      if (i==0) {
        j3=((j1+j2)/2);
      }
      if (i==s-1) {
        j4=((j1+j2)/2);
      }
      if (flagx!=3&&flagx!=2) {
        OKx=false;
      }
    }
    if (OKx) {
      for (int j=0; j<s; j++) {
        for (int i=0; i<s; i++) {
          if ( e[i][j]==1) {
            stroke(255);
          } else {
            stroke(0, 0, 255);
          }
        }
      }
      stroke(0);
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
    return sum/num;
  }
}