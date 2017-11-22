class thinning {
  data_extract DE;
  int threshold;

  thinning(data_extract _de) {
    DE = _de;
    threshold=160;
    println("begin thinning");

    get_knot_from_img();
  }

  ////////////////////////////////////////////
  //
  //      void get_knot_from_img()
  //
  ////////////////////////////////////////////
  void get_knot_from_img() {
    println("start image scan");

    binarization();
    DE.nbhs.clear();
    DE.points.clear();

    get_edge_data_thinning();

    //if (!modify_edge_data()) {
    //  println("image scan error");
    //  return ;
    //} else {
    //  println("image scan success");
    //}
    ////print_Nbh();
    //draw_on=true;
    //scan_img=false;
    //get_graph_data();
    ////println("now adjust graph edge");
    //adjust_graph_edge();
    //draw_original=false;
    //draw_on_draw_edges=true;
    //draw_on_draw_bezier=false;
    //// modification mode
    //modification_mode=1;
    ////
    //for (int i=0; i<15; i++) {
    //  adjust_graph_data();
    //  minimize_edge_by_rLength();
    //  minimize_edge_by_angle0();
    //  adjust_graph_edge();
    //}
    //set_all_Node();
    println("get_knot_from_im() success");
  }

  /////////////////////////////////////////////////
  //
  //    binarization()
  //
  /////////////////////////////////////////////////
  void binarization() {
    DE.image.loadPixels();

    for (int x=0; x<DE.disp_wid; x++) {
      for (int y=0; y<DE.disp_hei; y++) {        
        DE.d[y][x]=0;
      }
    }

    for (int x=0; x<DE.disp_wid-2*DE.offset; x++) {
      for (int y=0; y<DE.disp_hei-2*DE.offset; y++) {        
        color dotC=DE.image.pixels[x+(DE.disp_wid-2*DE.offset)*y];
        // processing version ends//
        float col=red(dotC)+green(dotC)+blue(dotC);
        if (col<3*threshold) {
          DE.d[y+DE.offset][x+DE.offset]=1;
          if (y+1+DE.offset<DE.disp_hei) DE.d[y+1+DE.offset][x+DE.offset]=1;
          if (y-1>=0) DE.d[y-1+DE.offset][x+DE.offset]=1;
          if (x+1+DE.offset<DE.disp_wid) DE.d[y+DE.offset][x+1+DE.offset]=1;
          if (x-1>=0) DE.d[y+DE.offset][x-1+DE.offset]=1;
        }
      }
    }
  }

  void binarization_new() {
    int w=DE.disp_wid;
    int h=DE.disp_hei;
    DE.image.loadPixels();
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {        
        DE.d[y][x]=0;
      }
    }
    FloatList xr = new FloatList();
    FloatList xg = new FloatList();
    FloatList xb = new FloatList();
    IntList xm = new IntList();
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {        
        color c=DE.image.pixels[x+w*y];
        float r=red(c);
        float g=green(c);
        float b=blue(c);
        boolean loopbreak=false;
        for (int j=0; j<xm.size () && !loopbreak; j++) {
          if (abs(xr.get(j)-r)+abs(xg.get(j)-g)+abs(xb.get(j)-b)<30) {
            xm.add(j, 1);
            loopbreak=true;
          }
        }
        if (!loopbreak) {
          xr.append(r);
          xg.append(g);
          xb.append(b);
          xm.append(1);
          //println(r,g,b);
        }
      }
    }
    int max_m=0;
    float yr=0, yb=0, yg=0;
    for (int j=0; j<xm.size (); j++) {
      if (max_m<xm.get(j)) {
        yr=xr.get(j);
        yg=xg.get(j);
        yb=xb.get(j);
        max_m=xm.get(j);
      }
    }
    println("max", yr, yg, yb, max_m);
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {        
        color c=DE.image.pixels[x+w*y];
        if (abs(red(c)-yr)+abs(green(c)-yg)+abs(blue(c)-yb)<50) {
          DE.d[y][x]=0;
        } else {
          DE.d[y][x]=1;
        }
      }
    }
  }

  //////////////////////////////////
  void get_edge_data_thinning() {
    int w = DE.disp_wid;
    int h = DE.disp_hei;
    boolean cont=true;
    int contcount=0;
    do {
      cont = do_thinning();//
    } while ( contcount++ <50 && cont);//
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        if (DE.d[y][x]==1) {
          int c=0;
          if (x>0) {
            if (DE.d[y][x-1]==1) {
              c++;
            }
          } 
          if (x<w-1) {
            if (DE.d[y][x+1]==1) {
              c++;
            }
          }
          if (y>0) {
            if (DE.d[y-1][x]==1) {
              c++;
            }
          } 
          if (y<h-1) {
            if (DE.d[y+1][x]==1) {
              c++;
            }
          }
          if (c>=3 || c==1) {
            DE.addToPoints(x, y);
          }
        }
      }
    }
    // d_new is used in find_next_point_on_thinning_graph.
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        DE.d_new[y][x]=DE.d[y][x];
      }
    }
    // DE.points.size() may increase in this loop
    for (int p=0; p<DE.points.size(); p++) {
      find_next_point_on_thinning_graph(p);
    }
  }

  boolean do_thinning() {
    int w = DE.disp_wid;
    int h = DE.disp_hei;
    boolean cont=false;
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        DE.d_new[y][x]=DE.d[y][x];
      }
    }
    for (int p=0; p<4; p++) {
      for (int x=1; x<w-1; x++) {
        for (int y=1; y<h-1; y++) {
          if (DE.d[y][x]==1) {
            boolean c1=(DE.d[y-1][x-1]==1);
            boolean c2=(DE.d[y][x-1]==1);
            boolean c3=(DE.d[y+1][x-1]==1);
            boolean c4=(DE.d[y+1][x]==1);
            boolean c5=(DE.d[y+1][x+1]==1);
            boolean c6=(DE.d[y][x+1]==1);
            boolean c7=(DE.d[y-1][x+1]==1);
            boolean c8=(DE.d[y-1][x]==1);
            if (p==0) {
              if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
                DE.d_new[y][x]=0;
              }
              if (!c8 && !c1 && !c2 && c4 && c5 && c6) {
                DE.d_new[y][x]=0;
              }
              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
                DE.d_new[y][x]=0;
              }
            }
            if (p==1) {
              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
                DE.d_new[y][x]=0;
              }
              if (!c6 && !c7 && !c8 && c2 && c3 && c4) {
                DE.d_new[y][x]=0;
              }
              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
                DE.d_new[y][x]=0;
              }
            }
            if (p==2) {
              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
                DE.d_new[y][x]=0;
              }
              if (!c4 && !c5 && !c6 && c8 && c1 && c2) {
                DE.d_new[y][x]=0;
              }
              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
                DE.d_new[y][x]=0;
              }
            }
            if (p==3) {
              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
                DE.d_new[y][x]=0;
              }
              if (!c2 && !c3 && !c4 && c6 && c7 && c8) {
                DE.d_new[y][x]=0;
              }
              if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
                DE.d_new[y][x]=0;
              }
            }
          }
        }
      }
      cont=false;
      for (int x=0; x<w; x++) {
        for (int y=0; y<h; y++) {
          if (DE.d[y][x]!=DE.d_new[y][x]) {
            DE.d[y][x]=DE.d_new[y][x];
            cont=true;
          }
        }
      }
    }
    return cont;
  }

  void find_next_point_on_thinning_graph(int p) {
    int vx = int(DE.points.get(p).x+0.1);
    int vy = int(DE.points.get(p).y+0.1);
    DE.d_new[vy][vx]=0;
    step_on_thinning_graph(p, vx-1, vy, 0);
    step_on_thinning_graph(p, vx, vy-1, 0);
    step_on_thinning_graph(p, vx+1, vy, 0);
    step_on_thinning_graph(p, vx, vy+1, 0);
  }

  void step_on_thinning_graph(int p, int x, int y, int count) {
    int w = DE.disp_wid;
    int h = DE.disp_hei;
    if (x<0 || x>=w) {
      return;
    }
    if (y<0 || y>=h) {
      return;
    }
    if (!DE.is_Beads_id(p)) {
      return ;
    }
    if (DE.d_new[y][x]==0) {
      return ;
    }
    for (int q=0; q<DE.points.size(); q++) {
      if (x==int(DE.points.get(q).x+0.1) && y==int(DE.points.get(q).y+0.1) ) {
        DE.addToNbh_WithoutCheck(p, q);
        return ;
      }
    }
    if (count==10) {
      int q = DE.addToPoints(x, y);
      DE.addToNbh_WithoutCheck(p, q);
      count=0;
      p=q;
      return;
    }
    DE.d_new[y][x]=0;
    step_on_thinning_graph(p, x-1, y, count+1);
    step_on_thinning_graph(p, x, y-1, count+1);
    step_on_thinning_graph(p, x+1, y, count+1);
    step_on_thinning_graph(p, x, y+1, count+1);
  }
}