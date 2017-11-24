package com.example.aharalab2017_a.beadsknot;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;

import java.util.ArrayList;

import static java.lang.Math.floor;

/*import android.app.Activity;*/
/*import android.os.Bundle;*/

class data_extract {
    private Bitmap original_bmp;//読むデータ
    private Bitmap Binarized_bmp;//最終データ
    ArrayList<Beads> points = new ArrayList<>();//点を登録
    private ArrayList<Nbh> row;//線を登録
    private Paint paint;
    private int width,height;//画面のサイズ
    private int StrokeWidth;
    private int[][] d;
    private int s;
    /*float ln;*/
    private int[] table;

    boolean success;

    data_extract(int _width, int _height, Bitmap _bitmap) {

        row = new ArrayList<>();
        points = new ArrayList<>();//点を登録

        //TODO　極端に横長の画面、縦長の画面の時にはここを調整する必要がありうる。
        width = _width;// このサイズに変換し、画像解析を行う
        height = _height;//

        original_bmp = _bitmap;

        // Binarized2_bmp に「二値化」を行った画像を収納。
        getBinarized();
        extractImage();
    }

    void extractImage(){
        paint = new Paint();
        StrokeWidth = 5;

        s = thickness();
        //s = 15;
        int looplimit = s;
        int kaisa = 0;

        do {
//            if (kaisa % 2 == 0) {
//                s -= kaisa;
//            } else {
//                s += kaisa;
//            }
            kaisa++;
            s++;

            row.clear();
            points.clear();
            // points , row を取得
            for (int y = 0; y < height; y += s) {
                for (int x = 0; x < width; x += s) {
                    copy_area(x, y);
                }
            }

            //TODO このあたりで経過を画面表示することも検討
            countRow();
            cancelLoop();
            countRow();
            removeThrone();
            countRow();
            fillGap();
            countRow();
            FindJoint();
        } while (!Ofutarisama() && kaisa < looplimit);
        if(kaisa < looplimit){
            JointOrientation();
            add_half_point_Joint();
            getNodes();
            testFindNextJoint();
            success = true;
        } else {
            success = false;
        }
    }

    Bitmap get_Binarized_img(){
        return Binarized_bmp;
    }
    int getWidth(){
        return width;
    }

    private void add_half_point_Joint() {
        for (int i = 0; i < points.size(); i++) {
            Beads a = points.get(i);
            if(a.Joint){
                int c=findtrueJointInPoints(i,a.n1);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.n1, 0);
                    int half = get_half_position(i, a.n1, count / 2);
                    points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.u1);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.u1, 0);
                    int half = get_half_position(i, a.u1, count / 2);
                    points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.n2);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.n2, 0);
                    int half = get_half_position(i, a.n2, count / 2);
                    points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.u2);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.u2, 0);
                    int half = get_half_position(i, a.u2, count / 2);
                    points.get(half).midJoint=true;
                }

            }
        }
    }

    void drawPoints(Canvas canvas) {//点をかく
        // paint.setColor(Color.argb(255, 255, 0, 0));
        //canvas.drawBitmap(Binarized2_bmp, (float) 0, (float) 0, paint);//リサイズした画像を表示する
        //canvas.drawBitmap(Binarized_bmp, (float) 0, (float) 0, paint);//リサイズしていない画像を表示する
        for (int i = 0; i < points.size(); i++) {
            Beads vec = points.get(i);
            if (vec.Joint) {
                paint.setColor(Color.argb(255, 0, 0, 255));
            } else {
                paint.setColor(Color.argb(255, 255, 0, 0));
            }
            if (vec.c > 0 && vec.c < 4) {
                System.out.println(i);
                paint.setStrokeWidth(StrokeWidth);
                paint.setAntiAlias(true);
                paint.setStyle(Paint.Style.STROKE);
                canvas.drawCircle((float) vec.x, (float) vec.y, vec.c * 3 + 1, paint);//vec.cは1or2or3のはず
            }
        }
    }

    void drawRow(Canvas canvas) {//線を書く
        for (int i=0; i<points.size (); i++) {
            Beads vec=points.get(i);
            if (vec.n1!=-1) {
                paint.setColor(Color.argb(255, 255, 0, 255));
                if (!points.get(vec.n1).Joint) {
                    canvas.drawLine((float)vec.x, (float)vec.y, (float)(points.get(vec.n1).x), (float)(points.get(vec.n1).y),paint);
                }
            }
            if (vec.n2!=-1) {
                paint.setColor(Color.argb(255, 255, 0, 255));
                if (!points.get(vec.n2).Joint) {
                    // line(vec.x, vec.y, points.get(vec.n2).x, points.get(vec.n2).y);//エラーがでる
                    canvas.drawLine((float)vec.x,(float) vec.y, (float)points.get(vec.n2).x, (float)points.get(vec.n2).y,paint);
                }
            }
        }
    }

    private void getBinarized() {//二値化
        Binarized_bmp = Bitmap.createScaledBitmap(original_bmp, width, height, false);//数字を変えることで大きさを変更できる
        int pixels[] = new int[width * height];
        d=new int [width][height];
        Binarized_bmp.getPixels(pixels, 0, width, 0, 0, width, height);
        int threshold = 120 ;
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int c = pixels[x + y * width];
                int b = c & 0xff;
                int g = (c >> 8) & 0xff;
                int r = (c >> 16) & 0xff;
                if (r+g+b > threshold * 3 ) {
                    Binarized_bmp.setPixel(x,y,0xffffffff);
                    d[x][y] = 0;
                } else {
                    Binarized_bmp.setPixel(x,y,0xff000000);
                    d[x][y] = 1;
                }
            }
        }
    }


    private double dist(double x1,double y1,double x2,double y2){//2点間の距離
        return Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
    }

    private int addToPoints(double u, double v) {//点を追加する
        for (int i = 0; i < points.size(); i++) {
            //int n = 10;/////とりあえず
            if (dist(u, v, points.get(i).x, points.get(i).y) < s*0.9) {
                return i;
            }
        }
        points.add(new Beads(u, v));
        return points.size() - 1;
    }

    private int addToRow(int nn, int mm) {//線を追加する
        if (nn!=mm&&connected(nn, mm)==1) {
            row.add(new Nbh(nn, mm));
        }
        return 1;
    }
    private int connected(int nn, int mm) {//線がつながっているか
        if ( duplicateRow(nn, mm)==1) {//重複したら
            return 0;
        }
        if (nn==mm) {
            return 0;
        }
        double xa = points.get(nn).x;
        double ya = points.get(nn).y;
        double xb = points.get(mm).x;
        double yb = points.get(mm).y;
        int l = (int)Math.floor(Math.min(xa, xb));
        int r = (int)Math.floor(Math.max(xa, xb));
        int t = (int)Math.floor(Math.min(ya, yb));
        int b = (int)Math.floor(Math.max(ya, yb));
        int [][]f=new int[r-l+1][b-t+1];
        int [][]g=new int[r-l+1][b-t+1];
        for (int x=0; x<r-l+1; x++) {
            System.arraycopy(d[l + x], t, f[x], 0, b - t + 1);
            /*for (int y=0; y<b-t+1; y++) {
                f[x][y]=d[l+x][t+y];
            }*/
        }
        int fax=(int)(xa-l);
        int fay=(int)(ya-t);//f上でのAの位置
        int fbx=(int)(xb-l);
        int fby=(int)(yb-t);//f上でのBの位置

        //f上で黒だけを通って(fax,fay)~(fbx,fby)へいく
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
                        g[x][y]=2;//Aが1ならば2にする
                    }
                }
            }
        }
        while (!loop_end);//1がなくなるまで繰り返す
        //もし1がなくなり、すべて2にすることができたら
        if (g[fbx][fby]==2) {
            return 1;//OKなら1を返す
        } else {
            return 0;
        }
    }

    private int duplicateRow(int nn, int mm) {//線が重複しているかどうかを調べる
        for (Nbh n : row) {
            if (nn==n.a&&mm==n.b) {
                return 1;
            }
            if (nn==n.b&&mm==n.a) {
                return 1;
            }
        }
        return 0;
    }

    private void countRow() {//線を数える
        for (Beads vec : points) {
            vec.c=0;
            vec.n1=vec.n2=vec.u1=vec.u2=-1;//正常でない値
        }
        for (Nbh n : row) {
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

    private void jointAddToRow() {//jointに関しての線を追加
        for (int u=0; u<points.size (); u++) {
            Beads vec=points.get(u);
            if (vec.Joint) {
                if (duplicateRow(u, vec.u1)==0) {
                    row.add(new Nbh(u, vec.u1));
                }
                if (duplicateRow(u, vec.u2)==0) {
                    row.add(new Nbh(u, vec.u2));
                }
            }
        }
    }

    private void removePoint(int u,int nb) {//点を消す
        if (points.get(nb).n1 == u) {
            points.get(nb).n1 = points.get(nb).u1;
        } else if (points.get(nb).n2 == u) {
            points.get(nb).n2 = points.get(nb).u1;
        }
        points.remove(u);
        for (int i = row.size() - 1; i >= 0; i--) {
            Nbh n = row.get(i);
            if (n.a == u || n.b == u) {
                row.remove(i);
            }
        }
        for (int i = row.size() - 1; i >= 0; i--) {
            Nbh n = row.get(i);
            if (n.a > u) {
                n.a--;
            }
            if (n.b > u) {
                n.b--;
            }
        }
        //}
        //void removePoint2(int u) {//お隣さんの通し番号を変える
        for (int i = 0; i < points.size(); i++) {
            Beads vec_po = points.get(i);

            if (vec_po.n1 > u) {
                vec_po.n1--;
            }
            if (vec_po.n2 > u) {
                vec_po.n2--;
            }
            if (vec_po.u1 > u) {
                vec_po.u1--;
            }
            if (vec_po.u2 > u) {
                vec_po.u2--;
            }
        }
    }

    private void cancelLoop(){// 小さいループを取り去る
        int rowSize;
        /*rowSize= row.size();*/
        Nbh n, m, k;
        int p=0,q=0,r=0;
        boolean OK;
        boolean loop;
        do{
            rowSize= row.size();
            /*Log.d("cancelLoop()","rowSize="+rowSize);*/
            loop = true;
            for(int i=0; i<rowSize && loop; i++){
                n = row.get(i);
                for(int j=i+1; j<rowSize && loop; j++){
                    m = row.get(j);
                    OK = false;
                    if(n.a==m.a){
                        p = n.a;
                        q = n.b;
                        r = m.b;
                        OK=true;
                    } else if(n.a == m.b){
                        p = n.a;
                        q = n.b;
                        r = m.a;
                        OK=true;
                    } else if(n.b == m.a){
                        p = n.b;
                        q = n.a;
                        r = m.b;
                        OK=true;
                    } else if(n.b == m.b){
                        p = n.b;
                        q = n.a;
                        r = m.a;
                        OK=true;
                    }
                    if(OK){
                        //Log.d("cancelLoop()",""+i+","+j);
                        for(int h = j+1; h<rowSize && loop; h++){
                            k = row.get(h);
                            if((k.a == q && k.b == r) || (k.b == q && k.a == r)){
                                //Log.d("cancelLoop()","    "+p+","+q+","+r);
                                loop = false;
                                double distPQ = Math.hypot(points.get(p).x-points.get(q).x,points.get(p).y-points.get(q).y);
                                double distPR = Math.hypot(points.get(p).x-points.get(r).x,points.get(p).y-points.get(r).y);
                                double distQR = Math.hypot(points.get(q).x-points.get(r).x,points.get(q).y-points.get(r).y);
                                if(distPQ >= distPR && distPQ >= distQR){ // distPQ is largest
                                    row.remove(i);
                                } else if(distPQ <= distPR && distPR >= distQR ){
                                    row.remove(j);
                                } else {
                                    row.remove(h);
                                }
                            }
                        }
                    }
                }
            }
        } while (!loop);
    }

    private void removeThrone() {//とげを除く//少し軽くできる
        for (int u=points.size ()-1; u>=0; u--) {
            if ( points.get(u).c==1) {
                for (int i=row.size ()-1; i>=0; i--) {
                    Nbh n=row.get(i);
                    if (n.a==u) {
                        if (points.get(n.b).c==3) {
                            removePoint(u,n.b);
                            //removePoint2(u);
                            points.get(n.b).c=2;
                        }
                    } else if (n.b==u) {
                        if (points.get(n.a).c==3) {
                            removePoint(u,n.a);
                            //removePoint2(u);
                            points.get(n.a).c = 2;
                        }
                    }
                }
            }
        }
    }

    private void fillGap() {//点と点の距離の最小を記録し、最小の距離の点が1本さんならばその点と点をつなげる//ここが遅い!!
        for (int u=0; u<points.size (); u++) {
            if ( points.get(u).c==1) {
                double min=width;
                int num=0;
                for (int v=0; v<points.size (); v++) {
                    if (u!=v) {
                        if (points.get(u).n1!=v) {
                            double d = dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
                            if (min>d) {
                                min=d;
                                num=v;
                            }
                        }
                    }
                }
                if (points.get(num).c==1) {
                    addToRow(u, num);
                    //なにかする
                    points.get(num).c++;
                    points.get(u).c++;
                } else if (points.get(num).c==0) {
                    addToRow(u, num);
                    points.get(num).c++;
                    points.get(u).c++;
                }
            }
        }
    }


    private void FindJoint() {//jointを探す
        for (int u=0; u<points.size (); u++) {
            if ( points.get(u).c==1) {
                double min=width;
                int num=0;
                for (int v=0; v<points.size (); v++) {
                    if (u!=v) {
                        int pgu1=points.get(u).n1;
                        // println(pgu1);
                        if (v!=pgu1) {
                            //print("pgu1="+pgu1);
                            if (pgu1!=-1&&v!=points.get(pgu1).n1&&v!=points.get(pgu1).n2) {
                                double d = dist(points.get(u).x, points.get(u).y, points.get(v).x, points.get(v).y);
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
                    if (pgn1!=-1&&points.get(pgn1).Joint) {//隣だったとき
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
                    //隣の隣
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

    private void JointOrientation(){
        for (int i=0; i<points.size (); i++) {
            Beads vec=points.get(i);
            if (vec.Joint) {
                if(vec.u1<0||vec.u1>=points.size()||vec.u2<0||vec.u2>=points.size()){
                    return;
                }
                Beads vecn1=points.get(vec.n1);
                double x0=vecn1.x;
                double y0=vecn1.y;
                Beads vecu1=points.get(vec.u1);
                double x1=vecu1.x;
                double y1=vecu1.y;
                Beads vecn2=points.get(vec.n2);
                double x2=vecn2.x;
                double y2=vecn2.y;
                Beads vecu2=points.get(vec.u2);
                double x3=vecu2.x;
                double y3=vecu2.y;
                double x02=x0-x2;//a
                double y02=y0-y2;//b
                double x13=x1-x3;//c
                double y13=y1-y3;//d
                if(x02*y13-y02*x13>0){
                    int a=vec.u1;
                    vec.u1=vec.u2;
                    vec.u2=a;
                }
            }
        }

    }

    private boolean Ofutarisama() {//みんなお二人様だったか確認
        for (Beads vec : points) {
            if (vec.c!=2) {
                return false;
            }
        }
        return true;
    }

    private void copy_area(int x, int y) {//
        int e[][] = new int[s][s];
        if (x + s > width || y + s > height) {
            return;
        }
        for (int j = 0; j < s; j++) {
            for (int i = 0; i < s; i++) {
                e[i][j] = d[x + i][y + j];
            }
        }
        double XY = 0, X = 0, Y = 0, XX = 0, YY = 0;
        int num = 0;
        for (int j = 0; j < s; j++) {
            for (int i = 0; i < s; i++) {
                if (e[i][j] == 1) {
                    XY += i * j;
                    X += i;
                    Y += j;
                    XX += i * i;
                    YY += j * j;
                    num++;
                }
            }
        }
        int v1 = 0;
        int v2 = 0;
        int v3 = 0;
        int v4 = 0;

        if (num > (s * s) / 10) {//1割以上だったら
            if ((num * XX) - (X * X) > (num * YY) - (Y * Y)) {
                /*double s2 = s*0.5;*/
                double a = (num * XY - X * Y) / ((num * XX) - (X * X));
                double b = (XX * Y - XY * X) / ((num * XX) - (X * X));
                boolean p1 = (b >= 0 && b <= s && d[x][(int) floor(y + b)] == 1);//p1が辺上に乗っているならば
                double k = a * s + b;
                boolean p2 = (k >= 0 && k <= s && d[x + s][(int) floor(y + k)] == 1); //p2が辺上に載っているならば
                double h = -b / a;
                //if(a==0)何か処理が必要
                boolean p3 = (h >= 0 && h <= s && d[(int) floor(x + h)][y] == 1); //p3が辺上に載っているならば
                double l = (s - b) / a;
                boolean p4 = (l >= 0 && l <= s && d[(int) floor(x + l)][y + s] == 1); //p4が辺上に載っているならば
                if (p1) {
                    v1 = addToPoints(x, (y + b));
                    //v1 = addToPoints(x, y+s2);
                }
                if (p2) {
                    v2 = addToPoints(x + s, (y + k));
                    //v2 = addToPoints(x + s, y + s2);
                }
                if (p3) {
                    v3 = addToPoints((x + h), y);
                    //v3 = addToPoints(x + s2, y);
                }
                if (p4) {
                    v4 = addToPoints((x + l), y + s);
                    //v4 = addToPoints(x + s2, y + s);
                }
                if (p1 && p2) {
                    addToRow(v1, v2);
                }
                if (p2 && p3) {
                    addToRow(v2, v3);
                }
                if (p3 && p4) {//加えた
                    addToRow(v3, v4);
                }
                if (p1 && p4) {
                    addToRow(v1, v4);
                }
                if (p1 && p3) {
                    addToRow(v1, v3);
                }
                if (p2 && p4) {
                    addToRow(v2, v4);
                }
            } else {
                double a = (num * XY - X * Y) / ((num * YY) - (Y * Y));
                double b = (YY * X - XY * Y) / ((num * YY) - (Y * Y));
                boolean p1 = (b >= 0 && b <= s && d[(int) (x + b)][y] == 1);//p1が辺上に乗っているならば
                double k = a * s + b;
                boolean p2 = (k >= 0 && k <= s && d[(int) (x + k)][y + s] == 1); //p2が辺上に載っているならば
                double h = -b / a;
                //if(a==0)何か処理が必要
                boolean p3 = (h >= 0 && h <= s && d[x][(int) (y + h)] == 1); //p3が辺上に載っているならば
                double l = (s - b) / a;
                boolean p4 = (l >= 0 && l <= s && d[x + s][(int) (y + l)] == 1); //p4が辺上に載っているならば
                if (p1) {
                    v1 = addToPoints((int) (x + b), y);
                }
                if (p2) {
                    v2 = addToPoints((int) (x + k), y + s);
                }
                if (p3) {
                    v3 = addToPoints(x, (int) (y + h));
                }
                if (p4) {
                    v4 = addToPoints(x + s, (int) (y + l));
                }
                if (p1 && p2) {
                    addToRow(v1, v2);
                }
                if (p2 && p3) {
                    addToRow(v2, v3);
                }
                if (p3 && p4) {//加えた
                    addToRow(v3, v4);
                }
                if (p1 && p4) {
                    addToRow(v1, v4);
                }
                if (p1 && p3) {
                    addToRow(v1, v3);
                }
                if (p2 && p4) {
                    addToRow(v2, v4);
                }
            }
        }
//        boolean OKy=true;
//        int flagy;
//        int i1=0;
//        int i2=s-1;
//        //int i3=0;
//        //int i4=0;
//        for (int j=0; j<s; j++) {
//            flagy=0;
//            for (int i=0; i<s; i++) {
//                if (flagy==0&&e[i][j]==0) {
//                    flagy=1;
//                } else if (flagy==0&&e[i][j]==1) {
//                    flagy=2;
//                    i1=i;
//                } else if (flagy==1&&e[i][j]==1) {
//                    flagy=2;
//                    i1=i;
//                } else if (flagy==2&&e[i][j]==0) {
//                    flagy=3;
//                    i2=i;
//                } else if (flagy==3&&e[i][j]==1) {
//                    flagy=4;
//                }
//            }
//            //if (j==0) {
//            //    i3=((i1+i2)/2);
//            //}
//            //if (j==s-1) {
//            //    i4=((i1+i2)/2);
//            //}
//            if (flagy!=3&&flagy!=2) {
//                OKy=false;
//            }
//        }
//        if (OKy) {
//            for (int j=0; j<s; j++) {
//                for (int i=0; i<s; i++) {
//                    if ( e[i][j]==1) {
//                        //stroke(0, 255, 0);
//                        paint.setColor(Color.argb(255, 0, 255, 0));
//                    } else {
//                        //stroke(0, 0, 255);
//                        paint.setColor(Color.argb(255, 0, 0, 255));
//                    }
//                }
//            }
//            // stroke(0);
//            paint.setColor(Color.argb(255, 0, 0, 0));
//        }
//
//        boolean OKx=true;
//        int flagx;
//        int j1=0;
//        int j2=s-1;
//        //int j3=0;
//        //int j4=0;
//        for (int i=0; i<s; i++) {
//            flagx=0;
//            for (int j=0; j<s; j++) {
//                if (flagx==0&&e[i][j]==0) {
//                    flagx=1;
//                } else if (flagx==0&&e[i][j]==1) {
//                    flagx=2;
//                    j1=j;
//                } else if (flagx==1&&e[i][j]==1) {
//                    flagx=2;
//                    j1=j;
//                } else if (flagx==2&&e[i][j]==0) {
//                    flagx=3;
//                    j2=j;
//                } else if (flagx==3&&e[i][j]==1) {
//                    flagx=4;
//                }
//            }
//            //if (i==0) {
//            //    j3=((j1+j2)/2);
//            //}
//            //if (i==s-1) {
//            //    j4=((j1+j2)/2);
//            //}
//            if (flagx!=3&&flagx!=2) {
//                OKx=false;
//            }
//        }
//        if (OKx) {
//            for (int j=0; j<s; j++) {
//                for (int i=0; i<s; i++) {
//                    if ( e[i][j]==1) {
//                        //stroke(255);
//                        paint.setColor(Color.argb(255, 255, 255, 255));
//                    } else {
//                        //  stroke(0, 0, 255);
//                        paint.setColor(Color.argb(255, 0, 0, 255));
//                    }
//                }
//            }
//            //stroke(0);
//            paint.setColor(Color.argb(255, 0, 0, 0));
//        }
    }

    private int thickness() {//線の太さの平均を計算してくれる
        int count=0;
        int sum=0;
        int num=1;
        boolean flag=false;
        for (int y=100; y<height; y+=100) {
            for (int x=0; x<width; x++) {
                if (d[x][y]==1) {
                    flag=true;
                    count++;
                }
                if (flag && d[x][y]==0) {
                    flag=false;
                    if (count>=5) {
                        sum+=count;
                        num++;
                    }
                    count=0;
                }
            }
        }
        Log.d("thickness",""+(int)Math.floor(sum/num));
        return sum/num;
    }

    private int findJointInPoints(int j,int c) {
        // for (int i = 0; i < points.size(); i++) {
        Beads p=points.get(c);
        if(p.Joint||p.midJoint){
            return c;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        } else if(p.n2==j){
            d=p.n1;
        } else {
            Log.d("間違っている","");
        }
        return findJointInPoints(c,d);
    }

    private int findtrueJointInPoints(int j,int c) {
        // for (int i = 0; i < points.size(); i++) {
        Beads p=points.get(c);
        if(p.Joint){
            return c;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            Log.d("間違っている","");
        }
        return findtrueJointInPoints(c,d);
    }

    private int findNeighborJointInPoints(int j,int c) {
        // for (int i = 0; i < points.size(); i++) {
        Beads p=points.get(c);
        if(p.Joint||p.midJoint){
            return j;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            Log.d("間違っている","");
        }
        return findNeighborJointInPoints(c,d);
    }

    private int countNeighborJointInPoints(int j,int c,int count) {
        Beads p=points.get(c);
        if(p.Joint||p.midJoint){
            return count;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            Log.d("間違っている","");
        }
        return countNeighborJointInPoints(c,d,count+1);
    }

    private int get_half_position(int j,int c,int count){
        if(count==0){
            return c;
        }
        Beads p=points.get(c);
        if(p.Joint){
            Log.d("エラー","");
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            Log.d("間違っている","");
        }
        return get_half_position(c,d,count-1);
    }



    private int findk(Beads joint, int j){
        if(joint.n1==j) {
            return 0;
        }
        else if(joint.u1==j) {
            return 1;
        }else   if(joint.n2==j) {
            return 2;
        }else   if(joint.u2==j) {
            return 3;
        }else {
            return -1;
        }
    }

    private void testFindNextJoint(){//デバック
        for(int i=0;i<points.size();i++){
            Beads a=points.get(i);
            if(a.Joint||a.midJoint){
                //Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
                // Beads b=points.get(a.n1);
                // Beads c=a.findNextJoint(points,b);
                int j=findNeighborJointInPoints(i,a.n1);
                int c=findJointInPoints(i,a.n1);
                int k=findk(points.get(c),j);
                Log.d("0の行先は",""+getNodesFromPoint(c)+","+k);
                //b=points.get(a.n2);
                //c=a.findNextJoint(points,b);
                if(a.Joint) {
                    j = findNeighborJointInPoints(i, a.u1);
                    c = findJointInPoints(i, a.u1);
                    k = findk(points.get(c), j);
                    Log.d("1の行先は", "" + getNodesFromPoint(c) + "," + k);
                }
                j=findNeighborJointInPoints(i,a.n2);
                c=findJointInPoints(i,a.n2);
                k=findk(points.get(c),j);
                Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
                //b=points.get(a.u1);
                //c=a.findNextJoint(points,b);

                //b=points.get(a.u2);
                //c=a.findNextJoint(points,b);
                if(a.Joint) {
                    j = findNeighborJointInPoints(i, a.u2);
                    c = findJointInPoints(i, a.u2);
                    k = findk(points.get(c), j);
                    Log.d("3の行先は", "" + getNodesFromPoint(c) + "," + k);
                }
            }
        }
    }

    private void getNodes(){
        int count=0;
        for(int i = 0; i < points.size(); i++) {
            Beads vec = points.get(i);
            if (vec.Joint||vec.midJoint) {
                count++;
            }
        }
//        Log.d("countの数",""+count);
        table=new int[count];
        count=0;
        for(int i = 0; i < points.size(); i++) {
            Beads vec = points.get(i);
            if (vec.Joint||vec.midJoint) {
                table[count]=i;
                count++;
            }
        }
    }

    private int getNodesFromPoint(int p){
        for(int i = 0; i < table.length; i++) {
            if(table[i]==p){
                return i;
            }
        }
        return -1;
    }

    void getEdges(ArrayList<Edge> edges){
        for(int i=0;i<points.size();i++){
            Beads a=points.get(i);
            if(a.Joint||a.midJoint){
                // Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
                // Beads b=points.get(a.n1);
                // Beads c=a.findNextJoint(points,b);
                int b=findNeighborJointInPoints(i,a.n1);
                int c=findJointInPoints(i,a.n1);
                int j=getNodesFromPoint(c);
                int k=findk(points.get(c),b);
                int h=getNodesFromPoint (i);
                //Log.d("0の行先は",""+getNodesFromPoint(c)+","+k);
                if(j>h) {
                    edges.add(new Edge(h, 0, j, k));
                }
                //b=points.get(a.n2);
                //c=a.findNextJoint(points,b);
                if(a.Joint) {
                    b = findNeighborJointInPoints(i, a.u1);
                    c = findJointInPoints(i, a.u1);
                    j = getNodesFromPoint(c);
                    k = findk(points.get(c), b);
                    // Log.d("1の行先は",""+getNodesFromPoint(c)+","+k);
                    if (j > h) {
                        edges.add(new Edge(h, 1, j, k));
                    }
                }
                b=findNeighborJointInPoints(i,a.n2);
                c=findJointInPoints(i,a.n2);
                j=getNodesFromPoint(c);
                k=findk(points.get(c),b);
                //Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
                if(j>h) {
                    edges.add(new Edge(h, 2, j, k));
                }
                if(a.Joint) {
                    //b=points.get(a.u1);
                    //c=a.findNextJoint(points,b);
                    //b=points.get(a.u2);
                    //c=a.findNextJoint(points,b);
                    b = findNeighborJointInPoints(i, a.u2);
                    c = findJointInPoints(i, a.u2);
                    j = getNodesFromPoint(c);
                    k = findk(points.get(c), b);
                    //Log.d("3の行先は",""+getNodesFromPoint(c)+","+k);
                    if (j > h) {
                        edges.add(new Edge(h, 3, j, k));
                    }
                }
            }
        }
    }
}


