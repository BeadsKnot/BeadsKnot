import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BeadsKnot extends PApplet {

//s\u30dc\u30bf\u30f3\u3092\u62bc\u3059\u3068\u753b\u50cf\u3092\u4fdd\u5b58
// PImage image;// ->data_extraction
// int w, h;// ->data_extraction
// int d[][];// ->data_extraction
// int s;// ->data_extraction
// int n = s;// ->data_extraction
boolean ofutarisama_flag=false;//\u304a\u4e8c\u4eba\u69d8\u304b\u3069\u3046\u304b\u306e\u30d5\u30e9\u30b0// ->data_extraction
PImage pastedImage;
PImage output;

data_extract data;

public void setup() {
  int extractSize=1500;

  //size(1500, 1500);//\u521d\u671f\u306e\u30b5\u30a4\u30ba
  //\u521d\u671f\u306e\u30b5\u30a4\u30ba
  // size(600, 600);//\u521d\u671f\u306e\u30b5\u30a4\u30ba

  data = new data_extract(extractSize, extractSize, null);
}

public void draw() {
  background(255);
  data.drawPoints();
  data.drawNbhs();
  if ( ofutarisama_flag) {
    data.tf.spring();
  }
}

public void keyPressed() {
  if ( key=='s') {
    int s = second();
    int m = minute();
    int h = hour();
    int d = day();
    int mon = month();
    save("knot"+mon+d+"-"+h+m+s+".png");
  }

  if (PApplet.parseInt(key)==15) {// ctrl+o
    selectInput("Select a file to process:", "fileSelected");
  }
}

public void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    PImage image = loadImage(selection.getAbsolutePath());
    data.make_data_extraction(image);
  }
}
class Beads {//\u70b9\u306e\u30af\u30e9\u30b9
  float x;
  float y;
  int c;
  int n1;
  int n2;
  int u1;
  int u2;
  boolean Joint;
  Beads(float _x, float _y) {
    x=_x;
    y=_y;
    n1=-1;
    n2=-1;
    u1=-1;
    u2=-1;
    Joint=false;
  }
}
class Node {
    double x;
    double y;
    double theta;
    double[] r;//\u9577\u3055\u3001\uff14\u3064
    int radius;//\u5186\u306e\u534a\u5f84
    public double edge_x(int i){
        return x + r[i] * Math.cos(theta+Math.toRadians(i*90));
    }
    public double edge_y(int i){
        return y - r[i] * Math.sin(theta+Math.toRadians(i*90));
    }
    public double edge_rx(int i, double s){
        return x + s * Math.cos(theta+Math.toRadians(i*90));
    }
    public double edge_ry(int i,double s){
        return y - s * Math.sin(theta+Math.toRadians(i*90));
    }
    boolean Joint;
    boolean drawOn;
    Node(double _x, double _y){
        x=_x;
        y=_y;
        theta=0;
        r=new double[4];
        radius=20;
        for(int i=0;i<4;i++) {
            r[i]=5;//\u7dda\u306e\u9577\u3055
        }
        Joint=false;
        drawOn = false;
    }
    public double getR(int i){
        if(0<=i && i<4) return r[i];
        else return 0;
    }
    public void setR(int i,double rr){
        if(0<=i && i<4) r[i] = rr;
    }
    public double getX(){ return x;}
    public double getY(){ return y;}
    public void draw_Alignment(double l, double t, double r, double b){
        double w = r-l;
        double h = b-t;
        double rate;
        if(w>h){
            rate = 1080/w;
        } else {
            rate = 1080/h;
        }
        //\u30ac\u30a4\u30c9\u306e\u63cf\u753b
//        p.setARGB(160, 0, 0, 0);
//        p.setStrokeWidth(5);
//        for(int i=0;i<4;i++) {
//           c.drawLine((float)x, (float)y, (float)edge_x(i), (float)edge_y(i) , p);
//        }
        if(Joint) {
            fill(255, 255, 0, 0);
        }else{
            fill(255,0,255,0);
        }
        if(drawOn) {
            noStroke();
            ellipse((float) ((x - l) * rate), (float) ((y - t) * rate), radius, radius);
        }
    }
}
class data_extract {

  int w , h;// \u89e3\u6790\u753b\u9762\u306e\u5927\u304d\u3055
  int d[][];// \u753b\u50cf\u306e2\u5024\u5316\u30c7\u30fc\u30bf
  int n,s;//\u89e3\u6790\u30e1\u30c3\u30b7\u30e5\u306e\u30b5\u30a4\u30ba

  ArrayList<Nbh> nbhs=new ArrayList<Nbh>();//\u7dda\u3092\u767b\u9332
  ArrayList<Beads> points=new ArrayList<Beads>();//\u70b9\u3092\u767b\u9332
  transform tf;

  //\u30b3\u30f3\u30b9\u30c8\u30e9\u30af\u30bf
  data_extract(int _h, int _w, PImage _img) {
    w = _w;
    h = _h;
    tf=new transform(this);
  }

  // image\u30c7\u30fc\u30bf\u306e\u89e3\u6790
  public void make_data_extraction(PImage image) {
    ofutarisama_flag=false;
    //\u3082\u3068\u753b\u50cf\u304c\u6a2a\u9577\u306e\u5834\u5408\uff0c\u7e26\u9577\u306e\u5834\u5408\u306b\u5fdc\u3058\u3066\u5909\u3048\u308b\u3002
    // \u30aa\u30d5\u30bb\u30c3\u30c8\u309250 \u306b\u53d6\u3063\u3066\u3044\u308b\u3002
    image.resize(w - 100, h - 100);

    image.loadPixels();
    d=new int [w][h];
    loadPixels();
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        if (x>=50&&x<(w-50)&&y>=50&&y<(h-50)) {
          int c = image.pixels[(y-50) * image.width + (x-50)];
          if (red(c)>128&&green(c)>128&&blue(c)>128) {
            d[x][y]=0;
          } else {
            d[x][y]=1;
          }
        } else {
          d[x][y]=0;
        }
      }
    }
    updatePixels();
    int Thickness=thickness() ;
    s=n=Thickness;
    do { 
      s++;
      n++; 
      nbhs=new ArrayList<Nbh>();
      points=new ArrayList<Beads>();
      for (int y=0; y<h; y+=n) {
        for (int x=0; x<w; x+=n) {
          copy_area(x, y);
        }
      }
      countNbhs();
      removethrone();
      fillgap();
      // get_nbh();
      countNbhs();
      FindJoint();
      ofutarisama_flag=Ofutarisama();
      println(Ofutarisama(), s);
      tf.ln=s;
    } while (!Ofutarisama ()&&s<(Thickness+10));
    //if (s==(Thickness+10)) {
    //println("\u5931\u6557");
    //}
    if ( ofutarisama_flag==false) {
      s=n=Thickness;
      do { 
        s--;
        n--; 
        nbhs=new ArrayList<Nbh>();
        points=new ArrayList<Beads>();
        for (int y=0; y<h; y+=n) {
          for (int x=0; x<w; x+=n) {
            copy_area(x, y);
          }
        }
        countNbhs();
        removethrone();
        fillgap();
        //get_nbh();
        countNbhs();
        FindJoint();
        ofutarisama_flag=Ofutarisama();
        tf.ln=s;
        println(Ofutarisama(), s);
      } while (!Ofutarisama ()&&s>(Thickness-10));
      if (s==(Thickness-10)) {
        println("\u5931\u6557");
      }
    }
    if ( ofutarisama_flag) {
      jointAddToNbhs();
      tf.spring_setup();
    }
  }

  public int addToPoints(int u, int v) {//\u70b9\u3092\u8ffd\u52a0\u3059\u308b
    for (int i=0; i<points.size (); i++) {
      if (dist(u, v, points.get(i).x, points.get(i).y )<n-1) {
        return i;
      }
    }
    points.add(new Beads(u, v));
    return points.size()-1;
  }

  public void drawPoints() {//\u70b9\u3092\u304b\u304f
    stroke(255, 0, 0);
    for (int i=0; i<points.size (); i++) {
      Beads vec=points.get(i);
      if (vec.Joint) {
        stroke(0, 0, 255);
      } else {
        stroke(255, 0, 0);
      }
      if (vec.c<=0||vec.c>=4) {
      } else {
        ellipse(vec.x, vec.y, vec.c*3+1, vec.c*3+1);//vec.c\u306f1or2or3\u306e\u306f\u305a
      }
    }
  }

  public int addToNbhs(int nn, int mm) {//\u7dda\u3092\u8ffd\u52a0\u3059\u308b
    if (nn!=mm&&connected(nn, mm)==1) {
      nbhs.add(new Nbh(nn, mm));
    }
    return 1;
  }

  public int connected(int nn, int mm) {//\u7dda\u304c\u3064\u306a\u304c\u3063\u3066\u3044\u308b\u304b
    if ( duplicateNbhs(nn, mm)==1) {//\u91cd\u8907\u3057\u305f\u3089
      return 0;
    }
    if (nn==mm) {
      return 0;
    }
    float xa=points.get(nn).x;
    float ya=points.get(nn).y;
    float xb=points.get(mm).x;
    float yb=points.get(mm).y;
    int l=PApplet.parseInt(min(xa, xb));
    int r=PApplet.parseInt(max(xa, xb));
    int t=PApplet.parseInt(min(ya, yb));
    int b=PApplet.parseInt(max(ya, yb));
    int [][]f=new int[r-l+1][b-t+1];
    int [][]g=new int[r-l+1][b-t+1];  
    for (int x=0; x<r-l+1; x++) {
      for (int y=0; y<b-t+1; y++) {
        f[x][y]=d[l+x][t+y];
      }
    }
    int fax=PApplet.parseInt(xa-l);
    int fay=PApplet.parseInt(ya-t);//f\u4e0a\u3067\u306eA\u306e\u4f4d\u7f6e
    int fbx=PApplet.parseInt(xb-l);
    int fby=PApplet.parseInt(yb-t);//f\u4e0a\u3067\u306eB\u306e\u4f4d\u7f6e

    //f\u4e0a\u3067\u9ed2\u3060\u3051\u3092\u901a\u3063\u3066(fax,fay)~(fbx,fby)\u3078\u3044\u304f
    for (int x=0; x<r-l+1; x++) {
      for (int y=0; y<b-t+1; y++) {
        g[x][y]=0;
      }
    }
    g[fax][fay]=1;
    boolean loop_end;
    do {
      loop_end=true;
      for (int x=0; x<r-l+1; x++) {
        for (int y=0; y<b-t+1; y++) {
          if (g[x][y]==1) {
            if (x!=0&&y!=0&&f[x-1][y-1]==1&&g[x-1][y-1]==0) {
              g[x-1][y-1]=1;
              loop_end=false;
            }
            if (y!=0&&f[x][y-1]==1&&g[x][y-1]==0) {
              g[x][y-1]=1;
              loop_end=false;
            }
            if (y!=0&&x!=r-l&&f[x+1][y-1]==1&&g[x+1][y-1]==0) {
              g[x+1][y-1]=1;
              loop_end=false;
            }
            if (x!=0&&f[x-1][y]==1&&g[x-1][y]==0) {
              g[x-1][y]=1;
              loop_end=false;
            }
            if (x!=r-l&&f[x+1][y]==1&&g[x+1][y]==0) {
              g[x+1][y]=1;
              loop_end=false;
            }
            if (x!=0&&y!=b-t&&f[x-1][y+1]==1&&g[x-1][y+1]==0) {
              g[x-1][y+1]=1;
              loop_end=false;
            }
            if (y!=b-t&&f[x][y+1]==1&&g[x][y+1]==0) {
              g[x][y+1]=1;
              loop_end=false;
            }
            if (x!=r-l&&y!=b-t&&f[x+1][y+1]==1&&g[x+1][y+1]==0) {
              g[x+1][y+1]=1;
              loop_end=false;
            }
            g[x][y]=2;//A\u304c1\u306a\u3089\u30702\u306b\u3059\u308b
          }
        }
      }
    } while (!loop_end);//1\u304c\u306a\u304f\u306a\u308b\u307e\u3067\u7e70\u308a\u8fd4\u3059
    //\u3082\u30571\u304c\u306a\u304f\u306a\u308a\u3001\u3059\u3079\u30662\u306b\u3059\u308b\u3053\u3068\u304c\u3067\u304d\u305f\u3089
    if (g[fbx][fby]==2) {
      return 1;//OK\u306a\u30891\u3092\u8fd4\u3059
    } else {
      return 0;
    }
  }

  public void drawNbhs() {//\u7dda\u3092\u66f8\u304f
    for (int i=0; i<points.size (); i++) {
      Beads vec=points.get(i);
      if (vec.n1!=-1) {
        stroke(255, 0, 0);
        try { 
          if (!points.get(vec.n1).Joint) {
            line(vec.x, vec.y, points.get(vec.n1).x, points.get(vec.n1).y);//\u30a8\u30e9\u30fc\u304c\u3067\u308b
          }
        }
        catch (IndexOutOfBoundsException e) {
        }
      }
      if (vec.n2!=-1) {
        stroke(255, 0, 0);
        try { 
          if (!points.get(vec.n2).Joint) {
            line(vec.x, vec.y, points.get(vec.n2).x, points.get(vec.n2).y);//\u30a8\u30e9\u30fc\u304c\u3067\u308b
          }
          /* process */
        } 
        catch (IndexOutOfBoundsException e) {
        }
      }
      // if (vec.u1!=-1) {
      //stroke(0, 255, 0);
      //line(vec.x, vec.y, points.get(vec.u1).x, points.get(vec.u1).y);//\u30a8\u30e9\u30fc\u304c\u3067\u308b
      //}
      //if (vec.u2!=-1) {
      //stroke(255, 255, 0);
      //line(vec.x, vec.y, points.get(vec.u2).x, points.get(vec.u2).y);
      //}
    }
  }

  public void countNbhs() {//\u7dda\u3092\u6570\u3048\u308b
    for (Beads vec : points) {
      vec.c=0;
      vec.n1=vec.n2=vec.u1=vec.u2=-1;//\u6b63\u5e38\u3067\u306a\u3044\u5024
    }
    for (Nbh n : nbhs) {
      // points.get(n.a).c++;
      //points.get(n.b).c++;
      Beads vec_1=points.get(n.a);
      if (vec_1.c==0) {
        vec_1.n1=n.b;
      } else if (vec_1.c==1) {
        vec_1.n2=n.b;
      } else if (vec_1.c==2) {
        vec_1.u1=n.b;
      } else if (vec_1.c==3) {
        vec_1.u2=n.b;
      }
      vec_1.c++;
      Beads vec_2=points.get(n.b);
      if (vec_2.c==0) {
        vec_2.n1=n.a;
      } else if (vec_2.c==1) {
        vec_2.n2=n.a;
      } else if (vec_2.c==2) {
        vec_2.u1=n.a;
      } else if (vec_2.c==3) {
        vec_2.u2=n.a;
      }
      vec_2.c++;
    }
  }

  public void jointAddToNbhs() {//joint\u306b\u95a2\u3057\u3066\u306e\u7dda\u3092\u8ffd\u52a0
    for (int u=0; u<points.size (); u++) {
      Beads vec=points.get(u);
      if (vec.Joint) {
        if (duplicateNbhs(u, vec.u1)==0) {
          nbhs.add(new Nbh(u, vec.u1));
        }
        if (duplicateNbhs(u, vec.u2)==0) {
          nbhs.add(new Nbh(u, vec.u2));
        }
        // addToNbhs(u, vec.u1);
        //addToNbhs(u, vec.u2);
        // println(u, vec.u1);
      }
    }
  }

  public int duplicateNbhs(int nn, int mm) {//\u7dda\u304c\u91cd\u8907\u3057\u3066\u3044\u308b\u304b\u3069\u3046\u304b\u3092\u8abf\u3079\u308b
    for (Nbh n : nbhs) {
      if (nn==n.a&&mm==n.b) {
        return 1;
      }
      if (nn==n.b&&mm==n.a) {
        return 1;
      }
    }
    return 0;
  }

  public void removePoint(int u) {//\u70b9\u3092\u6d88\u3059
    points.remove(u);
    for (int i=nbhs.size ()-1; i>=0; i--) {
      Nbh n=nbhs.get(i);
      if (n.a==u||n.b==u) {
        nbhs.remove(i);
      }
    }
    for (int i=nbhs.size ()-1; i>=0; i--) {
      Nbh n=nbhs.get(i);
      if (n.a>u) {
        n.a--;
      }
      if (n.b>u) {
        n.b--;
      }
    }
  }

  public void removePoint2(int u) {
    for (int i=0; i<points.size (); i++) {
      Beads vec_po=points.get(i);
      if (vec_po.n1>u) {
        vec_po.n1--;
      }
      if (vec_po.n2>u) {
        vec_po.n2--;
      }
      if (vec_po.u1>u) {
        vec_po.u1--;
      }
      if (vec_po.u2>u) {
        vec_po.u2--;
      }
    }
  }

  public void removethrone() {//\u3068\u3052\u3092\u9664\u304f
    for (int u=0; u<points.size (); u++) {
      if ( points.get(u).c==1) {
        for (int i=nbhs.size ()-1; i>=0; i--) {
          Nbh n=nbhs.get(i);
          if (n.a==u) {
            if (points.get(n.b).c==3) {
              removePoint(u);
              removePoint2(u);
              points.get(n.b).c=2;
            }
          } else if (n.b==u) {
            if (points.get(n.a).c==3) {
              removePoint(u);
              removePoint2(u);
              points.get(n.a).c=2;
            }
          }
        }
      }
    }
  }

  public void fillgap() {//\u70b9\u3068\u70b9\u306e\u8ddd\u96e2\u306e\u6700\u5c0f\u3092\u8a18\u9332\u3057\u3001\u6700\u5c0f\u306e\u8ddd\u96e2\u306e\u70b9\u304c1\u672c\u3055\u3093\u306a\u3089\u3070\u305d\u306e\u70b9\u3068\u70b9\u3092\u3064\u306a\u3052\u308b
    for (int u=0; u<points.size (); u++) {
      if ( points.get(u).c==1) {
        float min=w;
        int num=0;
        for (int v=0; v<points.size (); v++) {
          if (u!=v) {
            /*
            boolean OK=true;
             for (Nbh n : nbhs) {
             if (n.a==u&&n.b==v) {
             OK=false;
             }
             if (n.a==v&&n.b==u) {
             OK=false;
             }
             }
             */
            //if (OK) {
            if (points.get(u).n1!=v) {
              float d=dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
              if (min>d) {
                min=d;
                num=v;
              }
            }
          }
        }
        if (points.get(num).c==1) {
          addToNbhs(u, num);
          //\u306a\u306b\u304b\u3059\u308b
          points.get(num).c++;
          points.get(u).c++;
        } else if (points.get(num).c==0) {
          addToNbhs(u, num);
          points.get(num).c++;
          points.get(u).c++;
        }
      }
    }
  }
  /*
  void get_nbh() {//\u3068\u306a\u308a\u306e\u96a3\u306e\u5185\u5bb9\u3092get\u3059\u308b
   //for (Nbh n : nbhs) {
   for (int i=0; i<nbhs.size (); i++) {
   Nbh n=nbhs.get(i);
   if (n.a!=n.b) {
   if (points.get(n.a).n1==-1) {
   points.get(n.a).n1=n.b;
   } else {
   points.get(n.a).n2=n.b;
   }
   if (points.get(n.b).n1==-1) {
   points.get(n.b).n1=n.a;
   } else {
   points.get(n.b).n2=n.a;
   }
   }
   }
   }
   */

  public void FindJoint() {//joint\u3092\u63a2\u3059
    for (int u=0; u<points.size (); u++) {
      if ( points.get(u).c==1) {
        float min=w;
        int num=0;
        for (int v=0; v<points.size (); v++) {
          if (u!=v) {
            int pgu1=points.get(u).n1;
            // println(pgu1);
            if (v!=pgu1) {
              //print("pgu1="+pgu1);
              if (pgu1!=-1&&v!=points.get(pgu1).n1&&v!=points.get(pgu1).n2) {
                float d=dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
                if (min>d) {
                  min=d;
                  num=v;
                }
              }
            }
          }
        }
        if (points.get(num).c==2) {
          points.get(num).Joint=true;

          if (points.get(num).u1==-1) {
            points.get(num).u1=u;
          } else {
            points.get(num).u2=u;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          }
          int pgn1=points.get(num).n1;
          int pgn2=points.get(num).n2;
          if (pgn1!=-1&&points.get(pgn1).Joint) {//\u96a3\u3060\u3063\u305f\u3068\u304d
            points.get(pgn1).Joint=false;
            points.get(num).u2=points.get(pgn1).u1;
            points.get(pgn1).u1=-1;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          } else if (pgn2!=-1&&points.get(pgn2).Joint) {
            points.get(pgn2).Joint=false;
            points.get(num).u2=points.get(pgn2).u1;
            points.get(pgn2).u1=-1;
            points.get(points.get(num).u1).n2=num;
            points.get(points.get(num).u2).n2=num;
            points.get(points.get(num).u1).c++;
            points.get(points.get(num).u2).c++;
          }
          //\u96a3\u306e\u96a3
          if (pgn1!=-1&&pgn2!=-1) {
            int pgn1_1=points.get(pgn1).n1;
            int pgn1_2=points.get(pgn1).n2;
            int pgn2_1=points.get(pgn2).n1;
            int pgn2_2=points.get(pgn2).n2;
            if (num!=pgn1_1&&points.get(pgn1_1).Joint) {
              points.get(pgn1_1).Joint=false;
              points.get(pgn1).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn1).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn1).u2=points.get(pgn1_1).u1;
              points.get(pgn1_1).u1=-1;
              points.get(points.get(pgn1).u1).n2=pgn1;
              points.get(points.get(pgn1).u2).n2=pgn1;
              points.get(points.get(pgn1).u1).c++;
              points.get(points.get(pgn1).u2).c++;
            } else if (pgn1_2!=-1&&num!=pgn1_2&&points.get(pgn1_2).Joint) {
              points.get(pgn1_2).Joint=false;
              points.get(pgn1).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn1).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn1).u2=points.get(pgn1_2).u1;
              points.get(pgn1_2).u1=-1;
              points.get(points.get(pgn1).u1).n2=pgn1;
              points.get(points.get(pgn1).u2).n2=pgn1;
              points.get(points.get(pgn1).u1).c++;
              points.get(points.get(pgn1).u2).c++;
            } else  if (num!=pgn2_1&&points.get(pgn2_1).Joint) {
              points.get(pgn2_1).Joint=false;
              points.get(pgn2).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn2).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn2).u2=points.get(pgn2_1).u1;
              points.get(pgn2_1).u1=-1;
              points.get(points.get(pgn2).u1).n2=pgn2;
              points.get(points.get(pgn2).u2).n2=pgn2; 
              points.get(points.get(pgn2).u1).c++;
              points.get(points.get(pgn2).u2).c++;
            } else if (pgn2_2!=-1&&num!=pgn2_2&&points.get(pgn2_2).Joint) {
              points.get(pgn2_2).Joint=false;
              points.get(pgn2).Joint=true;
              points.get(num).Joint=false;
              points.get(pgn2).u1=points.get(num).u1;
              points.get(num).u1=-1;
              points.get(pgn2).u2=points.get(pgn2_2).u1;
              points.get(pgn2_2).u1=-1;
              if (points.get(pgn2).u1!=-1&&points.get(pgn2).u2!=-1) {
                points.get(points.get(pgn2).u1).n2=pgn2;
                points.get(points.get(pgn2).u2).n2=pgn2;
                points.get(points.get(pgn2).u1).c++;
                points.get(points.get(pgn2).u2).c++;
              }
            }
          }
        }
      }
    }
  }




  public void copy_area(int x, int y) {//
    int e[][]=new int[s][s];
    if (x+s>w||y+s>h) {
      return;
    }
    for (int j=0; j<s; j++) {
      for (int i=0; i<s; i++) {
        e[i][j]=d[x+i][y+j];
      }
    }
    float XY=0, X=0, Y=0, XX=0, YY=0;
    int num=0;
    for (int j=0; j<s; j++) {
      for (int i=0; i<s; i++) {
        if ( e[i][j]==1) {
          XY+=i*j;
          X+=i;
          Y+=j;
          XX+=i*i;
          YY+=j*j;
          num++;
        }
      }
    }
    int v1=0;
    int v2=0;
    int v3=0;
    int v4=0;

    if (num>(s*s)/10) {//1\u5272\u4ee5\u4e0a\u3060\u3063\u305f\u3089
      if ((num*XX)-(X*X)>(num*YY)-(Y*Y)) {
        float a=(num*XY-X*Y)/((num*XX)-(X*X));
        float b=(XX*Y-XY*X)/((num*XX)-(X*X));
        boolean p1=(b>=0&&b<=s&&d[x][(int)(y+b)]==1);//p1\u304c\u8fba\u4e0a\u306b\u4e57\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float k=a*s+b;
        boolean p2=(k>=0&&k<=s&&d[x+s][(int)(y+k)]==1); //p2\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float h=-b/a;
        //if(a==0)\u4f55\u304b\u51e6\u7406\u304c\u5fc5\u8981
        boolean p3=(h>=0&&h<=s&&d[(int)(x+h)][y]==1); //p3\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float l=(s-b)/a;
        boolean p4=(l>=0&&l<=s&&d[(int)(x+l)][y+s]==1); //p4\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        if (p1) {
          v1=addToPoints(x, (int)(y+b));
        }
        if (p2) {
          v2=addToPoints(x+s, (int)(y+k));
        }
        if (p3) {
          v3=addToPoints((int)(x+h), y);
        }
        if (p4) {
          v4=addToPoints((int)(x+l), y+s);
        }
        if (p1&&p2) {
          addToNbhs(v1, v2);
        }
        if (p2&&p3) {
          addToNbhs(v2, v3);
        }
        if (p1&&p4) {
          addToNbhs(v1, v4);
        }
        if (p1&&p3) {
          addToNbhs(v1, v3);
        }
        if (p2&&p4) {
          addToNbhs(v2, v4);
        }
      } else {
        float a=(num*XY-X*Y)/((num*YY)-(Y*Y));
        float b=(YY*X-XY*Y)/((num*YY)-(Y*Y));
        boolean p1=(b>=0&&b<=s&&d[(int)(x+b)][y]==1);//p1\u304c\u8fba\u4e0a\u306b\u4e57\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float k=a*s+b;
        boolean p2=(k>=0&&k<=s&&d[(int)(x+k)][y+s]==1); //p2\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float h=-b/a;
        //if(a==0)\u4f55\u304b\u51e6\u7406\u304c\u5fc5\u8981
        boolean p3=(h>=0&&h<=s&&d[x][(int)(y+h)]==1); //p3\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        float l=(s-b)/a;
        boolean p4=(l>=0&&l<=s&&d[x+s][(int)(y+l)]==1); //p4\u304c\u8fba\u4e0a\u306b\u8f09\u3063\u3066\u3044\u308b\u306a\u3089\u3070
        if (p1) {
          v1=addToPoints((int)(x+b), y);
        }
        if (p2) {
          v2=addToPoints((int)(x+k), y+s);
        }
        if (p3) {
          v3=addToPoints(x, (int)( y+h));
        }
        if (p4) {
          v4=addToPoints(x+s, (int)(y+l));
        }
        if (p1&&p2) {
          addToNbhs(v1, v2);
        }
        if (p2&&p3) {
          addToNbhs(v2, v3);
        }
        if (p1&&p4) {
          addToNbhs(v1, v4);
        }
        if (p1&&p3) {
          addToNbhs(v1, v3);
        }
        if (p2&&p4) {
          addToNbhs(v2, v4);
        }
      }
    }

    boolean OKy=true;
    int flagy;
    int i1=0;
    int i2=s-1;
    int i3=0;
    int i4=0;
    for (int j=0; j<s; j++) {
      flagy=0;
      for (int i=0; i<s; i++) {
        if (flagy==0&&e[i][j]==0) {
          flagy=1;
        } else if (flagy==0&&e[i][j]==1) {
          flagy=2;
          i1=i;
        } else if (flagy==1&&e[i][j]==1) {
          flagy=2;
          i1=i;
        } else if (flagy==2&&e[i][j]==0) {
          flagy=3;
          i2=i;
        } else if (flagy==3&&e[i][j]==1) {
          flagy=4;
        }
      }
      if (j==0) {
        i3=((i1+i2)/2);
      }
      if (j==s-1) {
        i4=((i1+i2)/2);
      }
      if (flagy!=3&&flagy!=2) {
        OKy=false;
      }
    }
    if (OKy) {
      for (int j=0; j<s; j++) {
        for (int i=0; i<s; i++) {
          if ( e[i][j]==1) {
            stroke(0, 255, 0);
          } else {
            stroke(0, 0, 255);
          }
        }
      }
      stroke(0);
    }

    boolean OKx=true;
    int flagx;
    int j1=0;
    int j2=s-1;
    int j3=0;
    int j4=0;
    for (int i=0; i<s; i++) {
      flagx=0;
      for (int j=0; j<s; j++) {
        if (flagx==0&&e[i][j]==0) {
          flagx=1;
        } else if (flagx==0&&e[i][j]==1) {
          flagx=2;
          j1=j;
        } else if (flagx==1&&e[i][j]==1) {
          flagx=2;
          j1=j;
        } else if (flagx==2&&e[i][j]==0) {
          flagx=3;
          j2=j;
        } else if (flagx==3&&e[i][j]==1) {
          flagx=4;
        }
      }
      if (i==0) {
        j3=((j1+j2)/2);
      }
      if (i==s-1) {
        j4=((j1+j2)/2);
      }
      if (flagx!=3&&flagx!=2) {
        OKx=false;
      }
    }
    if (OKx) {
      for (int j=0; j<s; j++) {
        for (int i=0; i<s; i++) {
          if ( e[i][j]==1) {
            stroke(255);
          } else {
            stroke(0, 0, 255);
          }
        }
      }
      stroke(0);
    }
  }
  public boolean Ofutarisama() {//\u307f\u3093\u306a\u304a\u4e8c\u4eba\u69d8\u3060\u3063\u305f\u304b\u78ba\u8a8d
    for (Beads vec : points) {
      if (vec.c!=2) {
        return false;
      }
    }
    return true;
  }

  public int thickness() {//\u7dda\u306e\u592a\u3055\u306e\u5e73\u5747\u3092\u8a08\u7b97\u3057\u3066\u304f\u308c\u308b
    int count=0;
    int sum=0;
    int num=1;
    boolean flag=false;
    for (int y=100; y<h; y+=100) {
      for (int x=0; x<w; x++) {
        if (d[x][y]==1) {
          flag=true;
          count++;
        }
        if (flag==true&&d[x][y]==0) {
          flag=false;
          if (count>=5) {
            sum+=count;
            num++;
          }
          count=0;
        }
      }
    }
    println("\u5e73\u5747\u306f"+sum/num);
    return sum/num;
  }
}
class drawOption {
  boolean drawOriginalImage;
  boolean drawThinningImage;
  boolean drawBeadsAndNhds;

  drawOption() {
    changeDrawOption(3);
  }

  public void setAllOptionFalse() {
    drawOriginalImage=false;
    drawThinningImage=false;
    drawBeadsAndNhds=false;
  }

  public void changeDrawOption(int i) {
    setAllOptionFalse();
    switch(i) {
    case 1:
      drawOriginalImage=true;
      break;
    case 2:
      drawThinningImage=true;
      break;
    case 3:
      drawBeadsAndNhds=true;
      break;
    }
  }
}
class Nbh {//\u7dda\u306e\u30af\u30e9\u30b9
  int a, b;
  Nbh(int aa, int bb) {
    a=aa;
    b=bb;
  }
}
class transform {//\u5f62\u3092\u6574\u3048\u308b\u30af\u30e9\u30b9
  float []dx;
  float []dy;
  data_extract de;
  float ln;//\u81ea\u7136\u9577\u3092\u5b9a\u7fa9 longueur naturel
  transform(data_extract _de){
    de=_de;
  }
  
  public void spring_setup() {
    dx=new float[de.points.size()];//\u70b9\u306e\u500b\u6570
    dy=new float[de.points.size()];
  }

  public void spring() {
    for (int i=0; i<de.points.size (); i++) {//\u521d\u671f\u5316
      dx[i]=0;
      dy[i]=0;
    }
    for (int i=0; i<de.nbhs.size (); i++) {
      calc_spring(de.nbhs.get(i).a, de.nbhs.get(i).b, ln);//Nbh[n,m]\u307f\u305f\u3044\u306a\u611f\u3058\u306b\u306a\u308b
    }
    for (int i=0; i<de.points.size (); i++) {//double spring scheme
      Beads vec=de.points.get(i);
      if (vec.Joint) {
        calc_spring(vec.n1, vec.u1, 1.414f*ln);
        calc_spring(vec.n2, vec.u1, 1.414f*ln);
        calc_spring(vec.n2, vec.u2, 1.414f*ln);
        calc_spring(vec.n1, vec.u2, 1.414f*ln);
      } else {
        calc_spring(vec.n1, vec.n2, 1.99f*ln);
      }
    }

    for (int i=0; i<de.points.size (); i++) {
      de.points.get(i).x+=dx[i];
      de.points.get(i).y+=dy[i];
    }
  }

  public void calc_spring(int i, int j, float l) {//\u3070\u306d\u30e2\u30c7\u30eb
    float X=0;
    float Y=0;
    float d=0;
    float k=0.1f;
    X=de.points.get(j).x-de.points.get(i).x;
    Y=de.points.get(j).y-de.points.get(i).y;
    d=sqrt(X*X+Y*Y);
    dx[i]+=X/d*k*(d-l);
    dy[i]+=Y/d*k*(d-l);
    dx[j]-=X/d*k*(d-l);
    dy[j]-=Y/d*k*(d-l);
  }
}
  public void settings() {  size(1000, 1000); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BeadsKnot" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
