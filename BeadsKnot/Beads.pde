class Beads {//点のクラス
  float x;
  float y;
  int c;
  int n1;
  int n2;
  int u1;
  int u2;
  boolean Joint;
  Beads(float _x, float _y) {
    x=_x;
    y=_y;
    n1=-1;
    n2=-1;
    u1=-1;
    u2=-1;
    c=0;
    Joint=false;
  }
}
