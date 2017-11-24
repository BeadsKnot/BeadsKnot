package com.example.aharalab2017_a.beadsknot;

import java.util.ArrayList;

class Beads {

    double x,y;
    int c;
    int n1,n2,u1,u2;
    boolean Joint,midJoint;

    Beads(double _x, double _y) {
        x=_x;
        y=_y;
        c=2;
        n1=-1;
        n2=-1;
        u1=-1;
        u2=-1;
        Joint=false;
        midJoint=false;
    }

    /*Beads findNextJoint(ArrayList<Beads> points, Beads _b){
        Beads a=this;
        Beads b=_b;
        Beads c;
        do{
            //cを次のものに設定
            if(points.get(b.n1)==a){
                c=points.get(b.n2);
            }else{
                c=points.get(b.n1);
            }
            a=b;
            b=c;
        }while(!c.Joint);
        return c;
    }*/

    float getTheta(ArrayList<Beads> points){
        Beads neighbor1=points.get(n1);
        double x1=neighbor1.x;
        double y1=neighbor1.y;
        double th=Math.atan2(-y1+y,x1-x);
        return (float)th;
    }
}
