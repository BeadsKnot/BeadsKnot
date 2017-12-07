class Binalization{
data_extract de;

  Binalization(data_extract _de){
    de = _de;
  }

  void getBinalized(PImage image){
    int w = de.w;
    int h = de.h;
  	image.loadPixels();
  	de.d=new int [w][h];
    for (int y=0; y<h; y++) {
    	for (int x=0; x<w; x++) {
    		if (x>=50&&x<(w-50)&&y>=50&&y<(h-50)) {
    			color c = image.pixels[(y-50) * image.width + (x-50)];
    			if ((red(c)+green(c)+blue(c))/3 > 128) {
    				de.d[x][y]=0;
    			} else {
    				de.d[x][y]=1;
    			}
    		} else {
    			de.d[x][y]=0;
    		}
    	}
    }
}


}