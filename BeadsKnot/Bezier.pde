class Bezier {
  float v1X, v1Y, v2X, v2Y, v3X, v3Y, v4X, v4Y;
  boolean active;

  Bezier() {
    active = false;
  }

  Bezier(Bezier _b){
    v1X = _b.v1X;
    v1Y = _b.v1Y;
    v2X = _b.v2X;
    v2Y = _b.v2Y;
    v3X = _b.v3X;
    v3Y = _b.v3Y;
    v4X = _b.v4X;
    v4Y = _b.v4Y;
    active = true;
  }

  void setV(float _v1X, float _v1Y, float _v2X, float _v2Y, float _v3X, float _v3Y, float _v4X, float _v4Y) {
    v1X = _v1X;
    v1Y = _v1Y;
    v2X = _v2X;
    v2Y = _v2Y;
    v3X = _v3X;
    v3Y = _v3Y;
    v4X = _v4X;
    v4Y = _v4Y;
    active = true;
  }

  void set_bezier(Node _A, Node _B, int ANodeRID, int BNodeRID){
    setV(_A.x, _A.y, _A.edge_x(ANodeRID), _A.edge_y(ANodeRID), _B.edge_x(BNodeRID), _B.edge_y(BNodeRID), _B.x, _B.y);
  }

  PVector get_curvature_range() {
    float min=PI;
    float max=0f;
    float step=(0.05);// step is 1/20
    float cx = v1X;
    float cy = v1Y;
    float dx = coordinate_bezier(v1X, v2X, v3X, v4X, step);
    float dy = coordinate_bezier(v1Y, v2Y, v3Y, v4Y, step);
    float ex = 0f, ey = 0f;
    for (float repeat = step*2; repeat<=1.0; repeat += step) {
      ex=coordinate_bezier(v1X, v2X, v3X, v4X, repeat);
      ey=coordinate_bezier(v1Y, v2Y, v3Y, v4Y, repeat);
      float ang = angle(cx, cy, dx, dy, ex, ey);
      if (ang < min) { // get minimum
        min = ang;
      }
      if (ang > max) { // get maximum
        max = ang;
      }
      cx = dx;
      cy = dy;
      dx = ex;
      dy = ey;
    }
    return new PVector(min, max);
  }

  float angle(float ax, float ay, float bx, float by, float cx, float cy) {
    if ((ax==bx && ay==by) || (bx==cx && by==cy)) {
      println("error in angle()");
    }
    float ang1 = atan2(ay-by, ax-bx);
    float ang2 = atan2(by-cy, bx-cx);
    float ret = ang2-ang1;
    //if (ret < 0.0) {
    //  ret = -ret;
    //}
    if (ret > PI) {
      ret = 2 * PI - ret;
    }
    if (ret < -PI) {
      ret = -2 * PI - ret;
    }
    return ret;
  }

  float naibun(float p, float q, float t) {
    return (p*(1.0-t)+q*t);
  }

  float coordinate_bezier(float a, float c, float e, float g, float t) {
    float x1 = naibun(a, c, t);
    float x2 = naibun(c, e, t);
    float x3 = naibun(e, g, t);
    float x4 = naibun(x1, x2, t);
    float x5 = naibun(x2, x3, t);
    return naibun(x4, x5, t);
  }

  float get_arclength() {
    float arclen=0f;
    float xx0 = v1X;
    float yy0 = v1Y;
    float xx, yy;
    for (float repeat=0.01f; repeat<=1.0f; repeat += 0.01f) {
      xx = coordinate_bezier(v1X, v2X, v3X, v4X, repeat);
      yy = coordinate_bezier(v1Y, v2Y, v3Y, v4Y, repeat);
      arclen += dist(xx0, yy0, xx, yy);
      xx0 = xx;
      yy0 = yy;
    }
    return arclen;
  }

  float atan2Vec(float a, float c, float p, float q) {
    float b = -c;
    float d = a;
    float s = (p * d - b * q) / (a * d - b * c);
    float t = (a * q - p * c) / (a * d - b * c);
    float ret = atan2(t, s);
    if (ret < 0) {
      ret += 2*PI;
    }
    return ret;
  }

  PVector get_rate_t1t2() {
    float rate = (dist(v4X-v1X, v4Y-v1Y, 0f, 0f))/250f;// 250=計測したときのV4-V1の長さ
    float t1 = degrees(atan2Vec(v2X-v1X, v2Y-v1Y, v4X-v1X, v4Y-v1Y));
    float t2 = degrees(atan2Vec(v2X-v1X, v2Y-v1Y, v3X-v4X, v3Y-v4Y));
    return new PVector(rate,t1,t2);
  }
};
