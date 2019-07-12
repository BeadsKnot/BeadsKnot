class region { //<>// //<>//
  ArrayList <Edge> border;
  ArrayList<Nbhd> atm;//どのn1もしくはn2もしくはu1もしくはu2が使われていたのかを知るために必要なペア
  ArrayList<Bead> saveJoint;
  data_extract de;
  data_graph dg;
  int col_code;
  orientation orie;
  region(data_extract _de, data_graph _dg, orientation _orie) {
    border=new ArrayList <Edge>();
    atm=new ArrayList<Nbhd>();
    saveJoint=new ArrayList<Bead>();
    de=_de;
    dg=_dg;
    orie=_orie;
    col_code=1;
  }
  void paintRegion() {/////////////nulpoint対応はまだ//get.()みたいなところがまだアブナイ
    int startID=-1;
    int startRID=-1;
    int endID=-1;
    //int endRID=-1;
    if (border==null) {
      return;
    }
    if (border.size()<2) {
      return;
    }
    if (border.get(0).ANodeID==border.get(1).ANodeID||border.get(0).ANodeID==border.get(1).BNodeID) {
      startID= border.get(0).BNodeID;
      startRID= border.get(0).BNodeRID;
      endID= border.get(0).ANodeID;
      // endRID= border.get(0).ANodeRID;
    } else {
      startID=border.get(0).ANodeID;
      startRID= border.get(0).ANodeRID;
      endID=border.get(0).BNodeID;
      //endRID=border.get(0).BNodeRID;
    }
    noStroke();
    if (col_code==0) {
      fill(255);
    } else if (col_code==1) {
      fill(#FF6347);
    } else {
      fill(#87ceeb);
    }
    beginShape();

    for (int b=0; b<border.size(); b++) {
      // println(startID, startRID, endID, endRID);
      Edge e=border.get(b);
      int pID=dg.nodes.get(startID).pointID;
      Bead p=de.getBead(pID);/////pがnullの可能性あり
      if (p==null) {
        fill(255);
        endShape();
        return;
      }
      int cID=p.get_un12(startRID);
      //println("pIDは"+pID, "cIDは"+cID);
      /////edgeをたどる

      for (int count=0; count<de.points.size(); count++) {
        int nID=-1;
        Bead c=de.getBead(cID);
        Bead j=de.getBead(pID);
        if (c==null||j==null) {
          fill(255);
          endShape();
          return;
        }
        if (j.Joint||j.midJoint||j.bandJoint) {
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
          //endRID=e.BNodeRID;
        } else {
          startID=e.BNodeID;
          startRID=e.BNodeRID;
          endID=e.ANodeID;
          //endRID=e.ANodeRID;
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
      if ( ! ptA.Joint&&!ptA.midJoint&&!ptA.bandJoint) {
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
      } else if (ptA.bandJoint) {
        //Jointみたいな扱いにして曲げることができるかできないかで分ける
        int nu12=-1;
        if (ptA.n1 == b) {
          if (ptA.u1==-1) {
            c=ptA.u2;
            nu12=3;
            //println("曲げる");
          } else {
            c = ptA.n2;
            nu12=2;
          }
        } else if (ptA.n2 == b) {
          if (ptA.u2==-1) {
            c=ptA.u1;
            nu12=1;
            //println("曲げる");
          } else {
            c = ptA.n1;
            nu12=0;
          }
        } else if (ptA.u1 == b) {
          c=ptA.n1;
          nu12=0;
          //println("曲げる");
        } else if (ptA.u2 == b) {
          c=ptA.n2;
          nu12=2;
          //println("曲げる");
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
        // println(ptA.n1, ptA.n2, ptA.u1, ptA.u2);
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
          //println("ptA.n2は"+ptA.n2);
          //Bead bn2=de.getBead(ptA.n2);
          //Bead bn2n2=de.getBead(bn2.n2);
          //if (bn2n2.Joint) {
          //  atm.add(new Nbhd(ptA.n2, bn2.n1));
          //} else {
          //  atm.add(new Nbhd(ptA.n2, bn2.n2));
          //}
          // cross.add(new Nbhd(i, minJ));
        } else if (b==ptA.u1) {
          //c=ptA.n2;
          c=ptA.n1;
          nu12=0;
          //nu12=0;
          //println("ptA.u2は"+ptA.u2);
          //Bead bu2=de.getBead(ptA.u2);
          //Bead bu2n2=de.getBead(bu2.n2);
          //if (bu2n2.Joint) {
          //  atm.add(new Nbhd(ptA.u2, bu2.n1));
          //} else {
          //  atm.add(new Nbhd(ptA.u2, bu2.n2));
          //}
        } else if (b==ptA.n2) {
          //c=ptA.u2;
          c=ptA.u1;
          nu12=1;
          //println("ptA.n1は"+ptA.n1);
          //Bead bn1=de.getBead(ptA.n1);
          //Bead bn1n2=de.getBead(bn1.n2);
          //if (bn1n2.Joint) {
          //  atm.add(new Nbhd(ptA.n1, bn1.n1));
          //} else {
          //  atm.add(new Nbhd(ptA.n1, bn1.n2));
          //}
        } else if (b==ptA.u2) {
          //c=ptA.n1;
          c=ptA.n2;
          //nu12=4;
          nu12=2;
          // println("ptA.u1は"+ptA.u1);
          //Bead bu1=de.getBead(ptA.u1);
          //Bead bu1n2=de.getBead(bu1.n2);
          //if (bu1n2.Joint) {
          //  atm.add(new Nbhd(ptA.u1, bu1.n1));
          //} else {
          //  atm.add(new Nbhd(ptA.u1, bu1.n2));
          //}
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
    //for (int i=0; i<atm.size(); i++) {
    //  println(atm.get(i).a, atm.get(i).b);
    //}

    //for (int bo=0; bo<border.size(); bo++) {
    //  Edge e=border.get(bo);
    //println(e.ANodeID, e.ANodeRID, e.BNodeID, e.BNodeRID);
    //}
    return;
  }

  void click_orientatio_for_auto(Nbhd nbhd) {//クリックされた領域のJointの
    // border=new ArrayList<Edge>();
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
      if ( ! ptA.Joint&&!ptA.midJoint&&!ptA.bandJoint) {
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
        //for (int eID=0; eID<dg.edges.size(); eID++) {
        //  Edge e=dg.edges.get(eID);
        //  //println("A=", e.ANodeID, e.ANodeRID);
        //  //println("B=",e.BNodeID,e.BNodeRID);
        //  if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
        //    // println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
        //    //println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  }
        //}
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
      } else if (ptA.bandJoint) {
        //Jointみたいな扱いにして曲げることができるかできないかで分ける
        int nu12=-1;
        if (ptA.n1 == b) {
          if (ptA.u1==-1) {
            c=ptA.u2;
            nu12=3;
            //println("曲げる");
          } else {
            c = ptA.n2;
            nu12=2;
          }
        } else if (ptA.n2 == b) {
          if (ptA.u2==-1) {
            c=ptA.u1;
            nu12=1;
            //println("曲げる");
          } else {
            c = ptA.n1;
            nu12=0;
          }
        } else if (ptA.u1 == b) {
          c=ptA.n1;
          nu12=0;
          //println("曲げる");
        } else if (ptA.u2 == b) {
          c=ptA.n2;
          nu12=2;
          //println("曲げる");
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
        //for (int eID=0; eID<dg.edges.size(); eID++) {
        //  Edge e=dg.edges.get(eID);
        //  //println("A=", e.ANodeID, e.ANodeRID);
        //  //println("B=",e.BNodeID,e.BNodeRID);
        //  if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
        //    // println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
        //    //println("MidJointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  }
        //}
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
        // println(ptA.n1, ptA.n2, ptA.u1, ptA.u2);
        /////////////////////////////////////////ptAがJointのとき
        // println("is a joint");
        println(ptA.orientation);
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
          println("ptA.n2は"+ptA.n2);
          atm.add(new Nbhd(ptA.n1, ptA.u2)); 
          saveJoint.add(ptA);
          // cross.add(new Nbhd(i, minJ));
        } else if (b==ptA.u1) {
          //c=ptA.n2;
          c=ptA.n1;
          nu12=0;
          //nu12=0;
          println("ptA.u2は"+ptA.u2);
          atm.add(new Nbhd(ptA.n1, ptA.u1));
          saveJoint.add(ptA);
        } else if (b==ptA.n2) {
          //c=ptA.u2;
          c=ptA.u1;
          nu12=1;
          println("ptA.n1は"+ptA.n1);
          atm.add(new Nbhd(ptA.n2, ptA.u1));
          saveJoint.add(ptA);
        } else if (b==ptA.u2) {
          //c=ptA.n1;
          c=ptA.n2;
          //nu12=4;
          nu12=2;
          println("ptA.u1は"+ptA.u1);
          atm.add(new Nbhd(ptA.n2, ptA.u2));
          saveJoint.add(ptA);
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
        //for (int eID=0; eID<dg.edges.size(); eID++) {
        //  Edge e=dg.edges.get(eID);
        //  //println("A=", e.ANodeID, e.ANodeRID);
        //  // println("B=", e.BNodeID, e.BNodeRID);
        //  if (e.ANodeID==nodeID&&e.ANodeRID==nu12) {
        //    //println("Jointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  } else if (e.BNodeID==nodeID&&e.BNodeRID==nu12) {
        //    //println("Jointのe.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, "e.BNodeIDは"+e.BNodeID, "e.BNodeRIDは"+e.BNodeRID);
        //    border.add(e);
        //  }
        //}
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
    for (int i=0; i<atm.size(); i++) {
      println(atm.get(i).a, atm.get(i).b);
    }

    //for (int bo=0; bo<border.size(); bo++) {
    //  Edge e=border.get(bo);
    //println(e.ANodeID, e.ANodeRID, e.BNodeID, e.BNodeRID);
    //}
    return;
  }

  void auto_get_region(ArrayList <Nbhd> auto, ArrayList <Bead> sj) {
    //auto.aはn1またはn2
    //auto.bはu1またはu2
    //atmとsaveJointを引数にする
    //atmとsaveJointのsizeは同じ
    for (int i=0; i<auto.size(); i++) {
      Bead a=de.getBead(auto.get(i).a);
      Bead b=de.getBead(auto.get(i).b);
      Bead j=sj.get(i);
      //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
      if (de.getBead(j.n1)==a) {
        if (de.getBead(j.u1)==b) {
          //4個の場合分け
          if (orie.orientation_greater(j.n2, j.n1)==1) {
            if (orie.orientation_greater(j.u2, j.u1)==1) {
              //bandも入れると3面貼りたい(band以外同じ色)
              Bead beadu=de.getBead(j.u2);
              Bead beadn=de.getBead(j.n2);
              if (de.getBead(beadu.n2)==j) {
                get_region_from_Nbhd(j.u2, bead.n1);
              } else if (de.getBead(beadu.n1)==j) {
                get_region_from_Nbhd(j.u2, bead.n2);
              }
              if (de.getBead(beadn.n2)==j) {
                get_region_from_Nbhd(j.n2, bead.n1);
              } else if (de.getBead(beadn.n1)==j) {
                get_region_from_Nbhd(j.n2, bead.n2);
              }
              //bandの分はn1からスタート
            } else if (orie.orientation_greater(j.u1, j.u2)==1) {
              //反対の1面だけ違う色を貼りたい
              Bead bead=de.getBead(j.u2);
              if (de.getBead(bead.n2)==j) {
                get_region_from_Nbhd(j.u2, bead.n1);
              } else if (de.getBead(bead.n1)==j) {
                get_region_from_Nbhd(j.u2, bead.n2);
              }
            }
          } else if (orie.orientation_greater(j.n1, j.n2)==1) {
            if (orie.orientation_greater(j.u1, j.u2)==1) {
              //bandも入れると3面貼りたい(band以外同じ色)
            } else if (orie.orientation_greater(j.u2, j.u1)==1) {
              //反対の1面だけ違う色を貼りたい
              Bead bead=de.getBead(j.u2);
              if (de.getBead(bead.n2)==j) {
                get_region_from_Nbhd(j.u2, bead.n1);
              } else if (de.getBead(bead.n1)==j) {
                get_region_from_Nbhd(j.u2, bead.n2);
              }
            }
          }
        } else if (de.getBead(j.u2)==b) {
          //4個の場合分け
        }
      } else if (de.getBead(j.n2)==a) {
        if (de.getBead(j.u1)==b) {
          //4個の場合分け
        } else if (de.getBead(j.u2)==b) {
          //4個の場合分け
        }
      }
    }
  }
}

boolean match_region(region _r) {
  if (_r==null) {
    return false;
  }
  if (_r.border.size()!=border.size()) {
    return false;
  }
  int count=0;
  for (int r=0; r<_r.border.size(); r++) {  
    for (int b=0; b<border.size(); b++) {  
      if (_r.border.get(r).matchEdge(border.get(b))) {
        count++;
        if (count==_r.border.size()) {
          return true;
        }
      }
    }
  }
  return false;
}
}