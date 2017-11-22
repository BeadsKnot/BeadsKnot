class data_extract {
  PImage image;
  ArrayList<Nbh> nbhs;
  ArrayList<Beads> points;
  transform tf;

  thinning thng;
  //square_extraction sqr;

  int offset = 10;

  int disp_wid, disp_hei;
  int[][] d;
  int[][] d_new;
  int[][] e;

  data_extract(int _w, int _h, PImage _img) {
    image = _img;
    image.resize(_w-2*offset, _h-2*offset);

    disp_wid = _w;
    disp_hei = _h;

    d=new int[disp_hei][disp_wid];
    d_new=new int[disp_hei][disp_wid];
    e=new int[40][40];

    println("begin data_extracxtion");

    nbhs=new ArrayList<Nbh>();
    points=new ArrayList<Beads>();

    thng = new thinning(this);
    //sqr = new square_extraction(this);
  }

  int addToPoints(int _x, int _y) {
    if (_y>=disp_hei || _x>=disp_wid) {
      return -1;
    }
    if (d[_y][_x]==0) {
      return -1;
    }
    for (int i=0; i<points.size (); i++) {
      if (dist(_x, _y, points.get(i).x, points.get(i).y)<5) {
        return i;
      }
    }
    points.add(new Beads(_x, _y));
    return points.size()-1;
  }

  boolean addToNbh_WithoutCheck(int i1, int i2) {
    if (!is_Beads_id(i1) || !is_Beads_id(i2)) {
      return false;
    }
    for (Nbh n : nbhs) {
      if ( n.a==i1 && n.b==i2 ) {
        return  false;
      } else if ( n.a==i2 && n.b==i1 ) {
        return  false;
      }
    }
    if (i1==i2) {
      return  false;
    }
    //float d=abs(points.get(i1).x-points.get(i2).x)+abs(points.get(i1).y-points.get(i2).y);
    nbhs.add(new Nbh(i1, i2));
    return true;
  }


  boolean is_Beads_id(int num) {
    return (0 <= num && num < points.size());
  }
}