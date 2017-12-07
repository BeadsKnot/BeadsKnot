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
	    DE.nbhs.clear();
	    DE.points.clear();



		// int de.d[w][h] を仮定してよい。
		return false;

	}

	boolean do_thinning() {
	    boolean cont=false;
	    for (int x=0; x<w; x++) {
	      for (int y=0; y<h; y++) {
	        d_new[y][x]=DE.d[y][x];
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
	                d_new[y][x]=0;
	              }
	              if (!c8 && !c1 && !c2 && c4 && c5 && c6) {
	                d_new[y][x]=0;
	              }
	              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
	                d_new[y][x]=0;
	              }
	            }
	            if (p==1) {
	              if (!c7 && !c8 && !c1 && c3 && c4 && c5) {
	                d_new[y][x]=0;
	              }
	              if (!c6 && !c7 && !c8 && c2 && c3 && c4) {
	                d_new[y][x]=0;
	              }
	              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
	                d_new[y][x]=0;
	              }
	            }
	            if (p==2) {
	              if (!c5 && !c6 && !c7 && c1 && c2 && c3) {
	                d_new[y][x]=0;
	              }
	              if (!c4 && !c5 && !c6 && c8 && c1 && c2) {
	                d_new[y][x]=0;
	              }
	              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
	                d_new[y][x]=0;
	              }
	            }
	            if (p==3) {
	              if (!c3 && !c4 && !c5 && c7 && c8 && c1) {
	                d_new[y][x]=0;
	              }
	              if (!c2 && !c3 && !c4 && c6 && c7 && c8) {
	                d_new[y][x]=0;
	              }
	              if (!c1 && !c2 && !c3 && c5 && c6 && c7) {
	                d_new[y][x]=0;
	              }
	            }
	          }
	        }
	      }
	      cont=false;
	      for (int x=0; x<w; x++) {
	        for (int y=0; y<h; y++) {
	          if (DE.d[y][x]!=d_new[y][x]) {
	            DE.d[y][x]=d_new[y][x];
	            cont=true;
	          }
	        }
	      }
	    }
	    return cont;
	}

}