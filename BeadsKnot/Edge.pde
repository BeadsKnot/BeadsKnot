class Edge {
     int h;//node
     int i;//edge
     int j;//node
     int k;//edge
    Edge(int _h,int _i,int _j,int _k){
        h=_h;
        i=_i;
        j=_j;
        k=_k;
    }

    int getH(){
        return h;
    }
    int getI(){
        return i;
    }
    int getJ(){
        return j;
    }
    int getK(){
        return k;
    }
    //　node と node をつなぐ曲線を描く
    void drawEdgeBezier(ArrayList<Node> nodes, double l, double t, double r, double b){
        // 旧関数名　connect_nodes
        //関数名をdrawEdgeBezierにしたい。
        // スタート地点を移動
        //Log.d("hとjを表示",""+h+"  "+j);
        double wid = r-l;
        double hei = b-t;
        double rate;
        if(wid>hei){
            rate = 1080/wid;
        } else {
            rate = 1080/hei;
        }
        Node a0=nodes.get(h);
        Node a1=nodes.get(j);
        double hx=(a0.x-l)*rate;
        double hy=(a0.y-t)*rate;
        if(i==1 || i==3) {
            hx = (a0.edge_rx(i,30/rate) - l) * rate;
            hy = (a0.edge_ry(i,30/rate) - t) * rate;
        }
        double ix=(a0.edge_x(i)-l)*rate;
        double iy=(a0.edge_y(i)-t)*rate;
        double jx=(a1.x-l)*rate;
        double jy=(a1.y-t)*rate;
        if(k==1 || k==3){
            jx = (a1.edge_rx(k,30/rate)-l)*rate;
            jy = (a1.edge_ry(k,30/rate)-l)*rate;
        }
        double kx=(a1.edge_x(k)-l)*rate;
        double ky=(a1.edge_y(k)-t)*rate;

        stroke(255,0,0,0);
        strokeWeight(5);
        drawCubicBezier(hx,hy,ix,iy,jx,jy,kx,ky);
    }

     double naibun(double p, double q, double t) {
        return (p*(1.0-t)+q*t);
    }

     double coordinate_bezier(double a, double c, double e, double g, double t) {
        double x1 = naibun(a, c, t);
        double x2 = naibun(c, e, t);
        double x3 = naibun(e, g, t);
        double x4 = naibun(x1, x2, t);
        double x5 = naibun(x2, x3, t);
        return naibun(x4, x5, t);
    }

     void drawCubicBezier(double hx, double hy, double ix, double iy, double jx, double jy, double kx, double ky){

    }

     double angle(double ax, double ay, double bx, double by, double cx, double cy) {
        double ang1 = (Math.atan2(ay-by, ax-bx));
        double ang2 = (Math.atan2(by-cy, bx-cx));
        double ret = ang2-ang1;
        if (ret < 0.0) {
            ret = -ret;
        }
        if (ret > Math.PI) {
            ret = (2*Math.PI - ret);
        }
        return ret;
    }
     double get_rangewidth_angle(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
        double ret0 = (Math.PI);
        double ret1 = 0;
        double step=(0.05);// step is 1/20
        double cx = x1;
        double dx = coordinate_bezier(x1, x2, x3, x4, step);
        double cy = y1;
        double dy = coordinate_bezier(y1, y2, y3, y4, step);
        double ex, ey;
        for (double i = step*2; i<=1.0; i += step) {
            ex=coordinate_bezier(x1, x2, x3, x4, i);
            ey=coordinate_bezier(y1, y2, y3, y4, i);
            double ang = angle(cx, cy, dx, dy, ex, ey);
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
        Node a0=nodes.get(h);
        Node a1=nodes.get(j);
        double x1=a0.x;
        double y1=a0.y;
        double x2=a0.edge_x(i);
        double y2=a0.edge_y(i);
        double x3=a1.edge_x(k);
        double y3=a1.edge_y(k);
        double x4=a1.x;
        double y4=a1.y;
        Log.d("CHECK",":" +get_rangewidth_angle(x1,y1,x2,y2,x3,y3,x4,y4) + "," );
    }*/

    void scaling_shape_modifier(ArrayList<Node> nodes) {//四本の線の長さを変えることで形を整える
        // E=min of angle;
        // minimize E
        // if (0<=e1 && e1<4 && 0<=e2 && e2<4 && is_gv_id(i1) && is_gv_id(i2) ) {
        Node a0=nodes.get(h);
        Node a1=nodes.get(j);
        double r1=a0.r[i];
        double r2=a1.r[k];
        double angle1 = (a0.theta+Math.PI*i/2);
        // double angle1 = x + r[i] * ( Math.cos(theta+Math.toRadians(i*90)));
        double angle2 = (a1.theta+Math.PI*k/2);
        //double angle2 = x + r[i] * ( Math.cos(theta+Math.toRadians(i*90)));
        double x1=a0.x;
        double y1=a0.y;
        double x4=a1.x;
        double y4=a1.y;
        double x2=(x1+r1*Math.cos(angle1));
        double y2=(y1-r1*Math.sin(angle1));
        //double y2 = x + r[i] * ( Math.cos(theta+Math.toRadians(i*90)));
        double x3=(x4+r2*Math.cos(angle2));
        double y3=(y4-r2*Math.sin(angle2));
        //  double y3 = x + r[i] * ( Math.cos(theta+Math.toRadians(i*90)));
        double dst= dist(x1, y1, x4, y4);
        int count=0;
        do {
            double e11=get_rangewidth_angle(x1, y1, x2, y2, x3, y3, x4, y4);
            double e21=get_rangewidth_angle(x1, y1, (x2+Math.cos(angle1)), (y2-Math.sin(angle1)), x3, y3, x4, y4);
            double e01=get_rangewidth_angle(x1, y1, (x2-Math.cos(angle1)), (y2+Math.sin(angle1)), x3, y3, x4, y4);
            double e12=get_rangewidth_angle(x1, y1, x2, y2, (x3+Math.cos(angle2)), (y3-Math.sin(angle2)), x4, y4);
            double e10=get_rangewidth_angle(x1, y1, x2, y2, (x3-Math.cos(angle2)), (y3+Math.sin(angle2)), x4, y4);
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
            x2=(x1+r1*Math.cos(angle1));
            y2=(y1-r1*Math.sin(angle1));
            x3=(x4+r2*Math.cos(angle2));
            y3=(y4-r2*Math.sin(angle2));
        }
        while (++count <10);
        a0.r[i]=r1;
        a1.r[k]=r2;
    }
     double dist(double x1,double y1,double x2,double y2){//2点間の距離
        return (Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)));
    }

    void rotation_shape_modifier(ArrayList<Node> nodes, ArrayList<Edge> edges) {//円を自動で回転させる
        double e0, e0p, e0m, e0r;
        for (int h = 0; h < nodes.size (); h ++) {
            /* Node node=nodes.get(h); */
            e0 = e0p = e0m = e0r = 0;
            for (int i = 0; i < 4; i ++) {
                // int i2=node.edges[j];
                int e1=-1,e2=-1,i1=-1,i2=-1;
                for(Edge e:edges){
                    if(h==e.h&&i==e.i){
                        i1=h;
                        i2=e.j;
                        e1=i;
                        e2=e.k;
                        break;
                    }else if(h==e.j&&i==e.k){
                        i1=h;
                        i2=e.h;
                        e1=i;
                        e2=e.i;
                        break;
                    }
                }
                if (i1!=-1&&i2!=-1&&e1!=-1&&e2!=-1) {
                    Node a1 = nodes.get(i1);
                    Node a2 = nodes.get(i2);
                    double r1=a1.r[e1];
                    double r2=a2.r[e2];
                    double angle1 = (a1.theta+Math.PI*e1/2);
                    double angle2 = (a2.theta+Math.PI*e2/2);
                    double x1=a1.x;
                    double y1=a1.y;
                    double x4=a2.x;
                    double y4=a2.y;
                    double x2=(x1+r1*Math.cos(angle1));
                    double y2=(y1-r1*Math.sin(angle1));
                    double x2p=(x1+r1*Math.cos(angle1+0.05));
                    double y2p=(y1-r1*Math.sin(angle1+0.05));
                    double x2m=(x1+r1*Math.cos(angle1-0.05));
                    double y2m=(y1-r1*Math.sin(angle1-0.05));
                    double x2r=(x1+10*Math.cos(angle1+Math.PI));
                    double y2r=(y1-10*Math.sin(angle1+Math.PI));
                    double x3=(x4+r2*Math.cos(angle2));
                    double y3=(y4-r2*Math.sin(angle2));
                    double e11=get_rangewidth_angle(x1, y1, x2, y2, x3, y3, x4, y4);
                    double e11p=get_rangewidth_angle(x1, y1, x2p, y2p, x3, y3, x4, y4);
                    double e11m=get_rangewidth_angle(x1, y1, x2m, y2m, x3, y3, x4, y4);
                    double e11r=get_rangewidth_angle(x1, y1, x2r, y2r, x3, y3, x4, y4);
                    e0 += e11;
                    e0p += e11p;
                    e0m += e11m;
                    e0r += e11r;
                }
            }
            /*if (e0r < e0) {
                nodes.get(h).theta += Math.PI;
            } else */
            if (e0>e0p && e0m>e0) {
                nodes.get(h).theta +=0.05;
            } else if (e0>e0m && e0p>e0) {
                nodes.get(h).theta -=0.05;
            } /*else {
                Log.d("check","do nothing");
            }*/
        }
    }

     double getXIntersectionWithInterval(double ox, double oy, double sx,double sy, double tx,double ty){
        if((sy-oy)*(ty-oy)>0){
            return -9999.0;
        }
        double t = (sy-oy)/(sy-ty);// sy is not equal to ty here
        double dx = sx - (sx-tx)*t;
        if(ox < dx){
            return dx;
        } else {
            return -9999.0;
        }
    }

    double getXIntersectionWithBezier(double ox, double oy, ArrayList<Node> nodes){
        Node a0 = nodes.get(h);
        Node a1 = nodes.get(j);
        double hx=a0.x;
        double hy=a0.y;
        double ix=a0.edge_x(i);
        double iy=a0.edge_y(i);
        double jx=a1.x;
        double jy=a1.y;
        double kx=a1.edge_x(k);
        double ky=a1.edge_y(k);
        double step = 0.1;
        double ret = 9999.0;
        for(double t = 0.0; t<1.0-step; t += step){
            double sx = coordinate_bezier(hx,ix,kx,jx,t);
            double sy = coordinate_bezier(hy,iy,ky,jy,t);
            double tx = coordinate_bezier(hx,ix,kx,jx,t+step);
            double ty = coordinate_bezier(hy,iy,ky,jy,t+step);
            double xx = getXIntersectionWithInterval(ox,oy,sx,sy,tx,ty);
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
                nodes.get(cursorEdge.h).drawOn = true;
                int newH = cursorEdge.j;
                int newI = cursorEdge.k;
                for(Edge e : edges){
                    boolean newHJoint = nodes.get(newH).Joint;
                    if(newHJoint){
                        if(newH == e.h && (newI+1)%4 == e.i){
                        //orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newH == e.j && (newI+1)%4 == e.k) {
                            orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    } else {
                        if(newH == e.h && (newI+2)%4 == e.i){
                            //orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newH == e.j && (newI+2)%4 == e.k) {
                            orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    }
                }
            } else {
                nodes.get(cursorEdge.j).drawOn = true;
                int newJ = cursorEdge.h;
                int newK = cursorEdge.i;
                for(Edge e : edges){
                    boolean newJJoint = nodes.get(newJ).Joint;
                    if(newJJoint){
                        if(newJ == e.h && (newK+1)%4 == e.i){
                            orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newJ == e.j && (newK+1)%4 == e.k){
                            //orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    } else {
                        if(newJ == e.h && (newK+2)%4 == e.i){
                            orientation = true;
                            cursorEdge = e;
                            break;
                        } else if(newJ == e.j && (newK+2)%4 == e.k){
                            //orientation = false;
                            cursorEdge = e;
                            break;
                        }
                    }
                }
            }
            println("getArea:" + cursorEdge.getName());
        } while ( ++count<30 && cursorEdge != thisEdge);
        //nodes.get(cursorEdge.j).drawOn = true;//maybe no need
    }

    String getName(){
        return "("+h+","+i+";"+j+","+k+")";
    }
}


