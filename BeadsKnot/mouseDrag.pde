class mouseDrag { //<>// //<>// //<>// //<>// //<>//
  ArrayList<PVector> trace;
  PVector prev;

  boolean free_dragging=false;
  boolean node_dragging=false;
  boolean node_next_dragging =false;
  boolean new_curve=false;
  int dragged_nodeID = -1;
  int dragged_BeadID = -1;
  float dragged_theta = 0f;
  float nd_theta = 0f;
  float nd_theta_branch = 0f;
  float DragX = 0f;
  float DragY = 0f;
  float PressX = 0;
  float PressY = 0;

  mouseDrag() {
    trace = new ArrayList<PVector>();
  }

  void draw_trace() {
    if (trace.size()>1) {
      PVector p0 = trace.get(0);
      for (int t=1; t<trace.size(); t++) {
        stroke(128);
        noFill();
        PVector p1 = trace.get(t);
        line(p0.x, p0.y, p1.x, p1.y);
        p0 = p1;
      }
      if (free_dragging && trace.size()>3) {
        p0 = trace.get(0);
        if (dist(p0.x, p0.y, mouseX, mouseY)<30) {
          stroke(128);
          fill(255, 0, 0, 40);
          ellipse(p0.x, p0.y, 60, 60);
        }
      }
    }
  }

  void trace_to_beads(data_extract data, data_graph graph) {
    ArrayList<PVector> meets = new ArrayList<PVector>();
    data.clearAllPoints();
    int traceNumber = trace.size();
    // まず1列のbeadの列を作る。
    for (int tr = 0; tr < traceNumber; tr++) {
      int bdID = data.addBeadToPoint(trace.get(tr).x, trace.get(tr).y);
      Bead bd = data.getBead(bdID);
      bd.n1 = (tr+1)%traceNumber;
      bd.n2 = (tr+traceNumber-1)%traceNumber;
      bd.c = 2;
      //data.points.add(bd);
    }
    for (int tr1 = 0; tr1 < traceNumber; tr1++) {
      for (int tr2 = tr1+1; tr2 < traceNumber; tr2++) {
        int difference = (tr2-tr1+2*traceNumber)%traceNumber;
        if (2 < difference && difference < traceNumber -2) {
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
          if ( st < 0 ) {
            st *= -1;
            s1 *= -1;
            t1 *= -1;
          }
          if (0 < s1 && s1 < st && 0 < t1 && t1 < st) {
            //trace.get(tr1+1) と trace.get(tr2+1)とを合流してJointにする。
            int jt = (tr1+1)%traceNumber;
            int jt2 = (tr2+1)%traceNumber;
            boolean OK=true;
            for (int mt=0; mt<meets.size(); mt++) {
              int js=int(meets.get(mt).x);
              int js2 = int(meets.get(mt).y);
              if (abs(jt-js)<=2 && abs(jt2-js2)<=2) {
                println(jt, js, jt2, js2);
                OK = false;
                break;
              }
            }
            if (OK) {
              println(jt, "meets", jt2);
              meets.add(new PVector(jt, jt2));
              Bead jtBead = data.points.get(jt);
              Bead jt2Bead = data.points.get(jt2);
              jtBead.Joint = true;
              jtBead.u1 = jt2Bead.n1;
              jtBead.u2 = jt2Bead.n2;
              data.removeBeadFromPoint(jt2);
              data.getBead(tr2).n1 = jt;
              data.getBead((tr2+2)%traceNumber).n2 = jt;
            }
          }
        }
      }
    }
    graph.make_data_graph();
    println("complete mouse-trace to beads");
  }

  void trace_to_parts_editing(data_extract data, data_graph graph, parts_editing edit, int endBeadID) {
    //そもそも、traceがJointの近くを通っていたら、作業しない。
    if (trace.size()<6) {
      println("traceの長さが短すぎる");
    }
    for (int i=1; i<edit.beads.size(); i++) {
      Bead bd = edit.beads.get(i);
      if (bd.Joint) {
        for (int j=3; j<trace.size()-3; j++) {
          PVector tr = trace.get(j);
          float d = dist(tr.x, tr.y, bd.x, bd.y);
          if (d<45) {// ビーズ３つ分の間隔
            println("traceの位置が不正");
            return;
          }
        }
      }
    }
    // まず、traceをすべてbeadに置き換える。（両端は除く）
    println("traceをbeadsに変換");
    int startBeadID = dragged_BeadID;
    int traceStartBeadID = 0;
    Bead startBead = edit.beads.get(startBeadID);
    if (startBead.c==1) {//スタートビーズのデータを整える
      startBead.n2 = edit.beads.size();
      startBead.c = 2;
    } else if (startBead.c==0) {// 想定として、 c は0か1
      startBead.n1 = edit.beads.size();
      startBead.c = 1;
    } else {
      //それ以外なら、即刻辞める
      println("startBeadの異常");
      return ;
    }
    Bead endBead = edit.beads.get(endBeadID);
    if (endBead.c!=1 && endBead.c!=0) {//エンドビーズについてもおかしなところがあれば即刻辞める
      return ;
    }
    traceStartBeadID = edit.beads.size();// 追加されるべき最初のbeadの番号
    for (int trID=1; trID<trace.size()-1; trID++) {//traceをひとつひとつbeadに置き換える
      PVector tr = trace.get(trID);
      Bead newBd = new Bead(tr.x, tr.y);

      int prevBeadID = edit.beads.size()-1;
      if (trID==1) {
        prevBeadID = startBeadID;
      }
      int nextBeadID = edit.beads.size()+1;
      if (trID == trace.size()-2) {
        nextBeadID = endBeadID;
      }
      newBd.n1 = prevBeadID;
      newBd.n2 = nextBeadID;
      newBd.c = 2;
      //println(prevBeadID, nextBeadID);
      edit.beads.add(newBd);
    }
    if (endBead.c==1) {
      endBead.n2 = edit.beads.size()-1;
      endBead.c = 2;
    } else if (endBead.c==0) {
      endBead.n1 = edit.beads.size()-1;
      endBead.c = 1;
    }
    //そののちに、既存のビーズ列、自分自身との交差を判定し、jointを追加する。
    ArrayList<PVector> meets = new ArrayList<PVector>();
    int beadsNumber = edit.beads.size();
    for (int bdID1 = traceStartBeadID; bdID1<beadsNumber; bdID1++) {
      Bead bd1 = edit.beads.get(bdID1);
      if (bd1.c>=2) {
        for (int bdID2=0; bdID2<beadsNumber; bdID2++) {
          Bead bd2 = edit.beads.get(bdID2);
          if (bdID2<bdID1 && bd2.c>=2) {
            int bd1n1 = bd1.n1;
            int bd1n2 = bd1.n2;
            int bd2n1 = bd2.n1;
            int bd2n2 = bd2.n2;
            if (bd1n1!=-1 && bd1n2!=-1 && bd2n1!=-1 && bd2n2!=-1
              && bd1n1!=bd2n1 && bd1n1!=bdID2 && bd1n1!=bd2n2
              && bdID1!=bd2n1 && bdID1!=bdID2 && bdID1!=bd2n2
              && bd1n2!=bd2n1 && bd1n2!=bdID2 && bd1n2!=bd2n2) {
              float x1 = edit.beads.get(bd1n1).x;
              float y1 = edit.beads.get(bd1n1).y;
              float x2 = edit.beads.get(bd1n2).x;
              float y2 = edit.beads.get(bd1n2).y;
              float x3 = edit.beads.get(bd2n1).x;
              float y3 = edit.beads.get(bd2n1).y;
              float x4 = edit.beads.get(bd2n2).x;
              float y4 = edit.beads.get(bd2n2).y;
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
              if ( st < 0 ) {
                st *= -1;
                s1 *= -1;
                t1 *= -1;
              }
              if (0 < s1 && s1 < st && 0 < t1 && t1 < st) {
                //trace.get(tr1+1) と trace.get(tr2+1)とを合流してJointにする。
                // 合流する点がJointに極めて近いときは失敗扱いにしたいが、
                //そもそもtraceがJointの近くを通らないことを保証しているので、信じることにする。
                //Jointの二重登録を避けるための作業。
                boolean localOK = true;
                for (int mt=0; mt<meets.size(); mt++) {
                  int js1 = int(meets.get(mt).x);
                  int js2 = int(meets.get(mt).y);
                  if (js1== bd1n1 || js1== bdID1 || js1== bd1n2 
                    || js1== bd2n1 || js1== bdID2 || js1== bd2n2
                    || js2== bd1n1 || js2== bdID1 || js2== bd1n2
                    || js2== bd2n1 || js2== bdID2 || js2== bd2n2) {
                    println(bdID1, bdID2, js1, js2);
                    localOK = false;
                    break;
                  }
                }
                if (localOK) {
                  println(bdID1, "meets", bdID2);
                  meets.add(new PVector(bdID1, bdID2));
                  bd1 = edit.beads.get(bdID1);
                  bd2 = edit.beads.get(bdID2);
                  bd2.Joint = true;
                  bd2.u1 = bd1n1;
                  bd2.u2 = bd1n2;
                  bd2.c = 4;
                  bd1.n1 = -1;
                  bd1.n2 = -1;
                  bd1.x = bd1.y = -1f;
                  bd1.c = -1;
                  Bead bd11 = edit.beads.get(bd1n1);
                  if (bd11.n1 == bdID1) bd11.n1 = bdID2;
                  else if (bd11.n2 == bdID1) bd11.n2 = bdID2;
                  Bead bd12 = edit.beads.get(bd1n2);
                  if (bd12.n1 == bdID1) bd12.n1 = bdID2;
                  else if (bd12.n2 == bdID1) bd12.n2 = bdID2;
                }
                //  }
                //}
                //終了条件の確認
              }
            }
          }
        }
      }
    }
    boolean OK=true;//図が完了しているかどうかのフラグ。
    for (int bdID=0; bdID<edit.beads.size(); bdID++) { //<>// //<>//
      Bead bd = edit.beads.get(bdID);
      if (bd.n1!=-1 || bd.n2!=-1 || bd.u1!=-1 || bd.u2!=-1) { 
        if (bd.c!=2 && bd.c!=4) {
          OK=false;
          return;
        }
      }
    }
    if (OK) {
      println("complete figure");
      data.clearAllPoints();
      for (int bdID=0; bdID<edit.beads.size(); bdID++) {
        Bead bd = edit.beads.get(bdID);
        int newBdID = data.addBeadToPoint(bd.x, bd.y);
        Bead newBd = data.getBead(newBdID);
        newBd.n1 = bd.n1;
        newBd.n2 = bd.n2;
        newBd.u1 = bd.u1;
        newBd.u2 = bd.u2;
        if (bd.c==4) {
          newBd.c = 2;
          newBd.Joint = true;
        } else if (bd.c==2) {
          newBd.c = 2;
          newBd.Joint = false;
        }
      }
      graph.make_data_graph();
      Draw.beads();
    }// OK=falseならば、図が未完成なので、さらなるトレースを待つ。
  }


  void trace_to_parts_editing2(data_extract data, int dragged_BeadID, int endBeadID) {
    // まず、traceをすべてbeadに置き換える。（両端は除く）
    //println("traceをbeadsに変換");
    int startID = dragged_BeadID;
    int traceStartBeadID = 0;
    Bead startBead = data.getBead(startID);
    if(startBead == null){
      println("trace_to_parts_editing2:error:dragged_BeadIDの値が不正");
      return ;
    }
    if (startBead.c==1) {//スタートビーズのデータを整える
      startBead.n2 = data.points.size();
      startBead.c = 2;
      //} else if (startBead.c==0) {// 想定として、 c は0か1
      //  startBead.n1 = data.points.size();
      //  startBead.c = 1;
    } else {
      //それ以外なら、即刻辞める
      println("startBeadの異常");
      return ;
    }
    Bead endBead = data.getBead(endBeadID);
    if (endBead.c!=1 && endBead.c!=0) {//エンドビーズについてもおかしなところがあれば即刻辞める
      return ;
    }
    traceStartBeadID = data.points.size();// 追加されるべき最初のbeadの番号
    for (int trID=1; trID<trace.size()-1; trID++) {//traceをひとつひとつbeadに置き換える
      PVector tr = trace.get(trID);
      Bead newBd = new Bead(disp.getX_fromWin(tr.x), disp.getY_fromWin(tr.y));

      int prevBeadID =data.points.size()-1;
      if (trID==1) {
        prevBeadID = startID;
      }
      int nextBeadID =data.points.size()+1;
      if (trID == trace.size()-2) {
        nextBeadID = endBeadID;
      }
      newBd.n1 = prevBeadID;
      newBd.n2 = nextBeadID;
      newBd.c = 2;
      data.points.add(newBd);
    }
    if (endBead.c==1) {
      endBead.n2 = data.points.size()-1;
      endBead.c = 2;
      //} else if (endBead.c==0) {
      //  endBead.n1 = data.points.size()-1;
      //  endBead.c = 1;
    }



    //そののちに、既存のビーズ列、自分自身との交差を判定し、jointを追加する。
    ArrayList<PVector> meets = new ArrayList<PVector>();
    int beadsNumber = data.points.size();
    for (int bdID1 = traceStartBeadID; bdID1<beadsNumber; bdID1++) {
      Bead bd1 = data.getBead(bdID1);
      if (bd1.c>=2) {
        for (int bdID2=0; bdID2<beadsNumber; bdID2++) {
          Bead bd2 = data.getBead(bdID2);
          if (bd2 != null && bdID2<bdID1 && bd2.c>=2) {
            int bd1n1 = bd1.n1;
            int bd1n2 = bd1.n2;
            int bd2n1 = bd2.n1;
            int bd2n2 = bd2.n2;
            if (bd1n1!=-1 && bd1n2!=-1 && bd2n1!=-1 && bd2n2!=-1
              && bd1n1!=bd2n1 && bd1n1!=bdID2 && bd1n1!=bd2n2
              && bdID1!=bd2n1 && bdID1!=bdID2 && bdID1!=bd2n2
              && bd1n2!=bd2n1 && bd1n2!=bdID2 && bd1n2!=bd2n2) {
              float x1 = data.getBead(bd1n1).x;
              float y1 = data.getBead(bd1n1).y;
              float x2 = data.getBead(bd1n2).x;
              float y2 = data.getBead(bd1n2).y;
              float x3 = data.getBead(bd2n1).x;
              float y3 = data.getBead(bd2n1).y;
              float x4 = data.getBead(bd2n2).x;
              float y4 = data.getBead(bd2n2).y;
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
              if ( st < 0 ) {
                st *= -1;
                s1 *= -1;
                t1 *= -1;
              }
              if (0 < s1 && s1 < st && 0 < t1 && t1 < st) {
                //trace.get(tr1+1) と trace.get(tr2+1)とを合流してJointにする。
                // 合流する点がJointに極めて近いときは失敗扱いにしたいが、
                //そもそもtraceがJointの近くを通らないことを保証しているので、信じることにする。
                //Jointの二重登録を避けるための作業。
                boolean localOK = true;
                for (int mt=0; mt<meets.size(); mt++) {
                  int js1 = int(meets.get(mt).x);
                  int js2 = int(meets.get(mt).y);
                  if (js1== bd1n1 || js1== bdID1 || js1== bd1n2 
                    || js1== bd2n1 || js1== bdID2 || js1== bd2n2
                    || js2== bd1n1 || js2== bdID1 || js2== bd1n2
                    || js2== bd2n1 || js2== bdID2 || js2== bd2n2) {
                    println(bdID1, bdID2, js1, js2);
                    localOK = false;
                    break;
                  }
                }
                if (localOK) {
                  println(bdID1, "meets", bdID2);
                  meets.add(new PVector(bdID1, bdID2));
                  bd1 = data.getBead(bdID1);
                  bd2 = data.getBead(bdID2);
                  ///////Jointかunderかoverかで変わる
                  ///overならbd1を採用し、underならbd2を採用する
                  if (data.over_crossing) {
                    bd1.c=2;
                    bd1.Joint = true;
                    bd1.u1 = bd2n1;
                    bd1.u2 = bd2n2;
                    // bd1.c = 4;
                    data.removeBeadFromPoint(bdID2);
                    //bd2.n1 = -1;
                    //bd2.n2 = -1;
                    //bd2.x = bd2.y = -1f;
                    //bd2.c = -1;

                    Bead bd11 = data.getBead(bd2n1);
                    if (bd11.n1 == bdID2) {
                      bd11.n1 = bdID1;
                    } else if (bd11.n2 == bdID2) {
                      bd11.n2 = bdID1;
                    }
                    Bead bd12 = data.getBead(bd2n2);
                    if (bd12.n1 == bdID2) {
                      bd12.n1 = bdID1;
                    } else if (bd12.n2 == bdID2) {
                      bd12.n2 = bdID1;
                    }
                  } else {
                    bd2.c=2;
                    bd2.Joint = true;
                    bd2.u1 = bd1n1;
                    bd2.u2 = bd1n2;
                    //bd2.c = 4;
                    data.removeBeadFromPoint(bdID1);
                    //bd1.n1 = -1;
                    //bd1.n2 = -1;
                    //bd1.x = bd1.y = -1f;
                    //bd1.c = -1;

                    Bead bd11 = data.getBead(bd1n1);
                    if (bd11.n1 == bdID1) {
                      bd11.n1 = bdID2;
                    } else if (bd11.n2 == bdID1) {
                      bd11.n2 = bdID2;
                    }
                    Bead bd12 = data.getBead(bd1n2);
                    if (bd12.n1 == bdID1) {
                      bd12.n1 = bdID2;
                    } else if (bd12.n2 == bdID1) {
                      bd12.n2 = bdID2;
                    }
                  }
                }
                //  }
                //}
                //終了条件の確認
              }
            }
          }
        }
      }
    }
    boolean OK=true;//図が完了しているかどうかのフラグ。
    for (int bdID=0; bdID<data.points.size(); bdID++) {
      Bead bd = data.getBead(bdID);
      if(bd!=null){
        if (bd.n1!=-1 || bd.n2!=-1 || bd.u1!=-1 || bd.u2!=-1) { 
          if (bd.c!=2 && bd.c!=4) {
            OK=false;
            return;
          }
        }
      }
    }
    if (OK) {
      println("complete figure");
      //data.points.clear();
      //for (int bdID=0; bdID<edit.beads.size(); bdID++) {
      //  Bead bd = edit.beads.get(bdID);
      //  if (bd.c==4) {
      //    bd.c=2;
      //    bd.Joint = true;
      //  } else if (bd.c==2) {
      //    bd.Joint = false;
      //  }
      //  data.points.add(bd);
      //}
      
      graph.make_data_graph();
      Draw.beads();
    }// OK=falseならば、図が未完成なので、さらなるトレースを待つ。
  }
};