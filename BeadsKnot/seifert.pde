class seifert {
  ArrayList <region> reg;
  seifert() {
    reg=new ArrayList<region>();
  }
  void find_nbhd_region(region r) {
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
                  get_region_from_Nbhd(new Nbhd(j.u2, beadu.n1));
                } else if (de.getBead(beadu.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, beadu.n2));
                }
                if (de.getBead(beadn.n2)==j) {
                  get_region_from_Nbhd(new Nbhd(j.n2, beadn.n1));
                } else if (de.getBead(beadn.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.n2, beadn.n2));
                }
                //bandの分はn1からスタート?
              } else if (orie.orientation_greater(j.u1, j.u2)==1) {
                //反対の1面だけ違う色を貼りたい
                Bead bead=de.getBead(j.u2);
                if (de.getBead(bead.n2)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, bead.n1));
                } else if (de.getBead(bead.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, bead.n2));
                }
              }
            } else if (orie.orientation_greater(j.n1, j.n2)==1) {
              if (orie.orientation_greater(j.u1, j.u2)==1) {
                //bandも入れると3面貼りたい(band以外同じ色)
                Bead beadu=de.getBead(j.u2);
                Bead beadn=de.getBead(j.n2);
                if (de.getBead(beadu.n2)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, beadu.n1));
                } else if (de.getBead(beadu.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, beadu.n2));
                }
                if (de.getBead(beadn.n2)==j) {
                  get_region_from_Nbhd(new Nbhd(j.n2, beadn.n1));
                } else if (de.getBead(beadn.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.n2, beadn.n2));
                }
                //bandの分はn1からスタート?
              } else if (orie.orientation_greater(j.u2, j.u1)==1) {
                //反対の1面だけ違う色を貼りたい
                Bead bead=de.getBead(j.u2);
                if (de.getBead(bead.n2)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, bead.n1));
                } else if (de.getBead(bead.n1)==j) {
                  get_region_from_Nbhd(new Nbhd(j.u2, bead.n2));
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