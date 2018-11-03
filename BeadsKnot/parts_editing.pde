class parts_editing {

  ArrayList<Bead> beads;

  parts_editing() {
    beads = new ArrayList<Bead>();
  }

  void draw_parts() {
    draw_nhd();
    draw_beads();
  }

  void draw_beads() {
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      int c = 2;
      if (bd.c == 1) {
        stroke(0);
        fill(255, 180, 0);
        c=3;
      } else if (bd.Joint || bd.midJoint) {
        stroke(0);
        fill(80, 255, 80);
        c=3;
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      //dispをつかって表示を画面サイズに合わせるように座標変換する。
      ellipse(bd.x, bd.y, c*3+1, c*3+1);
    }
  }

  void draw_nhd() {
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      if (0<= bd.n1 && bd.n1<beads.size()) {
        Bead next = beads.get(bd.n1);
        if (next.Joint || next.midJoint) {
          if(next.n1 == bdID || next.n2 == bdID){
            stroke(0);
          } else {
            stroke(255, 180, 255);
          }
        } else {
          stroke(0);
        }
        line(bd.x, bd.y, next.x, next.y);
      }
      if (0<= bd.n2 && bd.n2<beads.size()) {
        Bead next = beads.get(bd.n2);
        if (next.Joint || next.midJoint) {
          if(next.n1 == bdID || next.n2 == bdID){
            stroke(0);
          } else {
            stroke(255, 180, 255);
          }
        } else {
          stroke(0);
        }
        line(bd.x, bd.y, next.x, next.y);
      }
    }
  }

  void createJoint(float _x, float _y) {
    Bead bd=new Bead(_x, _y);
    int bdID = beads.size();
    bd.n1 = bdID+1;
    bd.n2 = bdID+2;
    bd.u1 = bdID+3;
    bd.u2 = bdID+4;
    bd.c = 4;
    bd.Joint=true;
    beads.add(bd);
    bd=new Bead(_x+15, _y);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x-15, _y);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x, _y+15);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x, _y-15);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
  }

  void deleteBead(int bdID) {
    Bead bd0 = beads.get(bdID);
    int bd0ID=bd0.n1;
    if (0<= bd0ID && bd0ID<beads.size()) {
      Bead bd1 = beads.get(bd0ID);
      bd0.n1 = -1;
      for (int r=0; r<4; r++) {
        if (bd1.get_un12(r)==bdID) {
          bd1.set_un12(r, -1);
        }
      }
    }
    bd0ID=bd0.n2;
    if (0<= bd0ID && bd0ID<beads.size()) {
      Bead bd1 = beads.get(bd0ID);
      bd0.n2 = -1;
      for (int r=0; r<4; r++) {
        if (bd1.get_un12(r)==bdID) {
          bd1.set_un12(r, -1);
        }
      }
    }
    bd0ID=bd0.u1;
    if (0<= bd0ID && bd0ID<beads.size()) {
      Bead bd1 = beads.get(bd0ID);
      bd0.u1 = -1;
      for (int r=0; r<4; r++) {
        if (bd1.get_un12(r)==bdID) {
          bd1.set_un12(r, -1);
        }
      }
    }
    bd0ID=bd0.u2;
    if (0<= bd0ID && bd0ID<beads.size()) {
      Bead bd1 = beads.get(bd0ID);
      bd0.u2 = -1;
      for (int r=0; r<4; r++) {
        if (bd1.get_un12(r)==bdID) {
          bd1.set_un12(r, -1);
        }
      }
    }
    bd0.x = bd0.y = -1;// 圏外
  }
}
