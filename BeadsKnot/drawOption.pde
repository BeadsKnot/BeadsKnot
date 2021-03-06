class drawOption {
  boolean _menu;
  boolean _original_image;
  boolean _binarized_image;
  boolean _thinning_image;
  boolean _beads;  
  boolean _line_without_beads;  
  boolean _data_graph;
  boolean _free_loop;
  boolean _parts_editing;
  boolean _posinega;
  boolean _smoothing;
  boolean _beads_with_Seifelt;

  boolean _show_points_nb;
  boolean _show_node_nb;
  boolean _show_orientation_nb;
  boolean _mirror;
  boolean _band_film;


  drawOption() {
    menu();
  }

  void setAllOptionFalse() {
    _menu = false;
    _original_image=false;
    _binarized_image=false;
    _thinning_image = false;
    _beads=false;
    _line_without_beads=false;
    _data_graph = false;
    _free_loop = false;
    _parts_editing = false;
    _posinega=false;
    _smoothing=false;
    _beads_with_Seifelt=false;

    _show_points_nb = false;
    _show_node_nb = false;
    _show_orientation_nb = false;
    
    _mirror=false;
    
    _band_film=false;
  }

  void menu() {
    setAllOptionFalse();
    _menu = true;
  }

  void original_image() {
    setAllOptionFalse();
    _original_image = true;
  }

  void binarized_image() {
    setAllOptionFalse();
    _binarized_image = true;
  }

  void thinning_image() {
    setAllOptionFalse();
    _thinning_image = true;
  }

  void beads() {
    setAllOptionFalse();
    _beads = true;
  }

  void line_without_beads() {
    setAllOptionFalse();
    _line_without_beads = true;
  }

  void data_graph() {
    setAllOptionFalse();
    _data_graph = true;
  }

  void free_loop() {
    setAllOptionFalse();
    _free_loop = true;
  }

  void parts_editing() {
    setAllOptionFalse();
    _parts_editing = true;
  }

  void posinega() {
    setAllOptionFalse();
    _posinega=true;
  }

  void smoothing() {
    setAllOptionFalse();
    _smoothing=true;
  }

  void beads_with_Seifelt() {
    setAllOptionFalse();
    _beads_with_Seifelt=true;
  }
  
  void mirror(){
    setAllOptionFalse();
    _mirror=true;
  }
  
  void band_film(){
   setAllOptionFalse();
   _band_film=true;
  }
};