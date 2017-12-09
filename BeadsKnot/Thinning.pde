class Thinning{
	data_extract DE;
	int w,h;
	int d_new[][];

	Thinning(data_extract _de){
		DE=_de;
		w=DE.w;
		h=DE.h;
		d_new = new int[w][h];
	}

	boolean getThinningExtraction(){
		w=DE.w;
		h=DE.h;
	    DE.nbhs.clear();
	    DE.points.clear();
		// int de.d[w][h] を仮定してよい。
		get_edge_data_thinning();
		DE.countNbhs();
		DE.getDisplayLTRB();
		println(DE.points.size(),DE.nbhs.size());
		DE.extraction_binalized = true;
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
}