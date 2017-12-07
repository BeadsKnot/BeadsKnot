class Binalization{
  int d[][];// 画像の2値化データ
  Binalization(){

  }

  void getBinalized(int w, int h,PImage image){
  	image.loadPixels();
  	d=new int [w][h];
    for (int y=0; y<h; y++) {
    	for (int x=0; x<w; x++) {
    		if (x>=50&&x<(w-50)&&y>=50&&y<(h-50)) {
    			color c = image.pixels[(y-50) * image.width + (x-50)];
    			if ((red(c)+green(c)+blue(c))/3 > 128) {
    				d[x][y]=0;
    			} else {
    				d[x][y]=1;
    			}
    		} else {
    			d[x][y]=0;
    		}
    	}
    }
}


}