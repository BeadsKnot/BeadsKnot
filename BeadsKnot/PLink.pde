class PLink {
  data_graph dg;
  display disp;
  //ファイル保存
  PrintWriter outfile;

  PLink(data_graph _dg,display _disp) {
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
    outfile.println(dg.nodes.size());
    for(int i=0;i<dg.nodes.size();i++){
    int x=(int)(dg.nodes.get(i).x);
    int y=(int)(dg.nodes.get(i).y);
    outfile.println(x+" "+y);
    }
    //辺の数
    outfile.println(dg.edges.size());
    for(int i=0;i<dg.edges.size();i++){
    int h=dg.edges.get(i).h;
    int j=dg.edges.get(i).j;
     outfile.println(h+" "+j);
    }
    //交点
    outfile.println("-1");
    outfile.flush(); //残りを出力する
    outfile.close(); // ファイルを閉じる
    return true;
  }
}