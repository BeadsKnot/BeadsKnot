//Edgeのクラス

class Edge {
     int ANodeID;//node
     int ANodeRID;//edge
     int BNodeID;//node
     int BNodeRID;//edge
    Edge(int _ANodeID,int _ANodeRID,int _BNodeID,int _BNodeRID){
        ANodeID=_ANodeID;
        ANodeRID=_ANodeRID;
        BNodeID=_BNodeID;
        BNodeRID=_BNodeRID;
    }

    int getANodeID(){
        return ANodeID;
    }
    int getANodeRID(){
        return ANodeRID;
    }
    int getBNodeID(){
        return BNodeID;
    }
    int getBNodeRID(){
        return BNodeRID;
    }
    //　node と node をつなぐ曲線を描く
    void drawEdgeBezier(ArrayList<Node> nodes, float l, float t, float r, float b){
        // 旧関数名　connect_nodes
        //関数名をdrawEdgeBezierにしたい。
        // スタート地点を移動
        //Log.d("hとjを表示",""+h+"  "+BNodeID);
        float wid = r-l;
        float hei = b-t;
        float rate;
        if(wid>hei){
            rate = 1080/wid;
        } else {
            rate = 1080/hei;
        }
        Node a0=nodes.get(ANodeID);
        Node a1=nodes.get(BNodeID);
        float hx=(a0.x-l)*rate;
        float hy=(a0.y-t)*rate;
        if(ANodeRID==1 || ANodeRID==3) {
            hx = (a0.edge_rx(ANodeRID,30/rate) - l) * rate;
            hy = (a0.edge_ry(ANodeRID,30/rate) - t) * rate;
        }
        float ix=(a0.edge_x(ANodeRID)-l)*rate;
        float iy=(a0.edge_y(ANodeRID)-t)*rate;
        float jx=(a1.x-l)*rate;
        float jy=(a1.y-t)*rate;
        if(BNodeRID==1 || BNodeRID==3){
            jx = (a1.edge_rx(BNodeRID,30/rate)-l)*rate;
            jy = (a1.edge_ry(BNodeRID,30/rate)-l)*rate;
        }
        float kx=(a1.edge_x(BNodeRID)-l)*rate;
        float ky=(a1.edge_y(BNodeRID)-t)*rate;

        stroke(255,0,0,0);
        strokeWeight(5);
        drawCubicBezier(hx,hy,ix,iy,jx,jy,kx,ky);
    }

     float naibun(float p, float q, float t) {
        return (p*(1.0-t)+q*t);
    }

     float coordinate_bezier(float a, float c, float e, float g, float t) {
        float x1 = naibun(a, c, t);
        float x2 = naibun(c, e, t);
        float x3 = naibun(e, g, t);
        float x4 = naibun(x1, x2, t);
        float x5 = naibun(x2, x3, t);
        return naibun(x4, x5, t);
    }

     void drawCubicBezier(float hx, float hy, float ix, float iy, float jx, float jy, float kx, float ky){

    }

     float angle(float ax, float ay, float bx, float by, float cx, float cy) {
        float ang1 = (atan2(ay-by, ax-bx));
        float ang2 = (atan2(by-cy, bx-cx));
        float ret = ang2-ang1;
        if (ret < 0.0) {
            ret = -ret;
        }
        if (ret > PI) {
            ret = (2*PI - ret);
        }
        return ret;
    }
     float get_rangewidth_angle(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
        float ret0 = (PI);
        float ret1 = 0;
        float step=(0.05);// step is 1/20
        float cx = x1;
        float dx = coordinate_bezier(x1, x2, x3, x4, step);
        float cy = y1;
        float dy = coordinate_bezier(y1, y2, y3, y4, step);
        float ex, ey;
        for (float i = step*2; i<=1.0; i += step) {
            ex=coordinate_bezier(x1, x2, x3, x4, i);
            ey=coordinate_bezier(y1, y2, y3, y4, i);
            float ang = angle(cx, cy, dx, dy, ex, ey);
            if (ang < ret0) { // get minimum
                ret0 = ang;
            }
            if (ang > ret1) { // get maximum
                ret1 = ang;
            }
            cx = dx;
            cy = dy;
            dx = ex;
            dy = ey;
        }
        return ret1-ret0;
    }

    /*public void print_get_rangewidth_angle(ArrayList<Node> nodes){
        Node a0=nodes.get(ANodeID);
        Node a1=nodes.get(BNodeID);
        float x1=a0.x;
        float y1=a0.y;
        float x2=a0.edge_x(i);
        float y2=a0.edge_y(i);
        float x3=a1.edge_x(k);
        float y3=a1.edge_y(k);
        float x4=a1.x;
        float y4=a1.y;
        Log.d("CHECK",":" +get_rangewidth_angle(x1,y1,x2,y2,x3,y3,x4,y4) + "," );
    }*/

    void scaling_shape_modifier(ArrayList<Node> nodes) {//四本の線の長さを変えることで形を整える
        // E=min of angle;
        // minimize E
        // if (0<=e1 && e1<4 && 0<=e2 && e2<4 && is_gv_id(i1) && is_gv_id(i2) ) {
        Node a0=nodes.get(ANodeID);
        Node a1=nodes.get(BNodeID);
        float r1=a0.r[ANodeRID];
        float r2=a1.r[BNodeRID];
        float angle1 = (a0.theta+PI*ANodeRID/2);
        // float angle1 = x + r[i] * ( cos(theta+toRadians(i*90)));
        float angle2 = (a1.theta+PI*BNodeRID/2);
        //float angle2 = x + r[i] * ( cos(theta+toRadians(i*90)));
        float x1=a0.x;
        float y1=a0.y;
        float x4=a1.x;
        float y4=a1.y;
        float x2=(x1+r1*cos(angle1));
        float y2=(y1-r1*sin(angle1));
        //float y2 = x + r[i] * ( cos(theta+toRadians(i*90)));
        float x3=(x4+r2*cos(angle2));
        float y3=(y4-r2*sin(angle2));
        //  float y3 = x + r[i] * ( cos(theta+toRadians(i*90)));
        float dst= dist(x1, y1, x4, y4);
        int count=0;
        do {
            float e11=get_rangewidth_angle(x1, y1, x2, y2, x3, y3, x4, y4);
            float e21=get_rangewidth_angle(x1, y1, (x2+cos(angle1)), (y2-sin(angle1)), x3, y3, x4, y4);
            float e01=get_rangewidth_angle(x1, y1, (x2-cos(angle1)), (y2+sin(angle1)), x3, y3, x4, y4);
            float e12=get_rangewidth_angle(x1, y1, x2, y2, (x3+cos(angle2)), (y3-sin(angle2)), x4, y4);
            float e10=get_rangewidth_angle(x1, y1, x2, y2, (x3-cos(angle2)), (y3+sin(angle2)), x4, y4);
            if (e11>e01&&r1>10) {
                r1--;
                // if (r1<beadsDistance) {
                //   r1=beadsDistance;
                //}
            } else if (e11>e21) {
                if (r1+1 < dst) {
                    r1++;
                }
            } else if (e11>e10&&r2>10) {
                r2--;
                //if (r2<beadsDistance) {
                //  r2=beadsDistance;
                //}
            } else if (e11>e12) {
                if (r2+1 < dst) {
                    r2++;
                }
            } else {
                break;
            }
            x2=(x1+r1*cos(angle1));
            y2=(y1-r1*sin(angle1));
            x3=(x4+r2*cos(angle2));
            y3=(y4-r2*sin(angle2));
        }
        while (++count <10);
        a0.r[ANodeRID]=r1;
        a1.r[BNodeRID]=r2;
    }
     float dist(float x1,float y1,float x2,float y2){//2点間の距離
        return (sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)));
    }

    void rotation_shape_modifier(ArrayList<Node> nodes, ArrayList<Edge> edges) {//円を自動で回転させる
        float e0, e0p, e0m, e0r;
        for (int h = 0; h < nodes.size (); h ++) {
            /* Node node=nodes.get(h); */
            e0 = e0p = e0m = e0r = 0;
            for (int i = 0; i < 4; i ++) {
                // int i2=node.edges[BNodeID];
                int e1=-1,e2=-1,i1=-1,i2=-1;
                for(Edge e:edges){
                    if(h==e.ANodeID&&i==e.ANodeRID){
                        i1=h;
                        i2=e.BNodeID;
                        e1=i;
                        e2=e.BNodeRID;
                        break;
                    }else if(h==e.BNodeID && i==e.BNodeRID){
                        i1=h;
                        i2=e.ANodeID;
                        e1=i;
                        e2=e.ANodeRID;
                        break;
                    }
                }
                if (i1!=-1&&i2!=-1&&e1!=-1&&e2!=-1) {
                    Node a1 = nodes.get(i1);
                    Node a2 = nodes.get(i2);
                    float r1=a1.r[e1];
                    float r2=a2.r[e2];
                    float angle1 = (a1.theta+PI*e1/2);
                    float angle2 = (a2.theta+PI*e2/2);
                    float x1=a1.x;
                    float y1=a1.y;
                    float x4=a2.x;
                    float y4=a2.y;
                    float x2=(x1+r1*cos(angle1));
                    float y2=(y1-r1*sin(angle1));
                    float x2p=(x1+r1*cos(angle1+0.05));
                    float y2p=(y1-r1*sin(angle1+0.05));
                    float x2m=(x1+r1*cos(angle1-0.05));
                    float y2m=(y1-r1*sin(angle1-0.05));
                    float x2r=(x1+10*cos(angle1+PI));
                    float y2r=(y1-10*sin(angle1+PI));
                    float x3=(x4+r2*cos(angle2));
                    float y3=(y4-r2*sin(angle2));
                    float e11=get_rangewidth_angle(x1, y1, x2, y2, x3, y3, x4, y4);
                    float e11p=get_rangewidth_angle(x1, y1, x2p, y2p, x3, y3, x4, y4);
                    float e11m=get_rangewidth_angle(x1, y1, x2m, y2m, x3, y3, x4, y4);
                    float e11r=get_rangewidth_angle(x1, y1, x2r, y2r, x3, y3, x4, y4);
                    e0 += e11;
                    e0p += e11p;
                    e0m += e11m;
                    e0r += e11r;
                }
            }
            /*if (e0r < e0) {
                nodes.get(ANodeID).theta += PI;
            } else */
            if (e0>e0p && e0m>e0) {
                nodes.get(ANodeID).theta +=0.05;
            } else if (e0>e0m && e0p>e0) {
                nodes.get(ANodeID).theta -=0.05;
            } /*else {
                Log.d("check","do nothing");
            }*/
        }
    }

     float getXIntersectionWithInterval(float ox, float oy, float sx,float sy, float tx,float ty){
        if((sy-oy)*(ty-oy)>0){
            return -9999.0;
        }
        float t = (sy-oy)/(sy-ty);// sy is not equal to ty here
        float dx = sx - (sx-tx)*t;
        if(ox < dx){
            return dx;
        } else {
            return -9999.0;
        }
    }

    float getXIntersectionWithBezier(float ox, float oy, ArrayList<Node> nodes){
        Node a0 = nodes.get(ANodeID);
        Node a1 = nodes.get(BNodeID);
        float hx=a0.x;
        float hy=a0.y;
        float ix=a0.edge_x(ANodeRID);
        float iy=a0.edge_y(ANodeRID);
        float jx=a1.x;
        float jy=a1.y;
        float kx=a1.edge_x(BNodeRID);
        float ky=a1.edge_y(BNodeRID);
        float step = 0.1;
        float ret = 9999.0;
        for(float t = 0.0; t<1.0-step; t += step){
            float sx = coordinate_bezier(hx,ix,kx,jx,t);
            float sy = coordinate_bezier(hy,iy,ky,jy,t);
            float tx = coordinate_bezier(hx,ix,kx,jx,t+step);
            float ty = coordinate_bezier(hy,iy,ky,jy,t+step);
            float xx = getXIntersectionWithInterval(ox,oy,sx,sy,tx,ty);
            if(-9998 < xx && xx<ret){
                ret = xx;
            }
        }
        return ret;
    }

    // TODO : call setDrawOn from MainActivity
    // TODO : add  'orientation' as input
    void setDrawOn(ArrayList<Node> nodes, ArrayList<Edge> edges){
        Edge thisEdge = this;
        Edge cursorEdge = this;
        boolean orientation = true;
        int count=0;
        do{
            if(orientation){
                nodes.get(cursorEdge.ANodeID).drawOn = true;
                int newH = cursorEdge.BNodeID;
                int newI = cursorEdge.BNodeRID;
                for(Edge e : edges){
                    boolean newHJoint = nodes.get(newH).Joint;
                    if(newHJoint){
                        if(newH == e.ANodeID && (newI+1)%4 == e.ANodeRID){
                        //orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newH == e.BNodeID && (newI+1)%4 == e.BNodeRID) {
                            orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    } else {
                        if(newH == e.ANodeID && (newI+2)%4 == e.ANodeRID){
                            //orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newH == e.BNodeID && (newI+2)%4 == e.BNodeRID) {
                            orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    }
                }
            } else {
                nodes.get(cursorEdge.BNodeID).drawOn = true;
                int newJ = cursorEdge.ANodeID;
                int newK = cursorEdge.ANodeRID;
                for(Edge e : edges){
                    boolean newJJoint = nodes.get(newJ).Joint;
                    if(newJJoint){
                        if(newJ == e.ANodeID && (newK+1)%4 == e.ANodeRID){
                            orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newJ == e.BNodeID && (newK+1)%4 == e.BNodeRID){
                            //orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    } else {
                        if(newJ == e.ANodeID && (newK+2)%4 == e.ANodeRID){
                            orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newJ == e.BNodeID && (newK+2)%4 == e.BNodeRID){
                            //orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    }
                }
            }
            println("getArea:" + cursorEdge.getName());
        } while ( ++count<30 && cursorEdge != thisEdge);
        nodes.get(cursorEdge.BNodeID).drawOn = true;//maybe no need
        //nodes.drawOn=true;
    }

    String getName(){
        return "("+ANodeID+","+ANodeRID+";"+BNodeID+","+BNodeRID+")";
    }
}

class EdgeConst {
  
}
