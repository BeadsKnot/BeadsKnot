class Beads {//点のクラス
  float x;
  float y;
  int c;
  int n1;
  int n2;
  int u1;
  int u2;
  boolean Joint;
  boolean midJoint;
  boolean closeJoint;
  Beads(float _x, float _y) {
    x=_x;
    y=_y;
    n1=-1;
    n2=-1;
    u1=-1;
    u2=-1;
    c=0;
    Joint=false;
    midJoint=false;
    closeJoint=false;
  }
  
  float getTheta(ArrayList<Beads> points){
        Beads neighbor1=points.get(n1);
        double x1=neighbor1.x;
        double y1=neighbor1.y;
        double th=Math.atan2(-y1+y,x1-x);
        return (float)th;
    }
    
}