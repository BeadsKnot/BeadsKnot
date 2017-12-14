class data_graph{
	
	ArrayList<Node> nodes;
	ArrayList<Edge> edges;
	data_extract de; 
	int[] table;

	data_graph(data_extract _de){
		nodes = new ArrayList<Node>();
		edges = new ArrayList<Edge>();
		de = _de;
		make_data_graph();
	}

	void make_data_graph(){//nodesやedgesを決める
	     JointOrientation();
	     add_half_point_Joint();
	     getNodes();
	     testFindNextJoint();
	     set_nodes_edges();

            
	}
	void JointOrientation(){
        for (int i=0; i<de.points.size (); i++) {
            Beads vec=de.points.get(i);
            if (vec.Joint) {
                if(vec.u1<0||vec.u1>=de.points.size()||vec.u2<0||vec.u2>=de.points.size()){
                    return;
                }
                Beads vecn1=de.points.get(vec.n1);
                double x0=vecn1.x;
                double y0=vecn1.y;
                Beads vecu1=de.points.get(vec.u1);
                double x1=vecu1.x;
                double y1=vecu1.y;
                Beads vecn2=de.points.get(vec.n2);
                double x2=vecn2.x;
                double y2=vecn2.y;
                Beads vecu2=de.points.get(vec.u2);
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
     void add_half_point_Joint() {
        for (int i = 0; i < de.points.size(); i++) {
            Beads a = de.points.get(i);
            if(a.Joint){
                int c=findtrueJointInPoints(i,a.n1);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.n1, 0);
                    int half = get_half_position(i, a.n1, count / 2);
                    de.points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.u1);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.u1, 0);
                    int half = get_half_position(i, a.u1, count / 2);
                    de.points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.n2);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.n2, 0);
                    int half = get_half_position(i, a.n2, count / 2);
                    de.points.get(half).midJoint=true;
                }
                c=findtrueJointInPoints(i,a.u2);
                if(i<c){
                    int count = countNeighborJointInPoints(i, a.u2, 0);
                    int half = get_half_position(i, a.u2, count / 2);
                    de.points.get(half).midJoint=true;
                }

            }
        }
    }
     int findtrueJointInPoints(int j,int c) {
        // for (int i = 0; i < de.points.size(); i++) {
        Beads p=de.points.get(c);
        if(p.Joint){
            return c;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            println("間違っている");
        }
        return findtrueJointInPoints(c,d);
    }

    int findNeighborJointInPoints(int j,int c) {
        // for (int i = 0; i < de.points.size(); i++) {
        Beads p=de.points.get(c);
        if(p.Joint||p.midJoint){
            return j;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
            println("間違っている");
        }
        return findNeighborJointInPoints(c,d);
    }

    private int countNeighborJointInPoints(int j,int c,int count) {
        Beads p=de.points.get(c);
        if(p.Joint||p.midJoint){
            return count;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
           // Log.d("間違っている","");
        }
        return countNeighborJointInPoints(c,d,count+1);
    }
     int get_half_position(int j,int c,int count){
        if(count==0){
            return c;
        }
        Beads p=de.points.get(c);
        if(p.Joint){
            //Log.d("エラー","");
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        }else if(p.n2==j){
            d=p.n1;
        }else{
           // Log.d("間違っている","");
        }
        return get_half_position(c,d,count-1);
    }
    void getNodes(){
        int count=0;
        for(int i = 0; i < de.points.size(); i++) {
            Beads vec = de.points.get(i);
            if (vec.Joint||vec.midJoint) {
                count++;
            }
        }
//        Log.d("countの数",""+count);
        table=new int[count];
        count=0;
        for(int i = 0; i < de.points.size(); i++) {
            Beads vec = de.points.get(i);
            if (vec.Joint||vec.midJoint) {
                table[count]=i;
                count++;
            }
        }
    }
     private void testFindNextJoint(){//デバック
        for(int i=0;i<de.points.size();i++){
            Beads a=de.points.get(i);
            if(a.Joint||a.midJoint){
                //Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
                // Beads b=points.get(a.n1);
                // Beads c=a.findNextJoint(points,b);
                int j=findNeighborJointInPoints(i,a.n1);
                int c=findJointInPoints(i,a.n1);
                int k=findk(de.points.get(c),j);
                //Log.d("0の行先は",""+getNodesFromPoint(c)+","+k);
                //b=points.get(a.n2);
                //c=a.findNextJoint(points,b);
                if(a.Joint) {
                    j = findNeighborJointInPoints(i, a.u1);
                    c = findJointInPoints(i, a.u1);
                    k = findk(de.points.get(c), j);
                    //Log.d("1の行先は", "" + getNodesFromPoint(c) + "," + k);
                }
                j=findNeighborJointInPoints(i,a.n2);
                c=findJointInPoints(i,a.n2);
                k=findk(de.points.get(c),j);
                //Log.d("2の行先は",""+getNodesFromPoint(c)+","+k);
                //b=points.get(a.u1);
                //c=a.findNextJoint(points,b);

                //b=points.get(a.u2);
                //c=a.findNextJoint(points,b);
                if(a.Joint) {
                    j = findNeighborJointInPoints(i, a.u2);
                    c = findJointInPoints(i, a.u2);
                    k = findk(de.points.get(c), j);
                   // Log.d("3の行先は", "" + getNodesFromPoint(c) + "," + k);
                }
            }
        }
    }
    int findJointInPoints(int j,int c) {
        // for (int i = 0; i < points.size(); i++) {
        Beads p=de.points.get(c);
        if(p.Joint||p.midJoint){
            return c;
        }
        int d=0;
        if(p.n1==j){
            d=p.n2;
        } else if(p.n2==j){
            d=p.n1;
        } else {
            //Log.d("間違っている","");
        }
        return findJointInPoints(c,d);
    }

    int findk(Beads joint, int j){
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

 int getNodesFromPoint(int p){
        for(int i = 0; i < table.length; i++) {
            if(table[i]==p){
                return i;
            }
        }
        return -1;
    }

    void getEdges(ArrayList<Edge> edges){
        for(int i=0;i<de.points.size();i++){
            Beads a=de.points.get(i);
            if(a.Joint||a.midJoint){
                // Log.d("getNodesFromPoint(i)は",""+getNodesFromPoint(i));
                // Beads b=points.get(a.n1);
                // Beads c=a.findNextJoint(points,b);
                int b=findNeighborJointInPoints(i,a.n1);
                int c=findJointInPoints(i,a.n1);
                int j=getNodesFromPoint(c);
                int k=findk(de.points.get(c),b);
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
                    k = findk(de.points.get(c), b);
                    // Log.d("1の行先は",""+getNodesFromPoint(c)+","+k);
                    if (j > h) {
                        edges.add(new Edge(h, 1, j, k));
                    }
                }
                b=findNeighborJointInPoints(i,a.n2);
                c=findJointInPoints(i,a.n2);
                j=getNodesFromPoint(c);
                k=findk(de.points.get(c),b);
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
                    k = findk(de.points.get(c), b);
                    //Log.d("3の行先は",""+getNodesFromPoint(c)+","+k);
                    if (j > h) {
                        edges.add(new Edge(h, 3, j, k));
                    }
                }
            }
        }
    }
void modifyArmsOfAlignments(Edge e){
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

   void modify(){
        //Nodeの座標も微調整したい。
        for(Edge i:edges) {
            i. scaling_shape_modifier(nodes);
        }
        //Edge.rotation_shape_modifier(nodes,edges);
    }

void set_nodes_edges(){
      // 読み取りデータからAlignmentのデータを取り出す。
            for (int i = 0; i < de.points.size(); i++) {
                Beads vec = de.points.get(i);
                if (vec.Joint||vec.midJoint) {
                    Node ali=new Node((float)vec.x,(float)vec.y);
                    ali.theta=vec.getTheta(de.points);
                    if(vec.Joint) {
                       ali.Joint=true;
                    }
                    nodes.add(ali);
                }
            }
            //Log.d("nodesの長さ",""+nodes.size());
            //　Alignmentのデータからedgeのデータを整える。
            getEdges(edges);
            //  形を整える。
            for(Edge e:edges) {
                modifyArmsOfAlignments(e);
            }
            for(int i=0;i<100;i++) {
               // modify();
            }
        }
       
}