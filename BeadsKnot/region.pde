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
      for (int count=0; count<de.points.size(); count++) {
        int nID=-1;
        Bead c=de.getBead(cID);
        vertex(disp.get_winX(c.x), disp.get_winY(c.y));
        if (c.n1==pID) {
          nID=c.n2;
        } else if (c.n2==pID) {
          nID=c.n1;
        }
        pID=cID;
        cID=nID;
        int ID=dg.nodes.get(endID).pointID;
        if (ID==cID) {
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

  region get_region_from_Nbhd(Nbhd nbhd) {
    region ret;
    ret=new region(de, dg);
    // int smoothingRegionContainsPt(float mX, float mY, Nbhd nbhd, boolean debug){
    //BからA
    if (nbhd == null) {
      return null;
    }
    int a = nbhd.a;
    Bead ptA = de.getBead(a);
    int b = nbhd.b;
    Bead ptB = de.getBead(b);
    int c = -1;
    if (ptA == null || ptB == null) {
      return null;
    }
    //Jointでないペアにする
    if (ptA.Joint) {
      int n1 = ptB.n1;
      int n2 = ptB.n2;
      if (n1 == a) {
        a = n2;
      } else if (n2 == a) {
        a = n1;
      } else {
        return null;
      }
      ptA = de.getBead(a);
      if (ptA==null) {
        return null;
      }
    }
    if (ptB.Joint) {
      int n1 = ptA.n1;
      int n2 = ptA.n2;
      if (n1 == b) {
        b = n2;
      } else if (n2 == b) {
        b = n1;
      } else {
        return null;
      }
      ptB = de.getBead(b);
      if (ptB==null) {
        return null;
      }
    }
    //orientationが計算されているかなぞ
    //if (ptA.orientation < ptB.orientation) {
    if (orie.orientation_greater(ptA.orientation, ptB.orientation)==-1) {
      ptA=de.getBead(b);
      ptB=de.getBead(a);
      c=a;
      a=b;
      b=c;
    }
    int start_a = a;
    int count = 0;
    //nearX = mX;
    float x0, y0, x1, y1, xxx;
    int repeatmax = de.points.size();
    for (int repeat=0; repeat < repeatmax; repeat++) {
      // go straight
      if ( ! ptA.Joint) {
        if (ptA.n1 == b) {
          c = ptA.n2;
        } else if (ptA.n2 == b) {
          c = ptA.n1;
        } else {
          println("get_region_from_Nbhd 1: error");
          return null;
        }
        b = a;
        a = c;
        ptA= de.getBead(a);
        if (ptA==null) {
          return null;
        }
        ptB = de.getBead(b);
        if (ptB==null) {
          return null;
        }
      }
      // jointのデータからedgeのIDを取得する
      else {
        int n1=ptA.n1;
        int n2=ptA.n2;
        int u1=ptA.u1;
        int u2=ptA.u2;
        Bead bdN1=de.getBead(n1), bdN2=de.getBead(n2), bdU1=de.getBead(u1), bdU2=de.getBead(u2);
        if (bdN1==null || bdN2==null || bdU1==null || bdU2==null) {
          break;///処理保留
        }
        int nu12=-1;
        if (b==ptA.n1) {
          //c=ptA.u1;
          c=ptA.u2;
          nu12=1;
        } else if (b==ptA.u1) {
          //c=ptA.n2;
          c=ptA.n1;
          //nu12=2;
          nu12=4;
        } else if (b==ptA.n2) {
          //c=ptA.u2;
          c=ptA.u1;
          nu12=3;
        } else if (b==ptA.u2) {
          //c=ptA.n1;
          c=ptA.n2;
          //nu12=4;
          nu12=2;
        } else {
          println("get_region_from_Nbhd 2: error", ptA.n1, ptA.u1, ptA.n2, ptA.u2, b);
          return null;
        }
        //A,Cから始まるedgeを見つける
        int nodeID=-1;
        for (int nID=0; nID<dg.nodes.size(); nID++) {
          Node n=dg.nodes.get(nID);
          if (n.pointID==a) {
            nodeID=nID;
          }
        }
        for (int eID=0; eID<dg.edges.size(); eID++) {
          Edge e=dg.edges.get(eID);
          if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
            ret.border.add(e);
          } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
            ret.border.add(e);
          }
        }
        b = a;
        a = c;
        ptA= de.getBead(a);
        if (ptA==null) {
          return null;
        }
        ptB = de.getBead(b);
        if (ptB==null) {
          return null;
        }
      }
      if (start_a == a) {
        break;
      }
    }
    return ret;
  }
}