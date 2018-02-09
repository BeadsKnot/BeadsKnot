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
  }
}
class plinkComponent {
  int pointNum1;
  int pointNum2;
}

class plinkPoint {
  int x;
  int y;
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