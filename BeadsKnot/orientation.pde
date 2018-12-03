class orientation {
  data_extract de;
  data_graph dg;
  orientation(data_extract _de, data_graph _dg) {
    de=_de;
    dg=_dg;
  }
  void decide_orientation() {//orientationを決める
    Node nd=dg.nodes.get(0);
    int beads_start=nd.pointID;
    int beads_first=nd.pointID;
    int beads_next=de.points.get(beads_start).n1;
    int beads_second=de.points.get(beads_start).n1;

    int ori_id=0;//通し番号

    for (int repeat=0; repeat<de.points.size()*2; repeat++) {
      de.points.get(beads_start).orientation=ori_id;
      //始めは0
      ori_id++;
      de.points.get(beads_next).orientation=ori_id;
      //次は1
      //Nbhd new_joint=find_next_joint(new Nbhd(beads_start, beads_next), ori_id);
      //自分で描いたプログラム
      // if (new_joint.a!=0&&new_joint.b!=0) {
      //ori_id++;
      //beads_start=new_joint.b;
      int beads_next_next=-1;

      if (de.points.get(beads_next).u1==beads_start) {
        beads_next_next=de.points.get(beads_next).u2;
      } else if (de.points.get(beads_next).u2==beads_start) {
        beads_next_next=de.points.get(beads_next).u1;
      } else if (de.points.get(beads_next).n1==beads_start) {
        beads_next_next=de.points.get(beads_next).n2;
      } else if (de.points.get(beads_next).n2==beads_start) {
        beads_next_next=de.points.get(beads_next).n1;
      }
      beads_start=beads_next;
      beads_next=beads_next_next;
      //}
      //if (de.points.get(new_joint.b).n2==new_joint.a) {
      //  if (new_joint.b==nd.pointID) {//new_joint.bが一番最初のJointに来たら終わり
      // println(beads_start, beads_first, beads_next, beads_second);
      if (beads_second==beads_next&&beads_first==beads_start) {
        return;
        // }
      }
    }
  }
  Nbhd find_next_joint(Nbhd n, int ori) {
    int a=n.a;//うしろ
    int b=n.b;//まえ
    for (int repeat=0; repeat<de.points.size(); repeat++) {
      if (de.points.get(b).Joint) {
        return new Nbhd(a, b);
      } else {
        //(a,b)を一つ前へ送る
        if (de.points.get(b).n1==a) {
          a=b;
          b=de.points.get(b).n2;
        } else {
          a=b;
          b=de.points.get(b).n1;
        }
        de.points.get(a).orientation=ori;
      }
    }
    return new Nbhd(0, 0);
  }
};