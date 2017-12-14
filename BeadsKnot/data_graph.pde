class data_graph{
	
	ArrayList<Node> nodes;
	ArrayList<Edge> edges;
	data_extract de;
	int[] table;

	data_graph(data_extract _de){
		nodes = new ArrayList<Node>();
		edges = new ArrayList<Edge>();
		de = _de;
	}

	void make_data_graph(){//nodesやedgesを決める
	     JointOrientation();
	     add_half_point_Joint();
	     getNodes();
	     testFindNextJoint();
            
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

void set_nodes_edges(){
	/*
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
            //extract.getEdges(edges);
            //  形を整える。
            for(Edge e:edges) {
               // modifyArmsOfAlignments(e);
            }
            for(int i=0;i<100;i++) {
                //modify();
            }
        */
        }

         



}