class region {
  ArrayList <Edge> border;
  data_extract de;
  data_graph dg;
  region(data_extract _de, data_graph _dg) {
    border=new ArrayList <Edge>();
    de=_de;
    dg=_dg;
  }
  void paintRegion(color col) {/////////////nulpoint対応はまだ
    int startID=border.get(0).ANodeID;
    int startRID=border.get(0).ANodeRID;
    int endID=border.get(0).BNodeID;
   // int endRID=border.get(0).BNodeRID;
   fill(col);
    beginShape();
    for (int b=0; b<border.size(); b++) {
      Edge e=border.get(b);
      int pID=dg.nodes.get(startID).pointID;
      Bead p=de.getBead(pID);/////pがnullの可能性あり
      int cID=p.get_un12(startRID);
      /////edgeをたどる
      for(int count=0;count<de.points.size();count++){
        int nID=-1;
        Bead c=de.getBead(cID);
        vertex(disp.get_winX(c.x),disp.get_winY(c.y));
        if(c.n1==pID){
          nID=c.n2;
        }else if(c.n2==pID){
          nID=c.n1;
        }
        pID=cID;
        cID=nID;
        int ID=dg.nodes.get(endID).pointID;
        if(ID==cID){
        break;
        }
      }
      //次への処理
      e=border.get(b+1);
      startID=e.ANodeID;
      startRID=e.ANodeRID;
      endID=e.BNodeID;
    //  endRID=e.BNodeRID;
    }
  }
}