import java.util.List;

class Triangle extends Shape{
  
  Triangle(Vector vec1,Vector vec2,Vector vec3){
    type = 1;
    this.lines = new Vector[] {vec1,vec2,vec3};
    calculateCenter();
    calculateNormal();
    minPos = new Vector(
    min(vec1.x,vec2.x,vec3.x),
    min(vec1.y,vec2.y,vec3.y),
    min(vec1.z,vec2.z,vec3.z));
    
    maxPos = new Vector(
    max(vec1.x,vec2.x,vec3.x),
    max(vec1.y,vec2.y,vec3.y),
    max(vec1.z,vec2.z,vec3.z));
  }
  
  void calculateCenter(){
    center = Vector.divide(Vector.add(Vector.add(lines[0],lines[1]),lines[2]),3f);
  }
  
  
  void calculateNormal(){
    this.normal = Vector.normalize(Vector.cross(Vector.substract(lines[1],lines[0]),Vector.substract(lines[2],lines[1])));
  }
  
  boolean isInside(Vector pos){
    return true;
  }
}
