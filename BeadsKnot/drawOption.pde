class drawOption {
  boolean drawOriginalImage;
  boolean drawThinningImage;
  boolean drawBeadsAndNhds;
  
  boolean data_graph_all_complete;

  drawOption() {
    changeDrawOption(3);
  }

  void setAllOptionFalse() {
    drawOriginalImage=false;
    drawThinningImage=false;
    drawBeadsAndNhds=false;
  }

  void changeDrawOption(int i) {
    setAllOptionFalse();
    switch(i) {
    case 1:
      drawOriginalImage=true;
      break;
    case 2:
      drawThinningImage=true;
      break;
    case 3:
      drawBeadsAndNhds=true;
      break;
    }
  }
};