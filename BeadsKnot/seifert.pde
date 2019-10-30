class seifert { //<>// //<>// //<>// //<>//
  ArrayList <region> reg;
  data_extract de;
  data_graph dg;
  orientation orie;
  mouseDrag mouse;
  seifert(data_extract _de, data_graph _dg, orientation _orie, mouseDrag _mouse) {
    reg=new ArrayList<region>();
    de=_de;
    dg=_dg;
    orie=_orie;
    mouse=_mouse;
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
        oneRID=AnodeRID;
        //println("nodeIDは"+nodeID);
        //println("oneRIDは"+oneRID);
        nodePointID=ANode.pointID;
        j=r.de.getBead(ANode.pointID);
        for (int n=0; n<4; n++) {
          nodeRID[n]=j.get_un12(n);
        }
        for (Edge ed : r.border) {
          if (ed.ANodeID==nodeID) {
            if (ed.ANodeRID==0||ed.ANodeRID==2) {
              anotherRID=ed.ANodeRID;
              //println("anotherRIDは"+anotherRID);
              break;
            }
          } 
          if (ed.BNodeID==nodeID) {
            if (ed.BNodeRID==0||ed.BNodeRID==2) {
              anotherRID=ed.BNodeRID;
              //println("anotherRIDは"+anotherRID);
              break;
            }
          }
        }
      } else if (BnodeRID==1||BnodeRID==3) {
        nodeID=BnodeID;
        oneRID=BnodeRID;
        // println("nodeIDは"+nodeID);
        // println("oneRIDは"+oneRID);
        nodePointID=BNode.pointID;
        j=r.de.getBead(BNode.pointID);
        for (int n=0; n<4; n++) {
          nodeRID[n]=j.get_un12(n);
        }
        for (Edge ed : r.border) {
          if (ed.ANodeID==nodeID) {
            if (ed.ANodeRID==0||ed.ANodeRID==2) {
              anotherRID=ed.ANodeRID;
              //println("anotherRIDは"+anotherRID);
              break;
            }
          } 
          if (ed.BNodeID==nodeID) {
            if (ed.BNodeRID==0||ed.BNodeRID==2) {
              anotherRID=ed.BNodeRID;
              // println("anotherRIDは"+anotherRID);
              break;
            }
          }
        }
      } else {
      }
      //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
      //oneRIDは1か3
      //anotherRIDは0か2
      if (j.Joint) {
        if ( !r.orie.inUse) {
          r.orie.decide_orientation();//bandJoint対応が見たいおう
        }
        Bead jn1=r.de.getBead(j.n1);
        Bead jn2=r.de.getBead(j.n2);
        Bead ju1=r.de.getBead(j.u1);
        Bead ju2=r.de.getBead(j.u2);
        int n_orie=r.orie.orientation_greater(jn2.orientation, jn1.orientation);
        int u_orie=r.orie.orientation_greater(ju2.orientation, ju1.orientation);
        int findbandJointID[]=new int[5];
        for (int n=0; n<4; n++) {
          int k=findBandJoint(r, nodePointID, nodeRID[n]);
          findbandJointID[n]=k;
          if (k!=-1) {
            //println("findbandJointは"+k);
            //println("そのときのnodePointIDは"+nodePointID);
            //println("そのときのnodeRID["+n+"]は"+nodeRID[n]);
            // edge_number(r, );
            //edge番号を返す関数を呼ぶ
            //get_edgesでedgeをaddしている
            //返されたedge番号と一致しているかどうかを判定する関数を呼ぶ
          }
        }
        findbandJointID[4]=findbandJointID[0];
        int bandJoint_oneRID=-1;
        // int bandJoint_anotherRID=-1;
        for (int ed=0; ed<r.dg.edges.size(); ed++) {
          Edge ee=r.dg.edges.get(ed);
          Node ndA=r.dg.nodes.get(ee.ANodeID);
          Node ndB=r.dg.nodes.get(ee.BNodeID);
          for (int n=0; n<4; n++) {
            if (findbandJointID[n]==ndA.pointID&&findbandJointID[n+1]==ndB.pointID) {
              //println("発見1,bandJoint_oneRIDは", bandJoint_oneRID);
              //discover_bandJoint=true;
              bandJoint_oneRID=n;
              //bandJoint_anotherRID=n+1;
            }
            if (findbandJointID[n]==ndB.pointID&&findbandJointID[n+1]==ndA.pointID) {
              //println("発見2,bandJoint_oneRIDは", bandJoint_oneRID);
              bandJoint_oneRID=n;
              //bandJoint_anotherRID=n+1;
            }
            // println(ndA.pointID, ndB.pointID, ee.ANodeRID, ee.BNodeRID);
          }
        }
        //  println("oneRID"+oneRID, "anotherRID"+anotherRID, "n_orie"+n_orie, "u_orie"+ u_orie);
        if (anotherRID==0) {
          if (oneRID==1) {
            if (n_orie==1) {
              if (u_orie==1) {
                //1,0,1,1
                println("1,0,1,1");
                // println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=col;
                  check_color(newR3);
                }
              } else if (u_orie==-1) {
                //1,0,1,-1
                println("1,0,1,-1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                }
              }
            } else if (n_orie==-1) {
              if (u_orie==1) {
                //1,0,-1,1
                println("1,0,-1,1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                }
              } else if (u_orie==-1) {
                //1,0,-1,-1
                println("1,0,-1,-1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=col;
                  check_color(newR3);
                }
              }
            }
          } else if (oneRID==3) {
            if (n_orie==1) {
              if (u_orie==1) {
                //3,0,1,1
                println("3,0,1,1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                }
              } else if (u_orie==-1) {
                //3,0,1,-1
                println("3,0,1,-1");     
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                }
              }
            } else if (n_orie==-1) {
              if (u_orie==1) {
                //3,0,-1,1
                println("3,0,-1,1");
                // println("bandJoint_oneRID", bandJoint_oneRID);  
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                }
              } else if (u_orie==-1) {
                //3,0,-1,-1
                println("3,0,-1,-1");
                println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                }
              }
            }
          }
        } else if (anotherRID==2) {
          if (oneRID==1) {
            if (n_orie==1) {
              if (u_orie==1) {
                //1,2,1,1
                println("1,2,1,1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                }
              } else if (u_orie==-1) {
                //1,2,1,-1
                println("1,2,1,-1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                }
              }
            } else if (n_orie==-1) {
              if (u_orie==1) {
                //1,2,-1,1
                println("1,2,-1,1");
                // println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                }
              } else if (u_orie==-1) {
                //1,2,-1,-1
                println("1,2,-1,-1");
                // println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==1||bandJoint_oneRID==3) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==0) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR2.col_code=col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==2) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.n2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                }
              }
            }
          } else if (oneRID==3) {
            if (n_orie==1) {
              if (u_orie==1) {
                //3,2,1,1
                println("3,2,1,1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR.col_code=col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=col;
                  check_color(newR3);
                }
              } else if (u_orie==-1) {
                //3,2,1,-1
                println("3,2,1,-1");
                // println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                }
              }
            } else if (n_orie==-1) {
              if (u_orie==1) {
                /////////////3,2,-1,1
                println("3,2,-1,1");
                //println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR=new region(r.de, r.dg, r.orie);
                  newR.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR.col_code=3-col;
                  check_color(newR);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=3-col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                }
              } else if (u_orie==-1) {
                //////////////3,2,-1,-1
                println("3,2,-1,-1");
                // println("bandJoint_oneRID", bandJoint_oneRID);
                if (bandJoint_oneRID==0||bandJoint_oneRID==2) {
                  println("間違えている");
                } else if (bandJoint_oneRID==-1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  //region newR2=new region(r.de, r.dg, r.orie);
                  //newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  //newR2.col_code=col;
                  //check_color(newR2);
                } else if (bandJoint_oneRID==1) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=3-col;
                  check_color(newR3);
                } else if (bandJoint_oneRID==3) {
                  int col=r.col_code;
                  region newR1=new region(r.de, r.dg, r.orie);
                  newR1.get_region_from_Nbhd(new Nbhd(nodePointID, j.n1), true);
                  newR1.col_code=col;
                  check_color(newR1);
                  region newR2=new region(r.de, r.dg, r.orie);
                  newR2.get_region_from_Nbhd(new Nbhd(nodePointID, j.u2), true);
                  newR2.col_code=3-col;
                  check_color(newR2);
                  region newR3=new region(r.de, r.dg, r.orie);
                  newR3.get_region_from_Nbhd(new Nbhd(nodePointID, j.u1), true);
                  newR3.col_code=col;
                  check_color(newR3);
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
  }
  //boolean determine_color(region r) {
  //ArrayList <region> total_color=new ArrayList<region>();
  //for (Edge e : r.border) {
  //int nodeID=e.ANodeID;
  //int nodeRID=e.ANodeRID;
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



  //nodeID=e.BNodeID;
  //nodeRID=e.BNodeRID;
  //隣のregionをどうやって塗るか


  //同じことは二度やらない
  //同じものがなければtotal_colorに追加する
  //match_regionを使ってチェックして色が違ったら
  //}
  //return false;
  //}

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

  void check_color(region r) {
    //newRとregでつじつまがあうかを確認する
    //reg一つ一つ見てみてnewRと同じregionでcol_codeが一致したら何もしない
    //reg一つ一つ見てみてnewRと同じregionでcol_codeが一致しなかったらエラーを出す
    //おなじregionで相手のcol_codeがoならcol_codeをコピー
    //同じregionがなかったらaddする
    //1と2が一致しなかったら不一致
    boolean match=false;
    for (int re=0; re<reg.size(); re++) {
      if (reg.get(re).match_region(r)) {
        match=true;
        if (reg.get(re).col_code==0) {
          r.col_code=reg.get(re).col_code;
        } else if (reg.get(re).col_code==r.col_code) {
          //何もしない
        } else {
          println("塗り方が間違っている");
        }
      }
    }
    if (!match) {
      reg.add(r);
      //println("addした！！！");
    }
  }
  void SeifertAlgorithm() {
    ArrayList<region> smoothingRegions=new ArrayList<region>(); 
    for (Edge e : dg.edges) {
      region r=GetSmoothingRegionFromEdges(e);
      boolean match=false;
      if (r!=null) {
        for (region r2 : smoothingRegions) {
          if (r2.match_region(r)) {
            match=true;
            break;
          }
        }
        if (!match) {
          //rの色を決める
          if (r.clockwise) {
            r.col_code=2;
          } else {
            r.col_code=1;
          }
          smoothingRegions.add(r);
          // seif.reg.add(r);//試しにアドしてみた。
        }
      }
    }
    //println(seif.reg.size());
    ////smoothingRegionsからseif.regを作る
    ////全部書き出して省く
    //bandJointをつける
    for (int i = 0; i < smoothingRegions.size(); i++) {
      region r = smoothingRegions.get(i);
      createBandEdges(r);
    }
    //smoothingRegionごとに、そこに含まれるregionを計算して色を塗る
    seif.reg.clear();
    for (int i = 0; i < smoothingRegions.size(); i++) {
      region sr = smoothingRegions.get(i);
      println("smoothing: ",sr.ToString());
      for (int j=0; j< sr.border.size(); j++) {
        Edge ed = sr.border.get(j);
        region re= GetRegionFromEdges(ed, sr.clockwise);
        // println(re.border.size());
        if (re == null) continue;
        boolean matchflag=false;
        for (region r2 : seif.reg) {
          if (r2.match_region(re)) {
            matchflag=true;
            break;
          }
        }
        if (!matchflag) {
          re.col_code=sr.col_code;
          println(re.ToString());
          seif.reg.add(re);
        }
      }
    }
    //bandEdgeごとに、そこに含まれるregionを計算して色を塗る
    for (int i = 0; i < dg.edges.size(); i++) {
      Edge ed = dg.edges.get(i);
      if(ed.bandEdge){
        println("found a band region", ed.bandColCode);
        region re = GetRegionFromEdges(ed, true);
        if(re != null){
          //println(re.ToString());
          re.col_code = (ed.bandColCode==1)? 2 : 1;
          seif.reg.add(re);
        }
      }
    }
  }

  region GetSmoothingRegionFromEdges(Edge startEdge) {
    region result=new region(de, dg, orie);
    //edgeはintの4つ組
    int nodeID=startEdge.ANodeID;
    int nodeRID=startEdge.ANodeRID;
    int nextNodeRID=-1;
    Edge nextEdge=null;
    float totalDecline = 0f;
    int APointId = dg.nodes.get(startEdge.ANodeID).pointID;
    int BPointId = dg.nodes.get(startEdge.BNodeID).pointID;
    Bead ANodeBead = de.getBead(APointId);
    Bead BNodeBead = de.getBead(BPointId);
    int APointRId = ANodeBead.get_un12(startEdge.ANodeRID);
    int BPointRId = BNodeBead.get_un12(startEdge.BNodeRID);
    int APointROri = de.getBead(APointRId).orientation;
    int BPointROri = de.getBead(BPointRId).orientation;
    if (APointROri<BPointROri) {
      nodeID=startEdge.BNodeID;
      nodeRID=startEdge.BNodeRID;
    }
    // do {
    for (int repeat=0; repeat<de.points.size(); repeat++) {
      Node node=dg.nodes.get(nodeID);
      if (node==null) {
        return null;
      }
      int nodeBeadID=node.pointID;
      Bead JointBead=de.getBead(nodeBeadID);
      if (JointBead==null) {
        return null;
      }
      if (JointBead.midJoint) {
        nextNodeRID=(nodeRID==0)?2:0;
      } else if (JointBead.Joint) {
        Bead n1Bead=de.getBead(JointBead.n1);
        Bead n2Bead=de.getBead(JointBead.n2);
        Bead u1Bead=de.getBead(JointBead.u1);
        Bead u2Bead=de.getBead(JointBead.u2);
        int n_orie=orie.orientation_greater(n2Bead.orientation, n1Bead.orientation);
        int u_orie=orie.orientation_greater(u2Bead.orientation, u1Bead.orientation);
        //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
        if (n_orie*u_orie>0) {
          if (nodeRID==0) {
            totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=3;
          } else if (nodeRID==1) {
            totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=2;
          } else if (nodeRID==2) {
            totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=1;
          } else if (nodeRID==3) {
            totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=0;
          }
        } else {
          if (nodeRID==0) {
            totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=1;
          } else if (nodeRID==1) {
            totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=0;
          } else if (nodeRID==2) {
            totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=3;
          } else if (nodeRID==3) {
            totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=2;
          }
        }
      }
      nextEdge=null;
      for (Edge e : dg.edges) {
        if (e.ANodeID==nodeID&&e.ANodeRID==nextNodeRID) {
          //println("e.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, nodeID, nextNodeRID);
          nextEdge=e;
          nodeID=e.BNodeID;
          nodeRID=e.BNodeRID;
          totalDecline+=getDeclination(e);
          break;
        } else if (e.BNodeID==nodeID&&e.BNodeRID==nextNodeRID) {
          //println("e.BNodeIDは"+e.BNodeID, "e.BNodeIDは"+e.BNodeRID, nodeID, nextNodeRID);
          nextEdge=e;
          nodeID=e.ANodeID;
          nodeRID=e.ANodeRID;
          totalDecline-=getDeclination(e);
          break;
        }
      }
      // println(nodeID, nodeRID, nextNodeRID);
      if (nextEdge!=null) {
        result.border.add(nextEdge);
        if (nextEdge.matchEdge(startEdge)) {
          //println(totalDecline);
          result.clockwise=(totalDecline>0)?true:false;
          return result;
        }
      }
    } 
    //while (!nextEdge.matchEdge(startEdge));
    //result.clockwise=(totalDecline>0)?true:false;
    //return result;
    return null;
  }


  region GetRegionFromEdges(Edge startEdge, boolean clockwise) {
    //println("GetRegionFromEdgs start");
    boolean cw=clockwise;
    //int APointId = dg.nodes.get(startEdge.ANodeID).pointID;
    //int BPointId = dg.nodes.get(startEdge.BNodeID).pointID;
    //Bead ANodeBead = de.getBead(APointId);
    //Bead BNodeBead = de.getBead(BPointId);
    //int APointRId = ANodeBead.get_un12(startEdge.ANodeRID);
    //int BPointRId = BNodeBead.get_un12(startEdge.BNodeRID);
    //int APointROri = de.getBead(APointRId).orientation;
    //int BPointROri = de.getBead(BPointRId).orientation;
    //println(APointROri, BPointROri, clockwise);
    //時計回りのときに右に曲がるのが正しい
    region result=new region(de, dg, orie);
    //　向きはANode,BNodeに織り込み済み
    int nodeID=startEdge.ANodeID;
    int nodeRID=startEdge.ANodeRID;
    int nextNodeRID=-1;
    Edge nextEdge=null;
    for (int repeat=0; repeat<de.points.size(); repeat++) {
      Node node=dg.nodes.get(nodeID);
      if (node==null) {
        return null;
      }
      // println(node.x, node.y);
      int nodeBeadID=node.pointID;
      Bead JointBead=de.getBead(nodeBeadID);
      if (JointBead==null) {
        return null;
      }
      if (JointBead.midJoint) {
        nextNodeRID=(nodeRID==0)?2:0;
      } else if (JointBead.Joint  || JointBead.bandJoint) {
        if (cw) {//右折
          nextNodeRID=(nodeRID+1)%4;
          if(JointBead.get_un12(nextNodeRID)<0){
            nextNodeRID=(nextNodeRID+1)%4;;
          }
        } else {// 左折
          nextNodeRID=(nodeRID+3)%4;
          if(JointBead.get_un12(nextNodeRID)<0){
            nextNodeRID=(nextNodeRID+3)%4;;
          }
        }
      }
      nextEdge=null;
      for (Edge e : dg.edges) {
        if (e.ANodeID==nodeID&&e.ANodeRID==nextNodeRID) {
          //println("e.ANodeIDは"+e.ANodeID, "e.ANodeRIDは"+e.ANodeRID, nodeID, nextNodeRID);
          nextEdge=e;
          nodeID=e.BNodeID;
          nodeRID=e.BNodeRID;
          break;
        } else if (e.BNodeID==nodeID&&e.BNodeRID==nextNodeRID) {
          nextEdge=e;
          nodeID=e.ANodeID;
          nodeRID=e.ANodeRID;
          break;
        }
      }
      // println(nodeID, nodeRID, nextNodeRID);
      if (nextEdge!=null) {
        result.border.add(nextEdge);
        if (nextEdge.matchEdge(startEdge)) {
          return result;
        }
      }
    } 
    return null;
  }

  void createBandEdges(region r) {
    //region result=new region(de, dg, orie);
    //edgeはintの4つ組
    for (int repeat=0; repeat<r.border.size(); repeat++) {
      Edge startEdge = r.border.get(repeat);
      boolean clockwise = r.clockwise;
      int nodeID=startEdge.ANodeID;
      int nodeRID=startEdge.ANodeRID;
      int nextNodeRID=-1;
      //Edge nextEdge=null;
      // float totalDecline = 0f;
      int APointId = dg.nodes.get(startEdge.ANodeID).pointID;
      int BPointId = dg.nodes.get(startEdge.BNodeID).pointID;
      Bead ANodeBead = de.getBead(APointId);
      Bead BNodeBead = de.getBead(BPointId);
      int APointRId = ANodeBead.get_un12(startEdge.ANodeRID);
      int BPointRId = BNodeBead.get_un12(startEdge.BNodeRID);
      int APointROri = de.getBead(APointRId).orientation;
      int BPointROri = de.getBead(BPointRId).orientation;
      if (APointROri<BPointROri) {
        nodeID=startEdge.BNodeID;
        nodeRID=startEdge.BNodeRID;
      }
      // do {
      Node node=dg.nodes.get(nodeID);
      if (node==null) {
        return;
      }
      int nodeBeadID=node.pointID;
      Bead JointBead=de.getBead(nodeBeadID);
      if (JointBead==null) {
        return;
      }
      if (JointBead.midJoint) {
        nextNodeRID=(nodeRID==0)?2:0;
      } else if (JointBead.Joint) {
        Bead n1Bead=de.getBead(JointBead.n1);
        Bead n2Bead=de.getBead(JointBead.n2);
        Bead u1Bead=de.getBead(JointBead.u1);
        Bead u2Bead=de.getBead(JointBead.u2);
        int n_orie=orie.orientation_greater(n2Bead.orientation, n1Bead.orientation);
        int u_orie=orie.orientation_greater(u2Bead.orientation, u1Bead.orientation);
        //orientation_greater(int o1, int o2) {// if o1>o2 then return 1;
        if (n_orie*u_orie>0) {
          if (nodeRID==0) {
            //totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=3;
            if (clockwise) {
              println(JointBead.n1, JointBead.u2);
              println(nthree_neighbors(JointBead.n1, nodeBeadID));
              println(uthree_neighbors(JointBead.u2, nodeBeadID));
              addABandEdge(nodeID, nextNodeRID, r.col_code);
              // Bead b=de.getBead(nthree_neighbors(JointBead.n1, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u2, nodeBeadID));
              // b2.bandJoint=true;
            }
          } else if (nodeRID==1) {
            //totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=2;
            if (!clockwise) {
              // println(JointBead.n2, JointBead.u1);
              println(nthree_neighbors(JointBead.n2, nodeBeadID));
              println(uthree_neighbors(JointBead.u1, nodeBeadID));
              addABandEdge(nodeID, nodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n2, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u1, nodeBeadID));
              //b2.bandJoint=true;
            }
          } else if (nodeRID==2) {
            // totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=1;
            if (clockwise) {
              //println(JointBead.n2, JointBead.u1);
              println(nthree_neighbors(JointBead.n2, nodeBeadID));
              println(uthree_neighbors(JointBead.u1, nodeBeadID));
              addABandEdge(nodeID, nextNodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n2, nodeBeadID));
              // b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u1, nodeBeadID));
              //b2.bandJoint=true;
            }
          } else if (nodeRID==3) {
            // totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=0;
            if (!clockwise) {
              //println(JointBead.n1, JointBead.u2);
              println(nthree_neighbors(JointBead.n1, nodeBeadID));
              println(uthree_neighbors(JointBead.u2, nodeBeadID));
              addABandEdge(nodeID, nodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n1, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u2, nodeBeadID));
              //b2.bandJoint=true;
            }
          }
        } else {
          if (nodeRID==0) {
            //totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=1;
            if (!clockwise) {
              // println(JointBead.n1, JointBead.u1);
              println(nthree_neighbors(JointBead.n1, nodeBeadID));
              println(uthree_neighbors(JointBead.u1, nodeBeadID));
              addABandEdge(nodeID, nodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n1, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u1, nodeBeadID));
              //b2.bandJoint=true;
            }
          } else if (nodeRID==1) {
            // totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=0;
            if (clockwise) {
              // println(JointBead.n1, JointBead.u1);
              println(nthree_neighbors(JointBead.n1, nodeBeadID));
              println(uthree_neighbors(JointBead.u2, nodeBeadID));
              addABandEdge(nodeID, nextNodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n1, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u2, nodeBeadID));
              //b2.bandJoint=true;
            }
          } else if (nodeRID==2) {
            //totalDecline += (PI/2);
            //print("right ");
            nextNodeRID=3;
            if (!clockwise) {
              // println(JointBead.n2, JointBead.u2);
              println(nthree_neighbors(JointBead.n2, nodeBeadID));
              println(uthree_neighbors(JointBead.u2, nodeBeadID));
              addABandEdge(nodeID, nodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n2, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u2, nodeBeadID));
              //b2.bandJoint=true;
            }
          } else if (nodeRID==3) {
            // totalDecline -= (PI/2);
            //print("left ");
            nextNodeRID=2;
            if (clockwise) {
              // println(JointBead.n2, JointBead.u2);
              println(nthree_neighbors(JointBead.n2, nodeBeadID));
              println(uthree_neighbors(JointBead.u2, nodeBeadID));
              addABandEdge(nodeID, nextNodeRID, r.col_code);
              //Bead b=de.getBead(nthree_neighbors(JointBead.n2, nodeBeadID));
              //b.bandJoint=true;
              //Bead b2=de.getBead(uthree_neighbors(JointBead.u2, nodeBeadID));
              //b2.bandJoint=true;
            }
          }
        }
      }
    } 
    return;
  }

  void addABandEdge(int nodeID, int rightRID, int colCode) {
    println("addABandEdge", nodeID, rightRID, colCode);
    int leftRID = (rightRID+1)%4; 
    // nodeID,rightRIDを含むエッジをeとする
    Edge e=GetEdgeByNode(nodeID, rightRID);
    if (e==null) return;
    // ノードから2番目のビーズb2、3番目のビーズb3を得る。ビーズ番号はそれぞれb2ID,b3ID。
    //（n,uで区別は不要かもしれない。）
    int nodeBeadID = dg.nodes.get(nodeID).pointID;
    Bead nodeBead = de.getBead(nodeBeadID);
    if (nodeBead == null) return;
    int b1ID = nodeBead.get_un12(rightRID);
    Bead b1 = de.getBead(b1ID);
    if (b1 == null) return;
    int b2ID = (b1.n1 == nodeBeadID) ? b1.n2: b1.n1;
    Bead b2 = de.getBead(b2ID);
    if (b2 == null) return;
    int b3ID = (b2.n1 == b1ID) ? b2.n2: b2.n1;
    Bead b3 = de.getBead(b3ID);
    if ( b3 == null) return;
    // b3をbandJointにする。
    b3.bandJoint = true;
    // b3の場所(b3.x, b3.y)にbandJointのためのノードnewRightBandNodeを新設する。
    Node newRightBandNode=new Node(b3.x, b3.y);
    newRightBandNode.pointID=b3ID;
    //Jointフラグはfalse,inUseフラグはtrueとする。
    newRightBandNode.Joint=false;
    newRightBandNode.inUse=true;
    // b3からみたb2の偏角をthetaパラメータに入れておく。
    newRightBandNode.theta = -atan2(b2.y-b3.y, b2.x-b3.x);
    // newRightBandNodeIDを「現状のノードの個数」とする。(次項との順番に注意。)
    int newRightBandNodeID=dg.nodes.size();
    // dg.nodesにnewRightBandNodeを追加する。(ノードは一つ増える。)
    dg.nodes.add(newRightBandNode);
    boolean rightB3n1_B2 = false, leftB3n1_B2 = false;
    if (e.ANodeID==nodeID&&e.ANodeRID==rightRID) {
      // エッジeをeとnewEdgeの二つに分割する。
      // ただし、ビーズb3からみたb2IDがn1なのかn2なのかに応じて、
      // これらエッジに含まれるRIDの値を調整する必要がある。
      if (b3.n1 == b2ID) {
        rightB3n1_B2 = true;
        e.ANodeID=newRightBandNodeID;
        e.ANodeRID=2;
        Edge newEdge=new Edge(newRightBandNodeID, 0, nodeID, rightRID);
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      } else {
        e.ANodeID=newRightBandNodeID;
        e.ANodeRID=0;//
        Edge newEdge=new Edge(newRightBandNodeID, 2, nodeID, rightRID);//
        //n1,n2の向きが逆なようなので一応thetaも変えておく
        newRightBandNode.theta += PI;
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      }
    } else if (e.BNodeID==nodeID&&e.BNodeRID==rightRID) {
      // エッジeをeとnewEdgeの二つに分割する。
      // ただし、ビーズb3からみたb2IDがn1なのかn2なのかに応じて、
      // これらエッジに含まれるRIDの値を調整する必要がある。
      if (b3.n1 == b2ID) {
        rightB3n1_B2 = true;
        e.BNodeID=newRightBandNodeID;
        e.BNodeRID=2;
        Edge newEdge=new Edge(newRightBandNodeID, 0, nodeID, rightRID);
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      } else {
        e.BNodeID=newRightBandNodeID;
        e.BNodeRID=0;//
        Edge newEdge=new Edge(newRightBandNodeID, 2, nodeID, rightRID);//
        //n1,n2の向きが逆なようなので一応thetaも変えておく
        newRightBandNode.theta += PI;
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      }
    }
    // dg.update_points();を実行する
    dg.modify();
    dg.update_points();
    dg.add_close_point_Joint();
    //以上の作業を(nodeID,leftID)についても行う。
    // nodeID,rightRIDを含むエッジをeとする
    e=GetEdgeByNode(nodeID, leftRID);
    if (e==null) return;
    // ノードから2番目のビーズb2、3番目のビーズb3を得る。ビーズ番号はそれぞれb2ID,b3ID。
    //（n,uで区別は不要かもしれない。）
    nodeBeadID = dg.nodes.get(nodeID).pointID;
    nodeBead = de.getBead(nodeBeadID);
    if (nodeBead == null) return;
    b1ID = nodeBead.get_un12(leftRID);
    b1 = de.getBead(b1ID);
    if (b1 == null) return;
    b2ID = (b1.n1 == nodeBeadID) ? b1.n2: b1.n1;
    b2 = de.getBead(b2ID);
    if (b2 == null) return;
    b3ID = (b2.n1 == b1ID) ? b2.n2: b2.n1;
    b3 = de.getBead(b3ID);
    if ( b3 == null) return;
    // b3をbandJointにする。
    b3.bandJoint = true;
    // b3の場所(b3.x, b3.y)にbandJointのためのノードnewRightBandNodeを新設する。
    Node newLeftBandNode=new Node(b3.x, b3.y);
    newLeftBandNode.pointID=b3ID;
    //Jointフラグはfalse,inUseフラグはtrueとする。
    newLeftBandNode.Joint=false;
    newLeftBandNode.inUse=true;
    // b3からみたb2の偏角をthetaパラメータに入れておく。
    newLeftBandNode.theta = -atan2(b2.y-b3.y, b2.x-b3.x);
    // newRightBandNodeIDを「現状のノードの個数」とする。(次項との順番に注意。)
    int newLeftBandNodeID=dg.nodes.size();
    // dg.nodesにnewRightBandNodeを追加する。(ノードは一つ増える。)
    dg.nodes.add(newLeftBandNode);
    if (e.ANodeID==nodeID&&e.ANodeRID==leftRID) {
      // エッジeをeとnewEdgeの二つに分割する。
      // ただし、ビーズb3からみたb2IDがn1なのかn2なのかに応じて、
      // これらエッジに含まれるRIDの値を調整する必要がある。
      if (b3.n1 == b2ID) {
        leftB3n1_B2 = true;
        e.ANodeID=newLeftBandNodeID;
        e.ANodeRID=2;
        Edge newEdge=new Edge(newLeftBandNodeID, 0, nodeID, leftRID);
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      } else {
        e.ANodeID=newLeftBandNodeID;
        e.ANodeRID=0;//
        Edge newEdge=new Edge(newLeftBandNodeID, 2, nodeID, leftRID);//
        //n1,n2の向きが逆なようなので一応thetaも変えておく
        newLeftBandNode.theta += PI;
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      }
    } else if (e.BNodeID==nodeID&&e.BNodeRID==leftRID) {
      // エッジeをeとnewEdgeの二つに分割する。
      // ただし、ビーズb3からみたb2IDがn1なのかn2なのかに応じて、
      // これらエッジに含まれるRIDの値を調整する必要がある。
      if (b3.n1 == b2ID) {
        leftB3n1_B2 = true;
        e.BNodeID=newLeftBandNodeID;
        e.BNodeRID=2;
        Edge newEdge=new Edge(newLeftBandNodeID, 0, nodeID, leftRID);
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      } else {
        e.BNodeID=newLeftBandNodeID;
        e.BNodeRID=0;//
        Edge newEdge=new Edge(newLeftBandNodeID, 2, nodeID, leftRID);//
        //n1,n2の向きが逆なようなので一応thetaも変えておく
        newLeftBandNode.theta += PI;
        // newEdgeをdg.edgesへ追加する。
        dg.edges.add(newEdge);
      }
    }
    // dg.update_points();を実行する
    dg.modify();
    dg.update_points();
    dg.add_close_point_Joint();
    // newRightBandNodeとnewLeftBandNodeをつなぐようなbandEdgeを追加する。
    //このとき、これらのNodeの枝の付け替えを行う。（詳細未定）
    //bandEdgeの中点に相当するbeadを一つ追加する（一つで十分らしい）場所は二つのノードの中点。
    Bead rightBandBead = de.getBead(newRightBandNode.pointID);
    Bead leftBandBead = de.getBead(newLeftBandNode.pointID);
    Bead newBandEdgeBead = new Bead((rightBandBead.x + leftBandBead.x)*0.5, (rightBandBead.y + leftBandBead.y)*0.5);
    newBandEdgeBead.n1 = newRightBandNode.pointID;
    newBandEdgeBead.n2 = newLeftBandNode.pointID;
    newBandEdgeBead.c = 2;
    int newBandEdgeBeadID = de.points.size();
    de.points.add(newBandEdgeBead);
    // このビーズをつなぐためのエッジを追加する。
    Edge newBandEdge = new Edge(newRightBandNodeID, (rightB3n1_B2? 0 : 2), newLeftBandNodeID, (leftB3n1_B2? 0 : 2));
    newBandEdge.bandEdge = true;//これを追加
    newBandEdge.bandColCode = colCode;//これを追加
    dg.edges.add(newBandEdge);
    // rightBandBeadのビーズつながりを調節する。
    if (rightB3n1_B2) {
      rightBandBead.u1 = rightBandBead.n1;
      rightBandBead.n1 = newBandEdgeBeadID;
    } else {
      rightBandBead.u2 = rightBandBead.n2;
      rightBandBead.n2 = newBandEdgeBeadID;
    }
    rightBandBead.c = 3;
    // leftBandBeadのビーズつながりを調節する。
    if (leftB3n1_B2) {
      leftBandBead.u2 = leftBandBead.n1;
      leftBandBead.n1 = newBandEdgeBeadID;
    } else {
      leftBandBead.u1 = leftBandBead.n2;
      leftBandBead.n2 = newBandEdgeBeadID;
    }
    leftBandBead.c = 3;
    /////
    // bandのための短いEdgeの番号を付け替える
    for (int i=0; i<dg.edges.size(); i++) {
      Edge ed = dg.edges.get(i);
      if (rightB3n1_B2) {
        if (ed.ANodeID==newRightBandNodeID && ed.ANodeRID == 0) {
          ed.ANodeRID = 1;
          break;
        }
        if (ed.BNodeID==newRightBandNodeID && ed.BNodeRID == 0) {
          ed.BNodeRID = 1;
          break;
        }
      } else {
        if (ed.ANodeID==newRightBandNodeID && ed.ANodeRID == 2) {
          ed.ANodeRID = 3;
          break;
        }
        if (ed.BNodeID==newRightBandNodeID && ed.BNodeRID == 2) {
          ed.BNodeRID = 3;
          break;
        }
      }
    }
    for (int i=0; i<dg.edges.size(); i++) {
      Edge ed = dg.edges.get(i);
      if (leftB3n1_B2) {
        if (ed.ANodeID == newLeftBandNodeID && ed.ANodeRID == 0) {
          ed.ANodeRID = 3;
          break;
        }
        if (ed.BNodeID == newLeftBandNodeID && ed.BNodeRID == 0) {
          ed.BNodeRID = 3;
          break;
        }
      } else {
        if (ed.ANodeID == newLeftBandNodeID && ed.ANodeRID == 2) {
          ed.ANodeRID = 1;
          break;
        }
        if (ed.BNodeID == newLeftBandNodeID && ed.BNodeRID == 2) {
          ed.BNodeRID = 1;
          break;
        }
      }
    }
    //////
    // dg.update_points();を実行する
    dg.modify();
    dg.update_points();
    dg.add_close_point_Joint();
  }

  int nthree_neighbors(int n, int nodeBeadID) {
    Bead JointBead=de.getBead(nodeBeadID);
    Bead b=de.getBead(n);//JointBead
    if (b.n1==nodeBeadID) {
      Bead b1=de.getBead(b.n2);
      if (b1.n1==JointBead.n1||b1.n1==JointBead.n2) {
        return b1.n2;
      } else {
        return b1.n1;
      }
    } else {
      Bead b2=de.getBead(b.n1);
      if (b2.n1==JointBead.n1||b2.n1==JointBead.n2) {
        return b2.n2;
      } else {
        return b2.n1;
      }
    }
  }

  int uthree_neighbors(int u, int nodeBeadID) {
    //u=JointBead.u2
    //Bead JointBead=de.getBead(nodeBeadID);
    Bead b=de.getBead(u);//JointBead
    if (b.n1==nodeBeadID) {
      Bead b1=de.getBead(b.n2);
      if (b1.n1==u) {
        Bead b2=de.getBead(b1.n2);
        if (b2.n1==b.n1||b2.n1==b.n2) {
          return b2.n2;
        } else {
          return b2.n1;
        }
      } else {
        Bead b3=de.getBead(b1.n1);
        if (b3.n1==b.n1||b3.n1==b.n2) {
          return b3.n2;
        } else {
          return b3.n1;
        }
      }
    } else {
      Bead b4=de.getBead(b.n1);
      if (b4.n1==u) {
        Bead b5=de.getBead(b4.n2);
        if (b5.n1==b.n1||b5.n1==b.n2) {
          return b5.n2;
        } else {
          return b5.n1;
        }
      } else {
        Bead b6=de.getBead(b4.n1);
        if (b6.n1==b.n1||b6.n1==b.n2) {
          return b6.n2;
        } else {
          return b6.n1;
        }
      }
    }
  }

  Edge GetEdgeByNode(int ID, int RID) {
    for (int i=0; i<dg.edges.size(); i++) {
      Edge e=dg.edges.get(i);
      if (e.ANodeID==ID&&e.ANodeRID==RID) {
        return e;
      }
      if (e.BNodeID==ID&&e.BNodeRID==RID) {
        return e;
      }
    }
    return null;
  }



  float getDeclination(Edge e) {
    Node ANode = dg.nodes.get(e.ANodeID);
    Node BNode = dg.nodes.get(e.BNodeID);
    if (ANode ==null || BNode== null ) {
      return 0f;
    }
    Bead ANodeBead = de.getBead(ANode.pointID);
    if (ANodeBead == null) {
      return 0f;
    }
    int prev = ANode.pointID;
    int now = ANodeBead.get_un12(e.ANodeRID);
    int next=-1;
    Bead prevBead = de.getBead(prev);
    Bead nowBead = de.getBead(now);
    if (nowBead == null) {
      return 0f; // error
    }
    float prevX = prevBead.x;
    float prevY = prevBead.y;
    float nowX  = nowBead.x;
    float nowY  = nowBead.y;
    float startDecline = atan2(nowY-prevY, nowX-prevX);
    float nowDecline = startDecline;
    float modify = 0f;
    for (int i=0; i<de.points.size(); i++) {
      if (nowBead.n1 == prev) {
        next = nowBead.n2;
      } else if (nowBead.n2 == prev) {
        next = nowBead.n1;
      } else {
        return 0f;// error
      }
      Bead nextBead = de.getBead(next);
      if (nextBead == null) {
        return 0f; //error
      }
      float nextX = nextBead.x;
      float nextY = nextBead.y;
      float nextDecline = atan2(nextY-nowY, nextX-nowX);
      if (nextDecline < nowDecline - PI ) {
        modify += (2*PI);
      }
      if (nextDecline > nowDecline + PI ) {
        modify -= (2*PI);
      }
      if (next == BNode.pointID) {
        return nextDecline - startDecline + modify;
      }
      // 更新
      nowDecline = nextDecline;
      nowX=nextX;
      nowY=nextY;
      prev = now;
      now = next;
      nowBead = de.getBead(now);// no need to check to be an error
      // nowBead = nextBead;
    }
    return 0f; // error
  }
}