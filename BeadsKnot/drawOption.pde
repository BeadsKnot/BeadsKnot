class drawOption {
  boolean _original_image;
  boolean _binarized_image;
  boolean _thinning_image;
  boolean _beads;  
  boolean _data_graph;
  boolean _free_loop;

  drawOption() {
    beads();
  }

  void setAllOptionFalse() {
    _original_image=false;
    _binarized_image=false;
    _thinning_image = false;
    _beads=false;
    _data_graph = false;
    _free_loop = false;
  }

  void original_image(){
    setAllOptionFalse();
    _original_image = true;
  }
 
  void binarized_image(){
    setAllOptionFalse();
    _binarized_image = true;
  }
  
  void thinning_image(){
    setAllOptionFalse();
    _thinning_image = true;
  }
  
  void beads(){
    setAllOptionFalse();
    _beads = true;
  }
  
  void data_graph(){
    setAllOptionFalse();
    _data_graph = true;
  }
  
  void free_loop(){
    setAllOptionFalse();
    _free_loop = true;
  }
    
};
