class seifert {
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
      //edgeの番号のBeadsの番号を知る方法
      Node ANode=r.dg.nodes.get(AnodeID);
      Node BNode=r.dg.nodes.get(BnodeID);
      Bead j=r.de.getBead(0);
      ;
      if (AnodeRID==1||AnodeRID==3) {
        nodeID=AnodeID;
        println("nodeIDは"+nodeID);
        j=r.de.getBead(ANode.pointID);
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
        j=r.de.getBead(BNode.pointID);
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
        break;
      }
      //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
      //oneRIDは1か3
      //anotherRIDは0か2
      if (anotherRID==0) {
        if (oneRID==1) {
          if (r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u1, j.u2)==1) {
            Bead n2=r.de.getBead(j.n2);
            if (r.de.getBead(n2.n1).Joint) {
              //j.n2とn2.n2をnbhdにして色を塗る
            } else if (r.de.getBead(n2.n2).Joint) {
              //j.n2とn2.n1をnbhdにして色を塗る
            }
          }
        } else if (oneRID==3) {
          if (r.orie.orientation_greater(j.n2, j.n1)==1&&r.orie.orientation_greater(j.u2, j.u1)==1) {
            Bead n2=r.de.getBead(j.n2);
            if (r.de.getBead(n2.n1).Joint) {
              //j.n2とn2.n2をnbhdにして色を塗る
            } else if (r.de.getBead(n2.n2).Joint) {
              //j.n2とn2.n1をnbhdにして色を塗る
            }
          }
        }
      } else if (anotherRID==2) {
        if (oneRID==1) {
          if (r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u1, j.u2)==1) {
            Bead n1=r.de.getBead(j.n1);
            if (r.de.getBead(n1.n1).Joint) {
              //j.n1とn1.n2をnbhdにして色を塗る
            } else if (r.de.getBead(n1.n2).Joint) {
              //j.n1とn1.n1をnbhdにして色を塗る
            }
          }
        } else if (oneRID==3) {
          if (r.orie.orientation_greater(j.n1, j.n2)==1&&r.orie.orientation_greater(j.u2, j.u1)==1) {
            Bead n1=r.de.getBead(j.n1);
            if (r.de.getBead(n1.n1).Joint) {
              //j.n1とn1.n2をnbhdにして色を塗る
            } else if (r.de.getBead(n1.n2).Joint) {
              //j.n1とn1.n1をnbhdにして色を塗る
            }
          }
        }
      }
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
}