class Thinning{
	data_extract DE;
	int w,h;
	int d_new[][];

	ArrayList<Nbh> cross;

	Thinning(data_extract _de){
		DE=_de;
		w=DE.w;
		h=DE.h;
		d_new = new int[w][h];
		cross = new ArrayList<Nbh>();
	}

	boolean getThinningExtraction(){
		w=DE.w;
		h=DE.h;
	    DE.nbhs.clear();
	    DE.points.clear();
		// int de.d[w][h] を仮定してよい。
		get_edge_data_thinning();

		DE.countNbhs();

		println("cancel_loop()");
		cancel_loop() ;

		// println("find_crossing()");
		// find_crossing();		

		DE.getDisplayLTRB();
		println(DE.points.size(),DE.nbhs.size());
		//DE.extraction_binalized = true;
		DE.extraction_beads = true;
		return false;

	}

//////////////////////////////////
  	void get_edge_data_thinning() {
    	boolean cont=true;
    	int contcount=0;
    	do {
      		cont = do_thinning();//
    	} while ( contcount++ <50 && cont);//
    	for (int x=0; x<w; x++) {
    		for (int y=0; y<h; y++) {
    			if (DE.d[x][y]==1) {
    				int c=0;
    				if (x>0) {
    					if (DE.d[x][y-1]==1) {
    						c++;
    					}
    				}
    				if (x<w-1) {
    					if (DE.d[x][y+1]==1) {
    						c++;
    					}
    				}
    				if (y>0) {
    					if (DE.d[x-1][y]==1) {
    						c++;
    					}
    				}
    				if (y<h-1) {
    					if (DE.d[x+1][y]==1) {
    						c++;
    					}
    				}
    				if (c>=3 || c==1) {
    					int cc = addToPoints(x, y);
    					DE.points.get(cc).c = 2;
    				}
    			}
    		}
    	}
    	// d_new is used in find_next_point_on_thinning_graph.
    	for (int x=0; x<w; x++) {
    		for (int y=0; y<h; y++) {
    			d_new[x][y]=DE.d[x][y];
    		}
    	}
    	// DE.points.size() may increase in this loop
    	for (int p=0; p<DE.points.size(); p++) {
    		find_next_point_on_thinning_graph(p);
    	}
    }

    ////////////////////////////
	boolean do_thinning() {
	    boolean cont=false;
	    for (int x=0; x<w; x++) {
	      	for (int y=0; y<h; y++) {
	        	d_new[x][y]=DE.d[x][y];
	      	}
	    }
	    for (int p=0; p<4; p++) {
	      	for (int x=1; x<w-1; x++) {
	        	for (int y=1; y<h-1; y++) {
	          		if (DE.d[x][y]==1) {
	            		boolean c1=(DE.d[x-1][y-1]==1);
			            boolean c2=(DE.d[x][y-1]==1);
			            boolean c3=(DE.d[x+1][y-1]==1);
			            boolean c4=(DE.d[x+1][y]==1);
			            boolean c5=(DE.d[x+1][y+1]==1);
			            boolean c6=(DE.d[x][y+1]==1);
			            boolean c7=(DE.d[x-1][y+1]==1);
			            boolean c8=(DE.d[x-1][y]==1);
	           	 		if (p==0) {
	              			if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
	                			d_new[x][y]=0;
	              			}
				            if (!c8 && !c1 && !c2 && c4 && c5 && c6) {
				                d_new[x][y]=0;
				            }
				            if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
				                d_new[x][y]=0;
				            }
						}
						if (p==1) {
							if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
								d_new[x][y]=0;
							}
							if (!c6 && !c7 && !c8 && c2 && c3 && c4) {
								d_new[x][y]=0;
							}
							if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
								d_new[x][y]=0;
							}
						}
						if (p==2) {
							if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
								d_new[x][y]=0;
							}
							if (!c4 && !c5 && !c6 && c8 && c1 && c2) {
								d_new[x][y]=0;
							}
							if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
								d_new[x][y]=0;
							}
						}
						if (p==3) {
							if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
								d_new[x][y]=0;
							}
							if (!c2 && !c3 && !c4 && c6 && c7 && c8) {
								d_new[x][y]=0;
							}
							if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
								d_new[x][y]=0;
							}
						}
					}
				}
			}
			cont=false;
			for (int x=0; x<w; x++) {
				for (int y=0; y<h; y++) {
					if (DE.d[x][y]!=d_new[x][y]) {
						DE.d[x][y]=d_new[x][y];
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
		d_new[vx][vy]=0;
		step_on_thinning_graph(p, vx-1, vy, 0);
		step_on_thinning_graph(p, vx, vy-1, 0);
		step_on_thinning_graph(p, vx+1, vy, 0);
		step_on_thinning_graph(p, vx, vy+1, 0);
	}

	void step_on_thinning_graph(int p, int x, int y, int count) {
		if (x<0 || x>=w) {
			return;
		}
		if (y<0 || y>=h) {
			return;
		}
		if (!is_Beads_id(p)) {
			return ;
		}
		if (d_new[x][y]==0) {
			return ;
		}
		for (int q=0; q<DE.points.size(); q++) {
			if (x==int(DE.points.get(q).x+0.1) && y==int(DE.points.get(q).y+0.1) ) {
				addToNbh_WithoutCheck(p, q);
				return ;
			}
		}
		if (count==10) {
			int q = addToPoints(x, y);
			addToNbh_WithoutCheck(p, q);
			count=0;
			p=q;
			return;
		}
		d_new[x][y]=0;
		step_on_thinning_graph(p, x-1, y, count+1);
		step_on_thinning_graph(p, x, y-1, count+1);
		step_on_thinning_graph(p, x+1, y, count+1);
		step_on_thinning_graph(p, x, y+1, count+1);
	}
	
	boolean is_Beads_id(int num) {
   		return (0 <= num && num < DE.points.size());
	}

	int addToPoints(int _x, int _y) {
		if (_y>=h || _x>=w) {
			return -1;
		}
		if (DE.d[_x][_y]==0) {
			return -1;
		}
		// for (int i=0; i<DE.points.size (); i++) {
		// 	if (dist(_x, _y, DE.points.get(i).x, DE.points.get(i).y)<5) {
		// 		return i;
		// 	}
		// }
		DE.points.add(new Beads(_x, _y));
		return DE.points.size()-1;
	}

	boolean addToNbh_WithoutCheck(int i1, int i2) {
		if (!is_Beads_id(i1) || !is_Beads_id(i2)) {
			return false;
		}
		for (Nbh n : DE.nbhs) {
			if ( n.a==i1 && n.b==i2 ) {
				return  false;
			} else if ( n.a==i2 && n.b==i1 ) {
				return  false;
			}
		}
		if (i1==i2) {
			return  false;
		}
		//float d=abs(points.get(i1).x-points.get(i2).x)+abs(points.get(i1).y-points.get(i2).y);
		DE.nbhs.add(new Nbh(i1, i2));
		return true;
	}

////////////////////////////////////////////
//
//      calcel_loop()
//
////////////////////////////////////////////
	int[] pt_tag2 ;
	int[] pt_tag1 ;
	int[] pt_prev ;
	boolean[] pt_left ;
	boolean[] pt_treated ;
	boolean[] nbh_left ;
	int[][] pt_nhd ;
	int[][] pt_row ;
	int cancel_loop_phase=0;

	void cancel_loop() {
  		cancel_loop1();
  		cancel_loop2();
  		cancel_loop3();
	}


	void cancel_loop1() {//
  		cancel_loop_phase=1;
  		int pointsSize = DE.points.size();
  		pt_tag2 = new int[pointsSize];
  		pt_tag1 = new int[pointsSize];
  		pt_prev = new int[pointsSize];
		pt_left = new boolean[pointsSize];
		pt_treated = new boolean[pointsSize];
		nbh_left = new boolean[DE.nbhs.size()];
		pt_nhd = new int[pointsSize][4];
		pt_row = new int[pointsSize][4];
		for (int p=0; p<pointsSize; p++) {
			pt_tag2[p]=-1;
			pt_tag1[p]=-1;
			pt_prev[p]=-1;
			pt_left[p]=false;
			pt_treated[p]=false;
    		pt_nhd[p][0]=pt_nhd[p][1]=pt_nhd[p][2]=pt_nhd[p][3]=-1;
    		pt_row[p][0]=pt_row[p][1]=pt_row[p][2]=pt_row[p][3]=-1;
  		}
  		for (int n=0; n<DE.nbhs.size (); n++) {
			Nbh u = DE.nbhs.get(n);
    		for (int i=0; i<4; i++) {
      			if (pt_nhd[u.a][i]<0) {
        			pt_nhd[u.a][i] = u.b;
        			pt_row[u.a][i] = n;
        			break;
      			}
    		}
			for (int i=0; i<4; i++) {
				if (pt_nhd[u.b][i]<0) {
					pt_nhd[u.b][i] = u.a;
					pt_row[u.b][i] = n;
					break;
				}
			}
    		nbh_left[n]=false;
  		}
  		for (int p=0; p<DE.points.size (); p++) {
    		fill_pt_tag1(p, 1);
  		}
	}

	void cancel_loop2() {//
		cancel_loop_phase=2;
		int max, maxp, countp=DE.points.size();
		do {
			countp--;
			max=0;
			maxp=-1;
			for (int p=0; p<DE.points.size (); p++) {
				if ( pt_tag2[p]<0 && pt_tag1[p]>max) {
					max = pt_tag1[p];
					maxp = p;
				}
			}
			fill_pt_tag2(maxp, 1, -1);
		} 
		while (max>0 && countp>0);
	}

	void cancel_loop3() {//
		cancel_loop_phase=3;
		int max, maxp, countp=DE.points.size();
		do {
			countp--;
			max=0;
			maxp=-1;
			for (int p=0; p<DE.points.size (); p++) {
				if ( !pt_treated[p] && pt_tag2[p]>max) {
					max = pt_tag2[p];
					maxp = p;
				}
			}
			fill_pt_treated(maxp);
			if ( is_Beads_id(maxp) && DE.points.get(maxp).c>0) {
				for (int q=maxp; q!=-1; q=pt_prev[q]) {
					pt_left[q]=true;
				}
			}
		} while (max>0 && countp>0);
		for (int p=DE.points.size ()-1; p>=0; p--) {
			if ( !pt_left[p] ) {
				Beads u = DE.points.get(p);
				if (is_Beads_id(u.n1)) {
					Beads uo = DE.points.get(u.n1);
					uo.c --;
					if (uo.n1==p) { 
						uo.n1=uo.n2; uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.n2==p) { 
						uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.u1==p) { 
						uo.u1=uo.u2; uo.u2=-1;
					}
				}
				if (is_Beads_id(u.n2)) {
					Beads uo = DE.points.get(u.n2);
					uo.c --;
					if (uo.n1==p) { 
						uo.n1=uo.n2; uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.n2==p) { 
						uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.u1==p) { 
						uo.u1=uo.u2; uo.u2=-1;
					}
				}
				if (is_Beads_id(u.u1)) {
					Beads uo = DE.points.get(u.u1);
					uo.c --;
					if (uo.n1==p) { 
						uo.n1=uo.n2; uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.n2==p) { 
						uo.n2=uo.u1; uo.u1=uo.u2; uo.u2=-1;
					} else if (uo.u1==p) { 
						uo.u1=uo.u2; uo.u2=-1;
					}
				}
				DE.points.remove(p);
				for (int i=0; i<DE.points.size (); i++) {
					Beads v = DE.points.get(i);
					if (v.n1>p) v.n1--;
					if (v.n2>p) v.n2--;
					if (v.u1>p) v.u1--;
					if (v.u2>p) v.u2--;
				}
				for (int i=DE.nbhs.size ()-1; i>=0; i--) {
					Nbh r = DE.nbhs.get(i) ;
					if (r.a==p || r.b==p) {
						DE.nbhs.remove(i);
					} else {
						if (r.a>p) r.a--;
						if (r.b>p) r.b--;
					}
				}
			}
		}
	}

	void fill_pt_tag1(int p, int i) {
		if (! is_Beads_id(p)) {
			return ;
		}
		if (pt_tag1[p]>=0) {
			return ;
		} else {
			pt_tag1[p] = i;
			for (int k=0; k<4; k++) {
				fill_pt_tag1(pt_nhd[p][k], i+1);
			}
		}
	}

	void fill_pt_tag2(int p, int i, int prev) {
		if (! is_Beads_id(p)) {
			return ;
		}
		if (pt_tag2[p]>=0) {
			return ;
		} else {
			pt_tag2[p] = i;
			pt_prev[p] = prev;
			for (int k=0; k<4; k++) {
				fill_pt_tag2(pt_nhd[p][k], i+1, p);
			}
		}
	}


	void fill_pt_treated(int p) {
		if (! is_Beads_id(p)) {
			return ;
		}
		if (pt_treated[p]) {
			return ;
		}
		pt_treated[p] = true;
		for (int k=0; k<4; k++) {
			fill_pt_treated(pt_nhd[p][k]);
		}
	}

// void remove_isolated_point() {
//   for (int i=points.size ()-1; i>=0; i--) {
//     if (points.get(i).deg == 0) {
//       points.remove(i);
//     }
//   }
// }

////////////////////////////////////////////
//
//      find_crossing()
//
////////////////////////////////////////////
	boolean find_crossing() {
		for (int i=0; i<DE.points.size (); i++) {
	    Beads bdsi=DE.points.get(i);
	    if (bdsi.c==1) {
	      float min=9999;
	      int minJ=-1;
	      for (int j=0; j<DE.points.size (); j++) {
	        float d=dist(bdsi.x, bdsi.y, DE.points.get(j).x, DE.points.get(j).y);
	        if (d<min && i!=j ) {
	          if (j!=bdsi.n1 && DE.points.get(bdsi.n1).c == 2) {
	            if (!is_near_two_points(i, j, 5)) {
	              //if (j!=DE.points.get(bdsi.o1).o1 && j!=DE.points.get(bdsi.o1).o2) {
	              min=d;
	              minJ=j;
	            }
	          }
	        }
	      }
	      if (minJ>=0 && DE.points.get(minJ).c == 2) {
	        //if (!segmentOnCurve(i, minJ)) {
	          cross.add(new Nbh(i, minJ));
	        //}
	      }
	    }
	  }
	  find_crosspt_from_cross_new();
	  return false;
	}
	
	boolean is_near_two_points(int p, int q,int cc) {
	  if(!is_Beads_id(p)){
	  	return false;
	  }
	  if(p==q){
	    return true;
	  }
	  int a_prev = p;
	  int a_now = DE.points.get(p).n1;
	  if (is_Beads_id(a_now)) {
	    for (int i=0; i<cc && a_now!=-1; i++) {
	      if (a_now==q) {
	        return true;
	      }
	      int a_next = find_next(a_prev, a_now);
	      a_prev = a_now;
	      a_now = a_next;
	    }
	  }
	  a_prev = p;
	  a_now = DE.points.get(p).n2;
	  if (is_Beads_id(a_now)) {
	    for (int i=0; i<cc && a_now!=-1; i++) {
	      if (a_now==q) {
	        return true;
	      }
	      int a_next = find_next(a_prev, a_now);
	      a_prev = a_now;
	      a_now = a_next;
	    }
	  }
	  return false;
	}

	int find_next(int prv, int nw) {
	  if (is_Beads_id(nw)) {
	    Beads v = DE.points.get(nw);
	    if (v.n1 == prv) {
	      return v.n2;
	    } else if (v.n2 == prv) {
	      return v.n1;
	    } else if (v.u1 == prv) {
	      return v.u2;
	    } else if (v.u2 == prv) {
	      return v.u1;
	    }
	  }
	  return -1;
	}

	void find_crosspt_from_cross_new() {
	  for (int j=0; j<cross.size (); j++) {
	    Nbh cj = cross.get(j);
	    int m=0, max=DE.points.size();
	    int maxk=-1;
	    for (int k=0; k<cross.size (); k++) {
	      if (j != k) {
	        Nbh ck = cross.get(k);
	        m = find_near_points(cj.b, ck.b, 10);
	        if (0<=m && m<max) {
	          max = m;
	          maxk = k;
	        }
	      }
	    }
	    if (j<maxk) {
	      Nbh ck = cross.get(maxk);
	      Beads v=DE.points.get(ck.b);
	      v.Joint=true;
	      v.u1=cj.a;
	      // TODO 向きを決めないといけない
	      v.u2=ck.a;
	      DE.points.get(cj.a).c=2;
	      DE.points.get(cj.a).n2=ck.b;
	      DE.points.get(ck.a).c=2;
	      DE.points.get(ck.a).n2=ck.b;
	    }
	  }
	}

	int find_near_points(int p, int q,int cc) {
		if(p==q){
			return 0;
		}
		int a_prev = p;
		int a_now = DE.points.get(p).n1;
		if (is_Beads_id(a_now)) {
			for (int i=0; i<cc && a_now!=-1; i++) {
				if (a_now==q) {
					return i;
				}
				int a_next = find_next(a_prev, a_now);
				a_prev = a_now;
				a_now = a_next;
			}
		}
		a_prev = p;
		a_now = DE.points.get(p).n2;
		if (a_now>=0) {
			for (int i=0; i<cc && a_now!=-1; i++) {
				if (a_now==q) {
					return i;
				}
				int a_next = find_next(a_prev, a_now);
				a_prev = a_now;
				a_now = a_next;
			}
		}
		return -1;
	}
}