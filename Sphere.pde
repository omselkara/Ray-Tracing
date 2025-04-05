class Sphere extends Shape{
  
  Sphere(Vector center,Material mat,float radius){
    type = 2;
    this.center = center;
    this.radius = radius;
    this.material = mat;
    maxPos = Vector.add(center,new Vector(radius));
    minPos = Vector.substract(center,new Vector(radius));
  }
  
  Vector getNormal(Vector pos){
    return Vector.normalize(Vector.substract(pos,this.center));
  }
  
  boolean isInside(Vector pos){
    return Vector.distance(pos,this.center)<=this.radius;
  }
}
