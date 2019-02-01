class Bead {//点のクラス
  float x;
  float y;
  int c;
  int n1;
  int n2;
  int u1;//underのお隣//pointsの番号
  int u2;//underのお隣
  int orientation;//Beadsの番号ではない
  boolean inUse;//そもそも使用しているかどうか．
  boolean Joint;//crossingかどうか
  boolean midJoint;//crossingとcrossingの間のBeads
  boolean closeJoint;//crossingのやや隣
  boolean treated;//画像解析のときのみ使用
  Bead(float _x, float _y) {
    x=_x;
    y=_y;
    n1=-1;
    n2=-1;
    u1=-1;
    u2=-1;
    c=0;
    inUse=true;
    Joint=false;
    midJoint=false;
    closeJoint=false;
    //treated=false;
  }

  //BeadをNodeとみなした時の傾きthetaを計算する。
  float getTheta(ArrayList<Bead> points) {
    Bead neighbor1=points.get(n1);
    double x1=neighbor1.x;
    double y1=neighbor1.y;
    double th=Math.atan2(-y1+y, x1-x);
    return (float)th;
  }

  int get_un12(int rID) {
    switch(rID) {
    case 0: 
      return n1; 
    case 1: 
      return u1; 
    case 2: 
      return n2; 
    case 3: 
      return u2; 
    }
    return -1;
  }
  void set_un12(int rID, int beadID){
    switch(rID) {
    case 0: 
      n1 = beadID; 
      break;
    case 1: 
      u1 = beadID; 
      break;
    case 2: 
      n2 = beadID; 
      break;
    case 3: 
      u2 = beadID; 
      break;
    }
  }    
}