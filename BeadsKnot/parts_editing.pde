class parts_editing{
  
  ArrayList<Bead> beads;
  
  parts_editing(){
    beads = new ArrayList<Bead>();
  }
  
  void draw_parts(){
    draw_nhd();
    draw_beads();
  }
  
  void draw_beads(){
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      int c = 2;
      if(bd.c == 1){
        stroke(0);
        fill(255,180,0);
        c=3;
      } else if (bd.Joint || bd.midJoint) {
        stroke(0);
        fill(80,255,80);
        c=3;
      } else {
        stroke(255, 0, 0);
        fill(255);
      }
      //dispをつかって表示を画面サイズに合わせるように座標変換する。
      ellipse(bd.x, bd.y, c*3+1, c*3+1);
    }
  }
  
  void draw_nhd(){
    for (int bdID=0; bdID<beads.size (); bdID++) {
      Bead bd=beads.get(bdID);
      Bead next = beads.get(bd.n1);
      if(next.Joint || next.midJoint){
        stroke(255,180,255);
      } else {
        stroke(0);
      }
      line(bd.x,bd.y,next.x,next.y);
      next = beads.get(bd.n2);
      if(next.Joint || next.midJoint){
        stroke(255,180,255);
      } else {
        stroke(0);
      }
      line(bd.x,bd.y,next.x,next.y);
    }
  }
  
}
