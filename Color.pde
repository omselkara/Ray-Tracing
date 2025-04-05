class Color{
  float r,g,b;
  Color(float w){
    r = w;
    g = w;
    b = w;
  }
  Color(float r,float g,float b){
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  void Update(){
    r = max(0f,min(1f,r));
    g = max(0f,min(1f,g));
    b = max(0f,min(1f,b));
  }
  
  int Red(){
    return (int)(max(0,min(1,r))*255f);
  }
  int Green(){
    return (int)(max(0,min(1,g))*255f);
  }
  int Blue(){
    return (int)(max(0,min(1,b))*255f);
  }
  
  Color Dot(Color col){
    return new Color(r*col.r,g*col.g,b*col.b);
  }
  Color Dot(float w){
    return new Color(r*w,g*w,b*w);
  }
  Color Add(Color col){
    return new Color(r+col.r,g+col.g,b+col.b);
  }
  void SetTo(Color col){
    r = col.r;
    g = col.g;
    b = col.b;
  }
  boolean isZero(){
    return Red()==0 && Green()==0 && Blue()==0;
  }
  
  color getColor(){
    return color(Red(),Green(),Blue());
  }
}
Color rgb(float r,float g,float b){
  return new Color(r/255f,g/255f,b/255f);
}
Color rgb(float w){
  return new Color(w/255f,w/255f,w/255f);
}
