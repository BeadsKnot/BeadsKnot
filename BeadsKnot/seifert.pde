class seifert { //<>//
  ArrayList <region> reg;
  seifert() {
    reg=new ArrayList<region>();
  }
  void find_nbhd_region(region r) {
    for (Edge e : r.border) {
      int AnodeID=e.ANodeID;
      int AnodeRID=e.ANodeRID;
      int BnodeID=e.BNodeID;
      int BnodeRID=e.BNodeRID;
      int oneRID=-1;
      int anotherRID=-1;
      int nodeID=-1;
      int nodePointID=-1;
      Node ANode=r.dg.nodes.get(AnodeID);
      Node BNode=r.dg.nodes.get(BnodeID);////////////////////////IndexOutOfBoundsException:Indexエラー
      //midJointと近いところでbandを作ろうとするとエラーが出る
      Bead j=r.de.getBead(0);
      int nodeRID[]=new int[4];
      if (AnodeRID==1||AnodeRID==3) {
        nodeID=AnodeID;
        println("nodeIDは"+nodeID);
        nodePointID=ANode.pointID;
        j=r.de.getBead(ANode.pointID);
        for (int n=0; n<4; n++) {
          nodeRID[n]=j.get_un12(n);
        }
        oneRID=AnodeRID;
        println("oneRIDは"+oneRID);
        for (Edge ed : r.border) {
          if (ed.ANodeID==nodeID) {
            if (ed.ANodeRID==0||ed.ANodeRID==2) {
              anotherRID=ed.ANodeRID;
              println("anotherRIDは"+anotherRID);
              break;
            }
          }
          if (ed.BNodeID==nodeID) {
            if (ed.BNodeRID==0||ed.BNodeRID==2) {
              anotherRID=ed.BNodeRID;
              println("anotherRIDは"+anotherRID);
              break;
            }
          }
        }
      }
      if (BnodeRID==1||BnodeRID==3) {
        nodeID=BnodeID;
        oneRID=BnodeRID;
        println("nodeIDは"+nodeID);
        println("oneRIDは"+oneRID);
        nodePointID=BNode.pointID;
        j=r.de.getBead(BNode.pointID);
        for (int n=0; n<4; n++) {
          nodeRID[n]=j.get_un12(n);
        }
        for (Edge ed : r.border) {
          if (ed.ANodeID==nodeID) {
            if (ed.ANodeRID==0||ed.ANodeRID==2) {
              anotherRID=ed.ANodeRID;
              println("anotherRIDは"+anotherRID);
              break;
            }
          }
          if (ed.BNodeID==nodeID) {
            if (ed.BNodeRID==0||ed.BNodeRID==2) {
              anotherRID=ed.BNodeRID;
              println("anotherRIDは"+anotherRID);
              break;
            }
          }
        }
      }
      //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
      //oneRIDは1か3
      //anotherRIDは0か2
      int n_orie=r.orie.orientation_greater(j.n2, j.n1);
      int u_orie=r.orie.orientation_greater(j.u2, j.u1);
      int findbandJointID[]=new int[5];
      for (int n=0; n<4; n++) {
        int k=findBandJoint(r, nodePointID, nodeRID[n]);
        findbandJointID[n]=k;
        if (k!=-1) {
          println("findbandJointは"+k);
          println("そのときのnodePointIDは"+nodePointID);
          println("そのときのnodeRID["+n+"]は"+nodeRID[n]);
          // edge_number(r, );
          //edge番号を返す関数を呼ぶ
          //get_edgesでedgeをaddしている
          //返されたedge番号と一致しているかどうかを判定する関数を呼ぶ
        }
      }
      findbandJointID[4]=findbandJointID[0];
      boolean discover_bandJoint=false;
      for (int ed=0; ed<r.dg.edges.size(); ed++) {
        Edge ee=r.dg.edges.get(ed);
        Node ndA=r.dg.nodes.get(ee.ANodeID);
        Node ndB=r.dg.nodes.get(ee.BNodeID);
        for (int n=0; n<4; n++) {
          if (findbandJointID[n]==ndA.pointID&&findbandJointID[n+1]==ndB.pointID) {
            println("発見1");
            discover_bandJoint=true;
            Bead beadsA=r.de.getBead(ndA.pointID);
            int eeANodeRID=ee.ANodeRID;
            int tmp=0;
            if (eeANodeRID==1) {
              tmp=beadsA.n1;
              beadsA.n1=beadsA.u1;
              beadsA.u1=beadsA.n2;
              beadsA.n2=tmp;
            } else if (eeANodeRID==3) {
              tmp=beadsA.n1;
              beadsA.n1=beadsA.n2;
              beadsA.n2=beadsA.u2;
              beadsA.u2=tmp;
            }
            Bead beadsB=r.de.getBead(ndB.pointID);
            int eeBNodeRID=ee.BNodeRID;
            if (eeBNodeRID==1) {
              tmp=beadsB.n1;
              beadsB.n1=beadsB.n2;
              beadsB.n2=beadsB.u1;
              beadsB.u1=tmp;
            } else if (eeBNodeRID==3) {
              tmp=beadsB.n1;
              beadsB.n1=beadsB.u2;
              beadsB.u2=beadsB.n2;
              beadsB.n2=tmp;
            }
            r.dg.make_data_graph();
          }
          if (findbandJointID[n]==ndB.pointID&&findbandJointID[n+1]==ndA.pointID) {
            println("発見2");
            discover_bandJoint=true;
            Bead beadsA=r.de.getBead(ndA.pointID);
            int eeANodeRID=ee.ANodeRID;
            int tmp=0;
            if (eeANodeRID==1) {
              //もともと
              //tmp=beadsA.n1;
              //beadsA.n1=beadsA.u1;
              //beadsA.u1=beadsA.n2;
              //beadsA.n2=tmp;

              tmp=beadsA.n1;
              beadsA.n1=beadsA.n2;
              beadsA.n2=beadsA.u1;
              beadsA.u1=tmp;
            } else if (eeANodeRID==3) {
              //もともと
              //tmp=beadsA.n1;
              //beadsA.n1=beadsA.n2;
              //beadsA.n2=beadsA.u2;
              //beadsA.u2=tmp;

              tmp=beadsA.n1;
              beadsA.n1=beadsA.u2;
              beadsA.u2=beadsA.n2;
              beadsA.n2=tmp;
            }
            Bead beadsB=r.de.getBead(ndB.pointID);
            int eeBNodeRID=ee.BNodeRID;
            if (eeBNodeRID==1) {
              tmp=beadsB.n1;
              beadsB.n1=beadsB.u1;
              beadsB.u1=beadsB.n2;
              beadsB.n2=tmp;
            } else if (eeBNodeRID==3) {
              tmp=beadsB.n1;
              beadsB.n1=beadsB.n2;
              beadsB.n2=beadsB.u2;
              beadsB.u2=tmp;
            }
            r.dg.make_data_graph();
          }
          // println(ndA.pointID, ndB.pointID, ee.ANodeRID, ee.BNodeRID);
        }
      }

      if (anotherRID==0) {
        if (oneRID==1) {
          if (n_orie==1) {
            if (u_orie==1) {
              /////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            } else if (u_orie==-1) {
              //r.get_region_from_Nbhd()
              ////////////////////nodePointID,3
            }
          } else if (n_orie==-1) {
            if (u_orie==1) {
              /////////////////////nodePointID,3
            } else if (u_orie==-1) {
              ////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            }
          }
        } else if (oneRID==3) {
          if (n_orie==1) {
            if (u_orie==1) {
              /////////////////////nodePointID,2
            } else if (u_orie==-1) {
              ////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            }
          } else if (n_orie==-1) {
            if (u_orie==1) {
              /////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            } else if (u_orie==-1) {
              ////////////////////nodePointID,2
            }
          }
        }
      } else if (anotherRID==2) {
        if (oneRID==1) {
          if (n_orie==1) {
            if (u_orie==1) {
              ////////////////////nodePointID,0
            } else if (u_orie==-1) {
              ///////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            }
          } else if (n_orie==-1) {
            if (u_orie==1) {
              /////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            } else if (u_orie==-1) {
              ////////////////////nodePointID,0
            }
          }
        } else if (oneRID==3) {
          if (n_orie==1) {
            if (u_orie==1) {
              ///////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            } else if (u_orie==-1) {
              //////////////////////nodePointID,1
            }
          } else if (n_orie==-1) {
            if (u_orie==1) {
              /////////////////////nodePointID,1
            } else if (u_orie==-1) {
              ////////////////////bandのやつ
              if (discover_bandJoint) {
              } else {
              }
            }
          }
        }
      }




      //if (anotherRID==0) {
      //  if (oneRID==1) {
      //    if ((r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u1, j.u2)==1)||(r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u2, j.u1)==1)) {
      //      Bead n2=r.de.getBead(j.n2);
      //      if (r.de.getBead(n2.n1).Joint) {
      //        //j.n2とn2.n2をnbhdにして色を塗る
      //        println(j.n2, n2.n2);
      //      } else if (r.de.getBead(n2.n2).Joint) {
      //        //j.n2とn2.n1をnbhdにして色を塗る
      //        println(j.n2, n2.n1);
      //      }
      //    }
      //  } else if (oneRID==3) {
      //    if ((r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u2, j.u1)==1)||(r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u1, j.u2)==1)) {
      //      Bead n2=r.de.getBead(j.n2);
      //      if (r.de.getBead(n2.n1).Joint) {
      //        //j.n2とn2.n2をnbhdにして色を塗る
      //        println(j.n2, n2.n2);
      //      } else if (r.de.getBead(n2.n2).Joint) {
      //        //j.n2とn2.n1をnbhdにして色を塗る
      //        println(j.n2, n2.n1);
      //      }
      //    }
      //  }
      //} else if (anotherRID==2) {
      //  if (oneRID==1) {
      //    if ((r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u1, j.u2)==1)||(r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u2, j.u1)==1)) {
      //      Bead n1=r.de.getBead(j.n1);
      //      if (r.de.getBead(n1.n1).Joint) {
      //        //j.n1とn1.n2をnbhdにして色を塗る
      //        println(j.n1, n1.n2);
      //      } else if (r.de.getBead(n1.n2).Joint) {
      //        //j.n1とn1.n1をnbhdにして色を塗る
      //        println(j.n1, n1.n1);
      //      }
      //    }
      //  } else if (oneRID==3) {
      //    if ((r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u2, j.u1)==1)||(r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u1, j.u2)==1)) {
      //      Bead n1=r.de.getBead(j.n1);
      //      if (r.de.getBead(n1.n1).Joint) {
      //        //j.n1とn1.n2をnbhdにして色を塗る
      //        println(j.n1, n1.n2);
      //      } else if (r.de.getBead(n1.n2).Joint) {
      //        //j.n1とn1.n1をnbhdにして色を塗る
      //        println(j.n1, n1.n1);
      //      }
      //    }
      //  }
      //}
    }
  }
  boolean determine_color(region r) {
    ArrayList <region> total_color=new ArrayList<region>();
    for (Edge e : r.border) {
      int nodeID=e.ANodeID;
      int nodeRID=e.ANodeRID;
      //隣のregionをどうやって塗るか

      //auto.aはn1またはn2
      //auto.bはu1またはu2
      //atmとsaveJointを引数にする
      //atmとsaveJointのsizeは同じ
      //for (int i=0; i<auto.size(); i++) {
      //  Bead a=de.getBead(auto.get(i).a);
      //  Bead b=de.getBead(auto.get(i).b);
      //  Bead j=sj.get(i);
      //  //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
      //  if (de.getBead(j.n1)==a) {
      //    if (de.getBead(j.u1)==b) {
      //      //4個の場合分け
      //      if (orie.orientation_greater(j.n2, j.n1)==1) {
      //        if (orie.orientation_greater(j.u2, j.u1)==1) {
      //          //bandも入れると3面貼りたい(band以外同じ色)
      //          Bead beadu=de.getBead(j.u2);
      //          Bead beadn=de.getBead(j.n2);
      //          if (de.getBead(beadu.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, beadu.n1));
      //          } else if (de.getBead(beadu.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, beadu.n2));
      //          }
      //          if (de.getBead(beadn.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.n2, beadn.n1));
      //          } else if (de.getBead(beadn.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.n2, beadn.n2));
      //          }
      //          //bandの分はn1からスタート?
      //        } else if (orie.orientation_greater(j.u1, j.u2)==1) {
      //          //反対の1面だけ違う色を貼りたい
      //          Bead bead=de.getBead(j.u2);
      //          if (de.getBead(bead.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, bead.n1));
      //          } else if (de.getBead(bead.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, bead.n2));
      //          }
      //        }
      //      } else if (orie.orientation_greater(j.n1, j.n2)==1) {
      //        if (orie.orientation_greater(j.u1, j.u2)==1) {
      //          //bandも入れると3面貼りたい(band以外同じ色)
      //          Bead beadu=de.getBead(j.u2);
      //          Bead beadn=de.getBead(j.n2);
      //          if (de.getBead(beadu.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, beadu.n1));
      //          } else if (de.getBead(beadu.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, beadu.n2));
      //          }
      //          if (de.getBead(beadn.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.n2, beadn.n1));
      //          } else if (de.getBead(beadn.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.n2, beadn.n2));
      //          }
      //          //bandの分はn1からスタート?
      //        } else if (orie.orientation_greater(j.u2, j.u1)==1) {
      //          //反対の1面だけ違う色を貼りたい
      //          Bead bead=de.getBead(j.u2);
      //          if (de.getBead(bead.n2)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, bead.n1));
      //          } else if (de.getBead(bead.n1)==j) {
      //            get_region_from_Nbhd(new Nbhd(j.u2, bead.n2));
      //          }
      //        }
      //      }
      //    } else if (de.getBead(j.u2)==b) {
      //      //4個の場合分け
      //    }
      //  } else if (de.getBead(j.n2)==a) {
      //    if (de.getBead(j.u1)==b) {
      //      //4個の場合分け
      //    } else if (de.getBead(j.u2)==b) {
      //      //4個の場合分け
      //    }
      //  }
      //}



      nodeID=e.BNodeID;
      nodeRID=e.BNodeRID;
      //隣のregionをどうやって塗るか


      //同じことは二度やらない
      //同じものがなければtotal_colorに追加する
      //match_regionを使ってチェックして色が違ったら
    }
    return false;
  }

  int findBandJoint(region r, int p, int c) {
    int pID=p;
    int cID=c;
    int nID=-1;
    for (int repeat=0; repeat<r.de.points.size(); repeat++) {
      nID=r.de.getNextBead(pID, cID);
      if (nID==-1) {
        return -1;
      }
      Bead n=r.de.getBead(nID);
      if (n==null) {
        return -1;
      } else if (n.bandJoint) {
        return nID;
      } else if (n.Joint) {
        return -1;
      } else {
        pID=cID;
        cID=nID;
      }
    }
    return -1;
  }

  int edge_number(region r, Edge ed) {
    for (int e=0; e<r.dg.edges.size(); e++) {
      Edge ee=r.dg.edges.get(e);
      if (ee.ANodeID==ed.ANodeID&&ee.BNodeID==ed.BNodeID&&ee.ANodeRID==ed.ANodeRID&&ee.BNodeRID==ed.BNodeRID) {
        return e;
      }
      if (ee.BNodeID==ed.ANodeID&&ee.ANodeID==ed.BNodeID&&ee.BNodeRID==ed.ANodeRID&&ee.ANodeRID==ed.BNodeRID) {
        return e;
      }//
    }
    return -1;
  }
}