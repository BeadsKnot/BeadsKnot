class parts_editing {    //<>//

  ArrayList<Bead> beads;

  parts_editing() {
    beads = new ArrayList<Bead>();
  }

  void draw_parts() {
    draw_nhd();
    draw_beads();
  }

  void draw_beads() {
    strokeWeight(1);
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      int c = 2;
      if (bd.c == 3) {
        stroke(0);
        fill(255, 0, 0);
        c=5;
      }else if (bd.c == 1) {
        stroke(0);
        fill(255, 180, 0);
        c=3;
      } else if (bd.Joint) {
        stroke(0);
        fill(80, 255, 80);
        if (bd.c == 4) {
          c=2;
        } else {
          c=3;
        }
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      //dispをつかって表示を画面サイズに合わせるように座標変換する。
      ellipse(bd.x, bd.y, c*3+1, c*3+1);
    }
  }

  void draw_nhd() {
    strokeWeight(2);
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      if (0<= bd.n1 && bd.n1<beads.size() && beads.get(bd.n1).c>=0) {
        Bead next = beads.get(bd.n1);
        if (next.Joint) {
          if (next.n1 == bdID || next.n2 == bdID) {
            stroke(0);
          } else {
            stroke(255, 180, 255);
          }
        } else {
          stroke(0);
        }
        line(bd.x, bd.y, next.x, next.y);
      }
      if (0<= bd.n2 && bd.n2<beads.size() && beads.get(bd.n2).c>=0) {
        Bead next = beads.get(bd.n2);
        if (next.Joint) {
          if (next.n1 == bdID || next.n2 == bdID) {
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
    bd=new Bead(_x+30, _y);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x-30, _y);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x, _y+30);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
    bd=new Bead(_x, _y-30);
    bd.n1 = bdID;
    bd.c = 1;
    beads.add(bd);
  }

  void deleteBead(int bdID) {//クリックするとビーズを消すことができる。
    Bead bd0 = beads.get(bdID);
    int bd0ID=bd0.n1;
    if (0<= bd0ID && bd0ID<beads.size()) {
      Bead bd1 = beads.get(bd0ID);
      bd0.n1 = -1;
      for (int r=0; r<4; r++) {
        if (bd1.get_un12(r)==bdID) {
          bd1.set_un12(r, -1);
          bd1.c --;
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
          bd1.c --;
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
          bd1.c --;
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
          bd1.c --;
        }
      }
    }
    bd0.x = bd0.y = -1;// 圏外
    bd0.c = -1;
    //beads.remove(bdID);//本当に消す
    //for (int b=0; b<beads.size(); b++) {
    //  Bead bd = beads.get(b);
    //  if (bd.n1>bdID) bd.n1 --;
    //  if (bd.n2>bdID) bd.n2 --;
    //  if (bd.u1>bdID) bd.u1 --;
    //  if (bd.u2>bdID) bd.u2 --;
    //}

    restore_beads();
  }

  void restore_beads() {
    // 枝の番号(n1,n2,u1,u2)を整備する。
    for (int b=0; b<beads.size(); b++) {
      Bead bd = beads.get(b);
      int c, n[];
      c=0;
      n=new int[4];
      n[0]=n[1]=n[2]=n[3]=-1;
      if (bd.n1>=0 && bd.n1<beads.size()) {
        Bead bd1 = beads.get(bd.n1);
        for (int r=0; r<4; r++) {
          if (bd1.get_un12(r)==b) {
            n[c] = bd.n1;
            c++;
            break;
          }
        }
      }
      if (bd.n2>=0 && bd.n2<beads.size()) {
        Bead bd1 = beads.get(bd.n2);
        for (int r=0; r<4; r++) {
          if (bd1.get_un12(r)==b) {
            n[c] = bd.n2;
            c++;
            break;
          }
        }
      }
      if (bd.u1>=0 && bd.u1<beads.size()) {
        Bead bd1 = beads.get(bd.u1);
        for (int r=0; r<4; r++) {
          if (bd1.get_un12(r)==b) {
            n[c] = bd.u1;
            c++;
            break;
          }
        }
      }
      if (bd.u2>=0 && bd.u2<beads.size()) {
        Bead bd1 = beads.get(bd.u2);
        for (int r=0; r<4; r++) {
          if (bd1.get_un12(r)==b) {
            n[c] = bd.u2;
            c++;
            break;
          }
        }
      }
      bd.n1 = n[0];
      bd.n2 = n[1];
      bd.u1 = n[2];
      bd.u2 = n[3];
      bd.c=c;
      if (c<=2 && bd.Joint) {
        bd.Joint=false;
      }
    }
  }

  void points_to_beads(data_extract de) {
    beads.clear();
    int pointslength = de.points.size();
    println("pointslength", pointslength);
    //de.debugLogPoints("points_to_beads.csv");
    for (int ptID = 0; ptID < pointslength; ptID++) {
      Bead pt = de.getBead(ptID);
      if(pt==null){
        Bead bd = new Bead(0f,0f);
        bd.inUse=false;
        beads.add(bd);
      } else {
        Bead bd = new Bead(pt.x,pt.y);
        bd.n1 = pt.n1;
        bd.n2 = pt.n2;
        bd.u1 = pt.u1;
        bd.u2 = pt.u2;
        bd.c = pt.c;
        bd.inUse=true;
        bd.Joint = pt.Joint;
        beads.add(bd);
      }
    }
    restore_beads();
    //de.clearAllPoints();
    de.clearAllPoints();
    de.clearAllNbhd();
    Draw.parts_editing();
  }
}