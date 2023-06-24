//  utils.pde

class displayMessage {
  String msg;
  float fontSize=28f;
  float newlineSize= fontSize*1.5f;
  int start_column=0;
  void initialize() {
    fontSize=28f;
    newlineSize= fontSize*1.5f;
    start_column=0;
  }
  void showColumn(String newMsg, int column) {
    this.msg=newMsg;
    textSize(fontSize);
    fill(0, 80, 0);
    text(this.msg, 10, fontSize+2f+newlineSize*column);
  }
  void show(String newMsg) {
    showColumn(newMsg,0);
  }
  void showBelow(String newMsg) {
    this.msg=newMsg;
    textSize(fontSize);
    fill(0, 80, 0);
    text(this.msg, 10, width-10);
  }
  void showMenu(){
    showBelow("Menu mode:");
    int column=0;
    showColumn("e : input by editor", column++);
    showColumn("n : input by free loop", column++);
    showColumn("o : open file (png, jpg, gif, txt)", column++);
    showColumn("s : save file (png, txt, lnk)", column++);
    showColumn("r/R : rotate the figure", column++);
    showColumn("w : change w/beads and off-beads mode", column++);
    showColumn("click crossing : crossing change", column++);
  }    
};