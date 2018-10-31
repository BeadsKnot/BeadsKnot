class Bezier {
  float v1X,v1Y,v2X,v2Y,v3X,v3Y,v4X,v4Y;
  boolean active;
  
  Bezier(){
    active = false;
  }
  
  void setV(float _v1X, float _v1Y, float _v2X, float _v2Y,
  float _v3X, float _v3Y, float _v4X, float _v4Y){
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

  PVector get_curvature_range(){
    float min=0f;
    float max=0f;
    return new PVector(min,max);
  }
  
  float get_arclength(){
    return 0f;
  }
};
