void keyPressed() {
  if ( key=='a' || int(key)==1) { // a
  } else if ( key=='b' || int(key)==2) { // b 
    dispM.show("w/o band mode");
    Draw.band_film();
  } else if ( key=='c' || int(key)==3) { // c
  } else if ( key=='d' || int(key)==4) { // d 
    // console out Dowker code
    dispM.show("show Dowker code.");
    orie.decide_orientation(); // 
    orie.dowker_notation();  //
  } else if ( key=='e' || int(key)==5) { // e 
    // parts editing mode begins
    Draw.partsEditing();
    mouse.trace.clear();
    edit.beads.clear();
  } else if ( key=='f' || int(key)==6) { // f
  } else if ( key=='g' || int(key)==7) { // g
  } else if ( key=='h' || int(key)==8) { // h
  } else if ( key=='i' || int(key)==9) { // i
  } else if ( key=='j' || int(key)==10) { // j
  } else if ( key=='k' || int(key)==11) { // k
  } else if ( key=='l' || int(key)==12) { // l
  } else if ( key=='m' || int(key)==13) { 
    // modify shape mode/
    //if (Draw._dataGraph) {
    //  graph.modify();
    //} else {
    //  Draw._menu = true;
    //}
  } else if (key=='M') {
    println("obtain the mirror image of the knot");
    Draw.mirror();
    graph.displayMirror();
  } else if ( key=='n' || int(key)==14) {//
    // draw_free_loop mode begins
    Draw.free_loop();// change mode
    mouse.trace.clear();// clear beads data
  } else if ( key=='o' || int(key)==15) {// o // ctrl+o//
    // open file
    selectInput("Select a file to process:", "fileSelected");
    if (seif.reg.size()>=0) {
      // if seifert surface is here, delete it.
      for (int i=0; i<seif.reg.size(); i++) {
        seif.reg.get(i).border.clear();
      }
      seif.reg.clear();
    }
  } else if ( key=='p' || int(key)==16) {
    // show/hide beads id 
    Draw._show_points_nb = !Draw._show_points_nb;
  } else if ( key=='P') {
    // show/hide orientation id
    orie.decide_orientation();
    Draw._show_orientation_nb = !Draw._show_orientation_nb;
  } else if ( key=='q' || int(key)==17) {// ctrl+s//
    // show/hide node id
    Draw._show_node_nb = !Draw._show_node_nb;
  } else if ( key=='r' || int(key)==18) {// ctrl+s//
    // rotate whole clockwise 
    if (Draw._beads) {
      data.rotatePoints(PI/12);
      graph.rotateNodes(PI/12);
      graph.get_disp() ;
    }
  } else if (key == 'R') {
    // rotate whole unti-clockwise
    if (Draw._beads) {
      data.rotatePoints(-PI/12);
      graph.rotateNodes(-PI/12);
      graph.get_disp() ;
    }
  } else if ( key=='s' || int(key)==19) {// ctrl+s//
    // save file
    selectInput("Select a file to save", "saveFileSelect");
  } else if (key=='S') {
    // draw knot and Seifert surface
    orie.decide_orientation();
    Draw.beads_with_Seifelt();
    seif.SeifertAlgorithm();
  } else if ( key=='t' || int(key)==20) {// ctrl+s//
  } else if ( key=='u' || int(key)==21) {// ctrl+s//
  } else if ( key=='v' || int(key)==22) {// ctrl+v//
    // paste?
  } else if ( key=='w' || int(key)==23) {//
    // change w/beads and off-beads mode
    if (Draw._beads) {
      Draw.line_without_beads();
    } else if (Draw._line_without_beads) {
      Draw.beads();
    }
  } else if ( key=='x' || int(key)==24) {// ctrl+x//
    // cut?
  } else if ( key=='y' || int(key)==25) {// ctrl+y//
  } else if ( key=='z' || int(key)==26) {// ctrl+z//
    // undo?
  } else if (keyCode==ENTER) {/////////////////////////////////交点を割いた絵を描画する
    orie.decide_orientation();
    Draw.smoothing();
  } else if (keyCode==SHIFT) {/////////////////////////交点を割いた絵の描画を解除する
    Draw._beads=true;
    orie.decide_orientation();
    if (seif.reg.size()>0) {
      for (int i=0; i<seif.reg.size(); i++) {
        seif.reg.get(i).border.clear();
      }
      seif.reg.clear();
    }
    //} else if (key=='z') {/////////////////////////////////現在使われていない
    //  dowker dk = new dowker(graph); 
    //  dk.Start();
  }
}