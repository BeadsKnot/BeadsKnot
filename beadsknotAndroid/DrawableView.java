package com.example.aharalab2017_a.beadsknot;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Point;
// android.util.Log;
import android.view.View;

import java.util.ArrayList;

public class DrawableView extends View {
    public ArrayList<Node> nodes = new ArrayList<>();
    public ArrayList<Edge> edges = new ArrayList<>();
    protected boolean isAttached = true;
    Node selected_node = new Node(0,0);
    data_extract extract;
    Bitmap bitmap;

    int drawMode;
    int height,width;
    double _l,_t,_r,_b;

    public DrawableView(Context context) {
        super(context);
    }

    public void addSizeAndBmp(Point size, Bitmap _bmp) {
        setFocusable(true);

        int ww = _bmp.getWidth();
        int hh = _bmp.getHeight();

        width = Math.min(size.x,size.y);
        height = (int)Math.floor(width * hh / ww);

        // 結び目が入っている長方形のサイズの設定
        _l = 0;
        _t = 0;
        _r = width;
        _b = height;
        bitmap=_bmp;

        //　画面をこのサイズでデータ化
        extract=new data_extract(width, height, bitmap);//画面の4分の1のサイズで画像解析する（スピードアップのため）

        /*
         *  0: オリジナル画像
         *  1: オリジナル画像＋折れ線データ
         *  2: 結び目画面
         */
        if(extract.success){
            drawMode = 2;
        } else {
            drawMode = 1;// 読み取りに失敗した場合には、元画像を提示する。
        }
        if(extract.success){
            // 読み取りデータからAlignmentのデータを取り出す。
            for (int i = 0; i < extract.points.size(); i++) {
                Beads vec = extract.points.get(i);
                if (vec.Joint||vec.midJoint) {
                    Node ali=new Node((float)vec.x,(float)vec.y);
                    ali.theta=vec.getTheta(extract.points);
                    if(vec.Joint) {
                        ali.Joint=true;
                    }
                    nodes.add(ali);
                }
            }
            //Log.d("nodesの長さ",""+nodes.size());
            //　Alignmentのデータからedgeのデータを整える。
            extract.getEdges(edges);
            //  形を整える。
            for(Edge e:edges) {
                modifyArmsOfAlignments(e);
            }
            for(int i=0;i<100;i++) {
                modify();
            }
            //Log.d("edgesの長さ",""+edges.size());
        }
    }

    public void setX(float x){
        selected_node.x=x;
    }
    public void setY(float y){
        selected_node.y=y;
    }

    protected void onDraw(Canvas c) {
        super.onDraw(c);
        Paint p = new Paint();

        if(drawMode==0) {
            c.drawBitmap(extract.get_Binarized_img(),  0, 0, p);//リサイズした画像を表示する
        } else if(drawMode == 1) {
            c.drawBitmap(extract.get_Binarized_img(), 0, 0, p);//リサイズした画像を表示する
            extract.drawPoints(c);
            extract.drawRow(c);
            c.drawBitmap(extract.get_Binarized_img(),  extract.getWidth(), 0, p);//リサイズした画像を表示する
        } else if(drawMode == 2) {
            p.setAntiAlias(true);
            for(Node a:nodes) {
                a.draw_Alignment(c,p,_l, _t, _r, _b);
            }
            for(Edge e:edges) {
                e.connect_nodes(p,c,nodes,_l, _t, _r, _b);
            }
            //Log.d("thru","here");
            modify();
        }
    }


    protected void onAttachedToWindow() {
        isAttached = true;
        super.onAttachedToWindow();
    }

    protected void onDetachedFromWindow() {
        isAttached = false;
        super.onDetachedFromWindow();
    }


    protected void modifyArmsOfAlignments(Edge e){
        Node n1 = nodes.get(e.getH());
        Node n2 = nodes.get(e.getJ());
        int a1 = e.getI();
        int a2 = e.getK();
        double r1;
        double r2;
        int count = 0;
        boolean loopGoOn;
        do{
            loopGoOn = false;
            double d1 = Math.hypot(n1.getX() - n1.edge_x(a1), n1.getY() - n1.edge_y(a1));
            double d2 = Math.hypot(n1.edge_x(a1) - n2.edge_x(a2), n1.edge_y(a1) - n2.edge_y(a2));
            double d3 = Math.hypot(n2.getX() - n2.edge_x(a2), n2.getY() - n2.edge_y(a2));
            r1 = n1.getR(a1);
            if(d1 + 3.0 < d2){
                n1.setR(a1, r1+3.0);
                loopGoOn = true;
            } else if(d1 - 3.0 > d2){
                n1.setR(a1, r1-3.0);
                loopGoOn = true;
            }
            r2 = n2.getR(a2);
            if(d3 + 3.0 < d2){
                n2.setR(a2, r2+3.0);
                loopGoOn = true;
            } else if(d3 - 3.0 > d2){
                n2.setR(a2, r2-3.0);
                loopGoOn = true;
            }
        } while (loopGoOn && count++<50);
    }

    protected void modify(){
        //Nodeの座標も微調整したい。
        for(Edge i:edges) {
            i. scaling_shape_modifier(nodes);
        }
        Edge.rotation_shape_modifier(nodes,edges);
    }

}
