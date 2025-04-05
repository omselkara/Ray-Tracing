class Line{
  Vector pos;
  Vector dir;
  Vector center;
  float length;
  Line(Vector pos,Vector dir,float length){
    this.pos = pos;
    this.dir = Vector.normalize(dir);
    this.length = length;
    center = Vector.add(pos,Vector.multiply(this.dir,length/2.0f));
  }
  Line(Vector pos1,Vector pos2){
    this.pos = pos1;
    this.dir = Vector.substract(pos2,pos1);
    this.length = this.dir.length();
    this.dir = Vector.normalize(this.dir);
    center = Vector.divide(Vector.add(pos1,pos2),2f);
  }
  
  void reverse(){
    this.pos = getEndPoint();
    this.dir = Vector.negate(this.dir);
  }
  
  Vector getEndPoint(){
    return Vector.add(this.pos,Vector.multiply(this.dir,this.length));
  }
}
