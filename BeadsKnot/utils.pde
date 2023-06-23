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
  void show(String newMsg) {
    this.msg=newMsg;
    textSize(fontSize);
    fill(0, 80, 0);
    text(this.msg, 10, fontSize+2f+newlineSize*start_column);
  }
};