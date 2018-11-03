class mouseDrag {
  ArrayList<PVector> trace;
  PVector prev;
  
boolean node_dragging=false;
boolean node_next_dragging =false;
int dragged_nodeID = -1;
float dragged_theta = 0f;
float nd_theta = 0f;
float DragX = 0f;
float DragY = 0f;
float PressX = 0;
float PressY = 0;
  
  mouseDrag(){
    trace = new ArrayList<PVector>();
  }
  
  void draw_trace(){
    if (trace.size()>1) {
      PVector p0 = trace.get(0);
      for (int t=1; t<trace.size(); t++) {
        stroke(128);
        noFill();
        PVector p1 = trace.get(t);
        line(p0.x, p0.y, p1.x, p1.y);
        p0 = p1;
      }
      if (trace.size()>3) {
        p0 = mouse.trace.get(0);
        if (dist(p0.x, p0.y, mouseX, mouseY)<30) {
          stroke(128);
          fill(255, 180, 180);
          ellipse(p0.x, p0.y, 60, 60);
        }
      }
    }
  }
  
  void trace_to_beads(data_extract data, data_graph graph){
    data.points.clear();
    int traceNumber = trace.size();
    // まず1列のbeadの列を作る。
    for(int tr = 0; tr < traceNumber; tr++){
      Bead bd = new Bead(trace.get(tr).x, trace.get(tr).y);
      bd.n1 = (tr+1)%traceNumber;
      bd.n2 = (tr+traceNumber-1)%traceNumber;
      bd.c = 2;
      data.points.add(bd);
    }
    for(int tr1 = 0; tr1 < traceNumber; tr1+=2){
      for(int tr2 = tr1+1; tr2 < traceNumber; tr2+=2){
        int difference = (tr2-tr1+2*traceNumber)%traceNumber;
        if(2 < difference && difference < traceNumber -2){
          float x1 = trace.get(tr1).x;
          float y1 = trace.get(tr1).y;
          float x2 = trace.get((tr1+2)%traceNumber).x;
          float y2 = trace.get((tr1+2)%traceNumber).y;
          float x3 = trace.get(tr2).x;
          float y3 = trace.get(tr2).y;
          float x4 = trace.get((tr2+2)%traceNumber).x;
          float y4 = trace.get((tr2+2)%traceNumber).y;
          // (x2-x1)s+x1 = (x4-x3)t+x3 
          // (y2-y1)s+y1 = (y4-y3)t+y3
          //   (x2-x1)s - (x4-x3)t = +x3-x1 
          //   (y2-y1)s - (y4-y3)t = +y3-y1
          float a = x2 - x1;
          float b = -x4 + x3;
          float c = y2 - y1;
          float d = -y4 + y3;
          float p = x3 - x1;
          float q = y3 - y1;
          float s1 = p * d - b * q;  // s = s1/st
          float t1 = a * q - p * c;  // t = t1/st
          float st = a * d - b * c; 
          if( st < 0 ){
            st *= -1;
            s1 *= -1;
            t1 *= -1;
          }
          if(0 < s1 && s1 < st && 0 < t1 && t1 < st){
            //trace.get(tr1+1) と trace.get(tr2+1)とを合流してJointにする。
            int jt = (tr1+1)%traceNumber;
            int jt2 = (tr2+1)%traceNumber;
            println(jt,"meets",jt2);
            Bead jtBead = data.points.get(jt);
            Bead jt2Bead = data.points.get(jt2);
            jtBead.Joint = true;
            jtBead.u1 = jt2Bead.n1;
            jtBead.u2 = jt2Bead.n2;
            jt2Bead.n1 = -1;
            jt2Bead.n2 = -1;
            jt2Bead.x = jt2Bead.y = -1f;
            data.points.get(tr2).n1 = jt;
            data.points.get((tr2+2)%traceNumber).n2 = jt;
            
           }
        }
      }
    }
    graph.make_data_graph();
    println("complete mouse-trace to beads"); 
  }
};
