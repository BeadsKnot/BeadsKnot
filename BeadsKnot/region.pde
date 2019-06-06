class region { //<>// //<>//
  ArrayList <Edge> border;
  data_extract de;
  data_graph dg;
  color col;
  region(data_extract _de, data_graph _dg, color _col) {
    border=new ArrayList <Edge>();
    de=_de;
    dg=_dg;
    col=_col;
  }
  void paintRegion() {/////////////nulpoint対応はまだ
    int startID=-1;
    int startRID=-1;
    int endID=-1;
    int endRID=-1;
    if (border.get(0).ANodeID==border.get(1).ANodeID||border.get(0).ANodeID==border.get(1).BNodeID) {
      startID= border.get(0).BNodeID;
      startRID= border.get(0).BNodeRID;
      endID= border.get(0).ANodeID;
      endRID= border.get(0).ANodeRID;
    } else {
      startID=border.get(0).ANodeID;
      startRID= border.get(0).ANodeRID;
      endID=border.get(0).BNodeID;
      endRID=border.get(0).BNodeRID;
    }

    fill(col);
    beginShape();

    for (int b=0; b<border.size(); b++) {
      // println(startID, startRID, endID, endRID);
      Edge e=border.get(b);
      int pID=dg.nodes.get(startID).pointID;
      Bead p=de.getBead(pID);/////pがnullの可能性あり
      int cID=p.get_un12(startRID);
      //println("pIDは"+pID, "cIDは"+cID);
      /////edgeをたどる

      for (int count=0; count<de.points.size(); count++) {
        int nID=-1;
        Bead c=de.getBead(cID);
        Bead j=de.getBead(pID);
        if (j.Joint||j.midJoint) {
          vertex(disp.get_winX(j.x), disp.get_winY(j.y));
        }
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
      if (b!=border.size()-1) {
        e=border.get(b+1);
        if (endID==e.ANodeID) {
          startID=e.ANodeID;
          startRID=e.ANodeRID;
          endID=e.BNodeID;
          endRID=e.BNodeRID;
        } else {
          startID=e.BNodeID;
          startRID=e.BNodeRID;
          endID=e.ANodeID;
          endRID=e.ANodeRID;
        }
        //  endRID=e.BNodeRID;
      }
    }
    //for (int count=0; count<de.points.size(); count++) {
    //  Bead j=de.getBead(count);
    //  if (j.Joint) {
    //    vertex(disp.get_winX(j.x), disp.get_winY(j.y));
    //  }
    //}

    endShape();
  }

  void get_region_from_Nbhd(Nbhd nbhd) {
    border=new ArrayList<Edge>();
    // int smoothingRegionContainsPt(float mX, float mY, Nbhd nbhd, boolean debug){
    //BからA
    if (nbhd == null) {
      return;
    }
    int a = nbhd.a;
    Bead ptA = de.getBead(a);
    int b = nbhd.b;
    Bead ptB = de.getBead(b);
    int c = -1;
    if (ptA == null || ptB == null) {
      return;
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
        return;
      }
      ptA = de.getBead(a);
      if (ptA==null) {
        return;
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
        return;
      }
      ptB = de.getBead(b);
      if (ptB==null) {
        return;
      }
    }
    //orientationが計算されているかなぞ
    //if (ptA.orientation < ptB.orientation) {
    //if (orie.orientation_greater(ptA.orientation, ptB.orientation)==-1) {
    //  ptA=de.getBead(b);
    //  ptB=de.getBead(a);
    //  c=a;
    //  a=b;
    //  b=c;
    //}
    if (ptA.y>ptB.y) {
      ptA=de.getBead(b);
      ptB=de.getBead(a);
      c=a;
      a=b;
      b=c;
    }

    int start_a = a;
    //int count = 0;
    //nearX = mX;
    //float x0, y0, x1, y1, xxx;
    int repeatmax = de.points.size();
    for (int repeat=0; repeat < repeatmax; repeat++) {
      // go straight
      //print(a,b);
      if ( ! ptA.Joint&&!ptA.midJoint) {
        if (ptA.n1 == b) {
          c = ptA.n2;
        } else if (ptA.n2 == b) {
          c = ptA.n1;
        } else {
          println("get_region_from_Nbhd 1: error");
          return;
        }
        b = a;
        a = c;
        ptA= de.getBead(a);
        if (ptA==null) {
          return;
        }
        ptB = de.getBead(b);
        if (ptB==null) {
          return;
        }
      } else if (ptA.midJoint) {
        int nu12=-1;
        if (ptA.n1 == b) {
          c = ptA.n2;
          nu12=2;
        } else if (ptA.n2 == b) {
          c = ptA.n1;
          nu12=0;
        } else {
          println("get_region_from_Nbhd 1: error");
          return;
        }
        //A,Cから始まるedgeを見つける
        int nodeID=-1;
        for (int nID=0; nID<dg.nodes.size(); nID++) {
          Node n=dg.nodes.get(nID);
          if (n.pointID==a) {
            nodeID=nID;
          }
        }
        // println("now at", nodeID, nu12);
        for (int eID=0; eID<dg.edges.size(); eID++) {
          Edge e=dg.edges.get(eID);
          //println("A=", e.ANodeID, e.ANodeRID);
          //println("B=",e.BNodeID,e.BNodeRID);
          if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
            // println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
            border.add(e);
          } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
            //println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
            border.add(e);
          }
        }
        b = a;
        a = c;
        ptA= de.getBead(a);
        if (ptA==null) {
          return;
        }
        ptB = de.getBead(b);
        if (ptB==null) {
          return;
        }
      }
      // jointのデータからedgeのIDを取得する
      else {  
        /////////////////////////////////////////ptAがJointのとき
        // println("is a joint");
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
          // c=ptA.u1;
          c=ptA.u2;
          nu12=3;
        } else if (b==ptA.u1) {
          //c=ptA.n2;
          c=ptA.n1;
          nu12=0;
          //nu12=0;
        } else if (b==ptA.n2) {
          //c=ptA.u2;
          c=ptA.u1;
          nu12=1;
        } else if (b==ptA.u2) {
          //c=ptA.n1;
          c=ptA.n2;
          //nu12=4;
          nu12=2;
        } else {
          println("get_region_from_Nbhd 2: error", ptA.n1, ptA.u1, ptA.n2, ptA.u2, b);
          return ;
        }
        //A,Cから始まるedgeを見つける
        int nodeID=-1;
        for (int nID=0; nID<dg.nodes.size(); nID++) {
          Node n=dg.nodes.get(nID);
          if (n.pointID==a) {
            nodeID=nID;
          }
        }
        //println("now at", nodeID, nu12);
        for (int eID=0; eID<dg.edges.size(); eID++) {
          Edge e=dg.edges.get(eID);
          //println("A=", e.ANodeID, e.ANodeRID);
          // println("B=", e.BNodeID, e.BNodeRID);
          if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
            //println("Jointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
            border.add(e);
          } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
            //println("Jointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
            border.add(e);
          }
        }
        b = a;
        a = c;
        ptA= de.getBead(a);
        if (ptA==null) {
          return ;
        }
        ptB = de.getBead(b);
        if (ptB==null) {
          return ;
        }
      }
      if (start_a == a) {
        break;
      }
    }
    return;
  }
}