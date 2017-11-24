package com.example.aharalab2017_a.beadsknot;

import java.util.Vector;

class joint {
    /*double x;
    double y;*/
    private Vector<Double> d0;//向き
    private Vector<Double> d1;
    private Vector<Double> d2;
    private Vector<Double> d3;
    /*private joint N0;//お隣さん
    private joint N1;
    private joint N2;
    private joint N3;
    private int c0;//どことつながるのか
    private int c1;
    private int c2;
    private int c3;*/

    joint(){
        d0=new Vector<Double>();
        d1=new Vector<Double>();
        d2=new Vector<Double>();
        d3=new Vector<Double>();
    }
    /*public void setd(int n,double a,double b){
        switch (n){
            case 0:
                d0.add(a);
                d0.add(b);
                break;
            case 1:
                d1.add(a);
                d1.add(b);
                break;
            case 2:
                d2.add(a);
                d2.add(b);
                break;
            case 3:
                d3.add(a);
                d3.add(b);
                break;
        }
    }*/

    /*Vector<Double> getd(int n){
        switch (n) {
            case 0:
                return d0;
            case 1:
                return d1;
            case 2:
                return d2;
            case 3:
                return d3;
        }
        return d0;
    } */

    /*void setn(int n,joint N,int c){
        switch (n) {
            case 0:
                N0 = N;
                c0 = c;
                break;
            case 1:
                N1 = N;
                c1 = c;
                break;
            case 2:
                N2 = N;
                c2 = c;
                break;
            case 3:
                N3 = N;
                c3 = c;
                break;
        }
    }*/
}
