class displayWorld {
  float left, top, right, bottom;
  float win_width, win_height, win_offset;
  float rate;
  float Left,Right,Top,Bottom;
  
  displayWorld(float _w, float _h) {
    win_width = _w;
    win_height = _h;
    win_offset = 50;
    left=Left=win_offset;
    top=Top=win_offset;
    right=Right=win_width-win_offset;
    bottom=Bottom=win_height-win_offset;
    rate=1;
  }

  //TODO センタリングしたものを考えておく。
  float get_winX(float x) {
    return (x-left)*rate+win_offset;
  }

  float get_winY(float y) {
    return (y-top)*rate+win_offset;
  }

  float getX_fromWin(float winX) {
    return (winX-win_offset)/rate + left;
  }

  float getY_fromWin(float winY) {
    return (winY-win_offset)/rate + top;
  }

  void set_rate() {
    if (right-left>bottom-top) {
      rate = (win_width-2*win_offset)/(right-left);
    } else {
      rate = (win_width-2*win_offset)/(bottom-top);
    }
  }
  
  void modify(){
    if(Left>left+1){
      left ++;
    }else if(Left<left-1){
      left --;
    }
    if(Right>right+1){
      right++;
    } else if (Right<right-1){
      right--;
    }
    if(Top>top+1){
      top++;
    } else if (Top<top-1){
      top--;
    }
    if(Bottom>bottom+1){
      bottom++;
    } else if(Bottom<bottom-1){
      bottom--;
    }
    set_rate();
  }
}