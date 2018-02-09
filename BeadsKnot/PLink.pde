class PLink {
  data_graph dg;
  display disp;
  //ファイル保存
  PrintWriter outfile;
  ArrayList<plinkComponent> pCo;
  ArrayList<plinkPoint> pPo;
  ArrayList<plinkEdge> pEd;
  ArrayList<plinkCrossing> pCr;
  PLink(data_graph _dg, display _disp) {

    dg=_dg;
    disp=_disp;
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
      int h=pEd.get(i).h;
      int j=pEd.get(i).j;
      outfile.println(h+" "+j);
    }
    //交点
    outfile.println("-1");
    outfile.flush(); //残りを出力する
    outfile.close(); // ファイルを閉じる
    return true;
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
    int pointNum1;
    int pointNum2;
  }

  class plinkCrossing {
    int edgeNum1;
    int edgeNum2;
  }
}