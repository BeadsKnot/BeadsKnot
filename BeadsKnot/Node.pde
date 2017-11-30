class Node {
    double x;
    double y;
    double theta;
    double[] r;//長さ、４つ
    int radius;//円の半径
    double edge_x(int i){
        return x + r[i] * Math.cos(theta+Math.toRadians(i*90));
    }
    double edge_y(int i){
        return y - r[i] * Math.sin(theta+Math.toRadians(i*90));
    }
    double edge_rx(int i, double s){
        return x + s * Math.cos(theta+Math.toRadians(i*90));
    }
    double edge_ry(int i,double s){
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
            r[i]=5;//線の長さ
        }
        Joint=false;
        drawOn = false;
    }
    double getR(int i){
        if(0<=i && i<4) return r[i];
        else return 0;
    }
    void setR(int i,double rr){
        if(0<=i && i<4) r[i] = rr;
    }
    double getX(){ return x;}
    double getY(){ return y;}
    void drawNode(double l, double t, double r, double b){
        double w = r-l;
        double h = b-t;
        double rate;
        if(w>h){
            rate = 1080/w;
        } else {
            rate = 1080/h;
        }
        //ガイドの描画
//        stroke(160, 0, 0);
//        strokeWidth(5);
//        for(int i=0;i<4;i++) {
//           line((float)x, (float)y, (float)edge_x(i), (float)edge_y(i) , p);
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
