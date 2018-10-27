class Node {
    float x;
    float y;
    float theta;//ラジアン
    float[] r;//長さ、４つ
    int radius;//円の半径
    float edge_x(int i){
        return x + r[i] * cos(theta+radians(i*90));
    }
    float edge_y(int i){
        return y - r[i] * sin(theta+radians(i*90));
    }
    float edge_rx(int i, float s){
        return x + s * cos(theta+radians(i*90));
    }
    float edge_ry(int i,float s){
        return y - s * sin(theta+radians(i*90));
    }
    boolean Joint;
    boolean drawOn;
    Node(float _x, float _y){
        x=_x;
        y=_y;
        theta=0;
        r=new float[4];
        radius=20;
        for(int i=0;i<4;i++) {
            r[i]=5;//線の長さ
        }
        Joint=false;
        drawOn = false;
    }
    float getR(int i){
        if(0<=i && i<4) return r[i];
        else return 0;
    }
    void setR(int i,float rr){
        if(0<=i && i<4) r[i] = rr;
    }
    float getX(){ return x;}
    float getY(){ return y;} 
}