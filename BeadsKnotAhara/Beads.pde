class Beads {
  float x, y;
  float dx, dy;
  int deg;
  boolean Joint;
  boolean isNode;
  boolean isPreNode;
  int n1, n2, u1, u2;
  Beads(float _x, float _y) {
    x = _x;
    y = _y;
    deg = 0;
    n1 = n2 = u1 = u2 = -1;
    Joint = false;
    isNode = isPreNode = false;
  }
}