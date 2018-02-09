class PLink {
  //data_graph dg;
  data_extract de;
  display disp;
  //ファイル保存
  PrintWriter outfile;
  ArrayList<plinkComponent> pCo;
  ArrayList<plinkPoint> pPo;
  ArrayList<plinkEdge> pEd;
  ArrayList<plinkCrossing> pCr;
  PLink(data_extract _de, display _disp) {
    de=_de;
    disp=_disp;
    makePlinkData();//たどる関数
  }
  /*
  int number_of_component() {
   return ;
   }
   
   int number_of_point() {
   return ;
   }
   
   int number_of_edge() {
   return ;
   }
   
   int number_of_joint() {
   return;
   }
   */
  boolean file_output() {
    outfile = createWriter(file_name+".txt");
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

  void makePlinkData() {
    //初期化
    pCo=new ArrayList<plinkComponent>();
    pPo=new ArrayList<plinkPoint>();
    pEd=new ArrayList<plinkEdge>();
    pCr=new ArrayList<plinkCrossing>();
    //midJointとcloseJointに処理済みかどうかのフラグを設定
    for (int pN=0; pN<de.points.size(); pN++) {
      de.points.get(pN).treated=false;
    }
    int edgeCount=0;//辺を数える
    int pointCount=0;//点を数える
    //もしくはBeadsにフラグを設定
    //pointでfor文を回してmidJointとcloseJointを探す
    for (int pN=0; pN<de.points.size(); pN++) {
      Beads dePoint=de.points.get(pN);
      if (dePoint.midJoint||dePoint.closeJoint) {
        if (!dePoint.treated) {
          dePoint.treated=true;
          int pointCount0=pointCount;//輪が1以上あるときに使う
          pCo.add(new plinkComponent(pointCount, pointCount));
          pPo.add(new plinkPoint(pointCount,int(dePoint.x),int(dePoint.y)));
          pointCount++;
        }
      }
    }
    //処理済みでなくて、midJointまたはcloseJointに対してplinkComponentの始点登録とし
    //plinkPointsへの追加を行う
    //do文から線をたどる
  }
}
class plinkComponent {
  int pointNum1;
  int pointNum2;
  plinkComponent(int _pN1, int _pN2) {
    pointNum1=_pN1;
    pointNum2=_pN2;
  }
}

class plinkPoint {
  int pointNum;
  int x;
  int y;
  plinkPoint(int _n,int _x,int _y){
  pointNum=_n;
  x=_x;
  y=_y;
  }
}

class plinkEdge {
  int EdgeNum;
  int pointNum1;
  int pointNum2;
}

class plinkCrossing {
  int edgeNum1;
  int edgeNum2;
}