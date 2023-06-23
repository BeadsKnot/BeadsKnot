class PLink {
  //data_graph dg;
  data_extract de;
  displayWorld disp;
  //ファイル保存
  PrintWriter outfile;
  ArrayList<plinkComponent> pCo;//成分に関する配列
  ArrayList<plinkPoint> pPo;//ポイントに関する配列
  ArrayList<plinkEdge> pEd;//辺に関する配列
  ArrayList<crossing_set> crs;//交点の情報
  ArrayList<plinkCrossing> pCr;//交点に関する配列
  PLink(data_extract _de, displayWorld _disp) {
    de=_de;
    disp=_disp;
    makePlinkData();//たどる関数
  }

  boolean file_output() {//出力する関数
    outfile = createWriter(file_name);
    outfile.println("% Link Projection");
    //成分数
    outfile.println(pCo.size());
    for (int i=0; i<pCo.size(); i++) {
      int pN1=(pCo.get(i).pointNum1);
      int pN2=(pCo.get(i).pointNum2);
      outfile.println(pN1+" "+pN2);
    }
    //点の個数
    outfile.println(pPo.size());
    for (int i=0; i<pPo.size(); i++) {
      int x=(int)(pPo.get(i).x);
      int y=(int)(pPo.get(i).y);
      outfile.println(x+" "+y);
    }
    //辺の数
    outfile.println(pEd.size());
    for (int i=0; i<pEd.size(); i++) {
      int h=pEd.get(i).pointNum1;
      int j=pEd.get(i).pointNum2;
      outfile.println(h+" "+j);
    }
    //交点
    outfile.println(pCr.size());
    for (int i=0; i<pCr.size(); i++) {
      int h=pCr.get(i).edgeNum1;
      int j=pCr.get(i).edgeNum2;
      outfile.println(h+" "+j);
    }

    outfile.println("-1");
    outfile.flush(); //残りを出力する
    outfile.close(); // ファイルを閉じる
    return true;
  }

  void makePlinkData() {//たどる関数
    //初期化
    pCo=new ArrayList<plinkComponent>();
    pPo=new ArrayList<plinkPoint>();
    pEd=new ArrayList<plinkEdge>();
    pCr=new ArrayList<plinkCrossing>();
    crs=new ArrayList<crossing_set>();
    //midJointとcloseJointに処理済みかどうかのフラグを設定//もしくはBeadsにフラグを設定
    for (int pN=0; pN<de.points.size(); pN++) {
      Bead bd = de.points.get(pN); 
      bd.treated=false;//どこもたどっていないのでまずすべてfalseに
    }
    int edgeCount=0;//辺を数える
    int pointCount=0;//点を数える
    int crossingCount=0;//交点を数える
    //pointでfor文を回してmidJointとcloseJointを探す
    for (int pN=0; pN<de.points.size(); pN++) {
      Bead dePoint=de.points.get(pN);//pNをたくさん使うのでBeads型で名前を付けておく

      if (dePoint.midJoint||dePoint.closeJoint) {//midJointとcloseJointを探す
        if (!dePoint.treated) {//たどっていないポイントのなかで(たどっていたらtrue)
          dePoint.treated=true;//まずその点をたどったことにする
          int pointCount0=pointCount;//2成分以上のときにどことつながるのかわかるようにする
          pCo.add(new plinkComponent(pointCount, pointCount));//まず、成分に追加
          pPo.add(new plinkPoint(pointCount, int(dePoint.x), int(dePoint.y)));//点の座標を追加
          pointCount++;
          pairNum pn0=new pairNum(pN, dePoint.n1);
          while (true) {
            pairNum pn1=findMidJoint_CloseJointInPoints(pn0);
            crossing_set c_s=find_JointInPoints(pn0, edgeCount);
            if (c_s.edge_num!=-1) {
              crs.add(c_s);
            }

            Bead dePoint_out=de.getBead(pn1.j);
            if (!dePoint_out.treated) {//処理していなかったら
              dePoint_out.treated=true;
              pPo.add(new plinkPoint(pointCount, int(dePoint_out.x), int(dePoint_out.y)));
              pEd.add(new plinkEdge(edgeCount, pointCount-1, pointCount)); 
              pointCount++;
              edgeCount++;
              pn0.j=pn1.j;
              pn0.c=pn1.c;
            } else {
              pEd.add(new plinkEdge(edgeCount, pointCount-1, pointCount0));
              edgeCount++;
              break;
            }
            //処理済みでなくて、midJointまたはcloseJointに対してplinkComponentの始点登録とし
          }
        }
      }
      //plinkPointsへの追加を行う
      //do文から線をたどる
      //if (dePoint.closeJoint) {//closeJointを探す

      //  crossingCount++;
      //  if (crossingCount%4==0) {
      //    println(crossingCount);
      //    pCr.add(new plinkCrossing(crossingCount, 0, 0));
      //  }
      //}
    }
    for (int i=0; i<crs.size(); i++) {
      for (int j=i+1; j<crs.size(); j++) {
        int joint_num_i=crs.get(i).joint_num;
        int joint_num_j=crs.get(j).joint_num;
        if (joint_num_i==joint_num_j) {
          if (crs.get(i).over_under==2) {
            pCr.add(new plinkCrossing(crossingCount, crs.get(i).edge_num, crs.get(j).edge_num));
            //println(crossingCount, crs.get(i).edge_num, crs.get(j).edge_num);
            crossingCount++;
          } else if (crs.get(i).over_under==1) {
            pCr.add(new plinkCrossing(crossingCount, crs.get(j).edge_num, crs.get(i).edge_num));
            //println(crossingCount, crs.get(j).edge_num, crs.get(i).edge_num);
            crossingCount++;
          }
        }
      }
    }
    println("PLink file作成　成功");
  }

  pairNum findMidJoint_CloseJointInPoints(pairNum _pn) {//ペアでmidJointとcloseJointを探す関数
    int j=_pn.j;
    int c=_pn.c;
    while (true) {
      Bead pc=de.getBead(c);
      if (pc.n1==j) {
        j=c;
        c=pc.n2;
      } else if (pc.n2==j) {
        j=c;
        c=pc.n1;
      } else if (pc.u1==j) {
        j=c;
        c=pc.u2;
      } else if (pc.u2==j) {
        j=c;
        c=pc.u1;
      } else {
        println("miss");
        break;
      }
      if (pc.midJoint||pc.closeJoint) {
        return new pairNum(j, c);
      }
    }
    return new pairNum(0, 0);//特に意味のない一文
  }

  crossing_set find_JointInPoints(pairNum _pn, int edge_num) {//ペアでJointを探す関数
    //第二引数でedge_countを入れる
    int j=_pn.j;
    int c=_pn.c;
    int o_u_flag=0;
    while (true) {
      Bead pc=de.getBead(c);
      if (pc.n1==j) {
        j=c;
        c=pc.n2;
        o_u_flag=1;
      } else if (pc.n2==j) {
        j=c;
        c=pc.n1;
        o_u_flag=1;
      } else if (pc.u1==j) {
        j=c;
        c=pc.u2;
        o_u_flag=2;
      } else if (pc.u2==j) {
        j=c;
        c=pc.u1;
        o_u_flag=2;
      } else {
        println("miss");
        break;
      }
      if (pc.Joint) {
        return new crossing_set(edge_num, j, o_u_flag );
      } else if (pc.midJoint||pc.closeJoint) {
        return new crossing_set(-1, -1, -1);//特に意味のない一文
      }
    }
    return new crossing_set(-1, -1, -1);//特に意味のない一文
  }
}

//交点の探し方
//closeJointからcloseJointにつながっている線を探し、そこがつながっている線を記録




class pairNum {//ペアにする関数
  int j;
  int c;
  pairNum(int _j, int _c) {
    j=_j;
    c=_c;
  }
}

class plinkComponent {//成分に関する関数
  int pointNum1;
  int pointNum2;
  plinkComponent(int _pN1, int _pN2) {
    pointNum1=_pN1;
    pointNum2=_pN2;
  }
}

class plinkPoint {//点に関する関数
  int pointNum;
  int x;
  int y;
  plinkPoint(int _n, int _x, int _y) {
    pointNum=_n;
    x=_x;
    y=_y;
  }
}

class plinkEdge {//辺に関する関数
  int EdgeNum;
  int pointNum1;
  int pointNum2;
  plinkEdge(int _count, int _count1, int _count2) {
    EdgeNum=_count;
    pointNum1=_count1;
    pointNum2=_count2;
  }
}

class plinkCrossing {//交点に関する関数
  int CrossingNum;
  int edgeNum1;
  int edgeNum2;
  plinkCrossing(int count, int eN1, int eN2) {
    CrossingNum=count;
    edgeNum1=eN1;
    edgeNum2=eN2;
  }
}

class crossing_set {//
  int edge_num;
  int joint_num;
  int over_under;//1なら上、2なら下
  crossing_set(int edge, int joint, int o_u) {
    edge_num=edge;
    joint_num=joint;
    over_under=o_u;
  }
}