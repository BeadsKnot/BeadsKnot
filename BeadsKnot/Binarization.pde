class Binarization{
  data_extract de;
  int threshold;

  Binarization(data_extract _de){
    de = _de;
    threshold = 150;
  }

  void getBinarized(PImage image){
    threshold = getThreshold(image);
    //println("Threshold = "+threshold);
    int w = de.w;
    int h = de.h;
    image.loadPixels();
    de.d=new int [w][h];
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        if (x>=50&&x<(w-50)&&y>=50&&y<(h-50)) {
          color c = image.pixels[(y-50) * image.width + (x-50)];
          if ((red(c)+green(c)+blue(c))/3 > threshold) {
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

  int getThreshold(PImage image){
    int w = image.width;
    int h = image.height;
    image.loadPixels();
    int minC=0, maxC=255, numC=0;
    for(int s=0; s<500; s++){
      int x = int(random(w-200));
      int yy = int(random(h));
      int min=255;
      int max=0;
      for(int xx=0; xx<200; xx++){
        color c = image.pixels[yy * w + (x+xx)];
        int cc=int((red(c)+green(c)+blue(c))/3);
        if(cc<min) min = cc;
        if(cc>max) max = cc;
      } 
//println(min,max);
      if(max-min>50){
        if(minC<min) minC=min;
        if(maxC>max) maxC=max;
     }
    }
    if(minC<maxC){
      return (minC+maxC)/2;
    } else {
      return 150;
    }

  }

}