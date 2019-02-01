class orientation {
  data_extract de;
  data_graph dg;
  orientation(data_extract _de, data_graph _dg) {
    de=_de;
    dg=_dg;
  }
  void decide_orientation() {//orientationを決める
    Node nd = dg.nodes.get(0);
    for(int ndID=0; ndID<dg.nodes.size(); ndID++){
      nd = dg.nodes.get(ndID);
      if(nd.onUse){
        break;
      }
    }
    int beads_start=nd.pointID;
    int beads_first=nd.pointID;
    int beads_next=de.getBead(beads_start).n1;
    int beads_second=de.getBead(beads_start).n1;

    int ori_id=0;//通し番号

    for (int repeat=0; repeat<de.points.size()*2; repeat++) {
      de.getBead(beads_start).orientation=ori_id;
      //始めは0
      ori_id++;
      de.getBead(beads_next).orientation=ori_id;
      //次は1
      //Nbhd new_joint=find_next_joint(new Nbhd(beads_start, beads_next), ori_id);
      //自分で描いたプログラム
      // if (new_joint.a!=0&&new_joint.b!=0) {
      //ori_id++;
      //beads_start=new_joint.b;
      int beads_next_next=-1;

      if (de.getBead(beads_next).u1==beads_start) {
        beads_next_next=de.getBead(beads_next).u2;
      } else if (de.getBead(beads_next).u2==beads_start) {
        beads_next_next=de.getBead(beads_next).u1;
      } else if (de.getBead(beads_next).n1==beads_start) {
        beads_next_next=de.getBead(beads_next).n2;
      } else if (de.getBead(beads_next).n2==beads_start) {
        beads_next_next=de.getBead(beads_next).n1;
      }
      beads_start=beads_next;
      beads_next=beads_next_next;
      //}
      //if (de.getBead(new_joint.b).n2==new_joint.a) {
      //  if (new_joint.b==nd.pointID) {//new_joint.bが一番最初のJointに来たら終わり
      // println(beads_start, beads_first, beads_next, beads_second);
      if (beads_second==beads_next&&beads_first==beads_start) {
        ori_id++;
        de.getBead(beads_next).orientation=ori_id;
        return;
        // }
      }
    }
  }
  //Nbhd find_next_joint(Nbhd n, int ori) {
  //  int a=n.a;//うしろ
  //  int b=n.b;//まえ
  //  for (int repeat=0; repeat<de.points.size(); repeat++) {
  //    if (de.getBead(b).Joint) {
  //      return new Nbhd(a, b);
  //    } else {
  //      //(a,b)を一つ前へ送る
  //      if (de.getBead(b).n1==a) {
  //        a=b;
  //        b=de.getBead(b).n2;
  //      } else {
  //        a=b;
  //        b=de.getBead(b).n1;
  //      }
  //      de.getBead(a).orientation=ori;
  //    }
  //  }
  //  return new Nbhd(0, 0);
  //}

  void dowker_notation() {
    int count=0;
    int joint_point_ID=0;
    for (int i=0; i<de.points.size(); i++) {
      Bead b=de.getBead(i);
      if (b.Joint) {
        joint_point_ID=i;
        count++;
      }
    }
    count=count*2;
    // println(count);
    if (count>0) {
      int dowker_set[]=new int[count];
      boolean wheather_over[]=new boolean[count];
      Bead start=de.getBead(joint_point_ID);
      int n1=start.n1;
      int prev=joint_point_ID;
      int pre_prev=joint_point_ID;
      int j=0;
      Bead node= start;
      dowker_set[0]=joint_point_ID;
      wheather_over[0]=true;
      j++;
      for (int i=0; i<de.points.size(); i++) {
        pre_prev=prev;
        prev=n1;
        if (n1==start.n2) {
          println(i);
          break;
        } else {
          node=de.getBead(n1);
        }
        if (node.Joint) {
          //println(n1);
          dowker_set[j]=n1;
          if (node.n1==pre_prev) {
            n1=node.n2;
            wheather_over[j]=true;
          } else if (node.n2==pre_prev) {
            n1=node.n1;
            wheather_over[j]=true;
          } else if (node.u1==pre_prev) {
            n1=node.u2;
            wheather_over[j]=false;
          } else if (node.u2==pre_prev) {
            n1=node.u1;
            wheather_over[j]=false;
          }
          j=j+1;
        } else {
          n1=node.n1;
          if (pre_prev==n1) {
            n1=node.n2;
          }
        }
      }
      //print("(");
      for (int i=0; i<count; i++) {
        //println("dowker_set["+i+"]=", dowker_set[i]);
        //println("wheather_over["+i+"]", wheather_over[i]);

        if (i%2==0) {
          int a=dowker_set[i];
          for (int ii=0; ii<count; ii++) {
            if (ii!=i&&dowker_set[ii]==a) {
              if (wheather_over[ii]) {
                print("-"+(ii+1)+",");
                //return;
              } else {
                print((ii+1)+",");
                //return;
              }
            }
          }
        }

        //int a=dowker_set[0];
        //for (int c=0; c<count; c++) {
        //  if (c!=0&&dowker_set[c]==a) {
        //    //println(c+1);
        //    if (wheather_over[c]) {
        //      print("-"+(c+1)+",");
        //      //return;
        //    } else {
        //      print((c+1)+",");
        //      //return;
        //    }
        //  }
        //}


        //if ((i+1)%2==0) {
        //  if (wheather_over[i]==true) {
        //    // print("-"+(i+1)+",");
        //  } else {
        //    // print(i+1+",");
        //  }
        //}
      }
      //print(")");
    }
  }
};