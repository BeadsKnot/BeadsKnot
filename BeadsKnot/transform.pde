class transform {//形を整えるクラス
  float []dx;
  float []dy;
  data_extract de;
  float ln;//自然長を定義 longueur naturel
  transform(data_extract _de){
    de=_de;
    ln = beads_interval;// グローバル変数
  }
  
  void spring_setup() {
    dx=new float[de.points.size()];//点の個数
    dy=new float[de.points.size()];
  }

  void spring() {
    for (int i=0; i<de.points.size (); i++) {//初期化
      dx[i]=0;
      dy[i]=0;
    }
    for (int i=0; i<de.nbhds.size (); i++) {
      calc_spring(de.nbhds.get(i).a, de.nbhds.get(i).b, ln);//Nbh[n,m]みたいな感じになる
    }
    for (int i=0; i<de.points.size (); i++) {//double spring scheme
      Bead vec=de.getBead(i);
      if (vec.Joint) {
        calc_spring(vec.n1, vec.u1, 1.414*ln);
        calc_spring(vec.n2, vec.u1, 1.414*ln);
        calc_spring(vec.n2, vec.u2, 1.414*ln);
        calc_spring(vec.n1, vec.u2, 1.414*ln);
      } else {
        calc_spring(vec.n1, vec.n2, 1.99*ln);
      }
    }

    for (int i=0; i<de.points.size (); i++) {
      de.getBead(i).x+=dx[i];
      de.getBead(i).y+=dy[i];
    }
  }

  void calc_spring(int i, int j, float l) {//ばねモデル
    float X=0;
    float Y=0;
    float d=0;
    float k=0.1;
    X=de.getBead(j).x-de.getBead(i).x;
    Y=de.getBead(j).y-de.getBead(i).y;
    d=sqrt(X*X+Y*Y);
    dx[i]+=X/d*k*(d-l);
    dy[i]+=Y/d*k*(d-l);
    dx[j]-=X/d*k*(d-l);
    dy[j]-=Y/d*k*(d-l);
  }
}