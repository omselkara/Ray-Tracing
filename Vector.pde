public static class Vector{
  float x,y,z;
  Vector(float x,float y,float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  Vector(float x,float y){
    this.x = x;
    this.y = y;
    this.z = 0;
  }
  
  Vector(float x){
    this.x = x;
    this.y = x;
    this.z = x;
  }
  
  public String toString(){
    return String.format("[%f ,%f ,%f]",x,y,z);
  }
  
  float length(){
    return sqrt(x*x+y*y+z*z);
  }
  
  public static Vector normalize(Vector vec){
    float magnitude = vec.length();
    return new Vector(vec.x/magnitude,vec.y/magnitude,vec.z/magnitude);
  }
  
  public static float distance(Vector vec1,Vector vec2){
    return sqrt((vec1.x-vec2.x)*(vec1.x-vec2.x)+(vec1.y-vec2.y)*(vec1.y-vec2.y)+(vec1.z-vec2.z)*(vec1.z-vec2.z));
  }
  
  public static Vector add(Vector vec1,Vector vec2){
    return new Vector(vec1.x+vec2.x,vec1.y+vec2.y,vec1.z+vec2.z);
  }
  
  public static Vector substract(Vector vec1,Vector vec2){
    return new Vector(vec1.x-vec2.x,vec1.y-vec2.y,vec1.z-vec2.z);
  }
  
  public static Vector multiply(Vector vec1,Vector vec2){
    return new Vector(vec1.x*vec2.x,vec1.y*vec2.y,vec1.z*vec2.z);
  }
  
  public static Vector multiply(Vector vec,float constant){
    return new Vector(vec.x*constant,vec.y*constant,vec.z*constant);
  }
  
  public static Vector divide(Vector vec1,Vector vec2){
    return new Vector(vec1.x/vec2.x,vec1.y/vec2.y,vec1.z/vec2.z);
  }
  
  public static Vector divide(Vector vec,float constant){
    return new Vector(vec.x/constant,vec.y/constant,vec.z/constant);
  }
  
  public static float dot(Vector vec1,Vector vec2){
    return vec1.x*vec2.x+vec1.y*vec2.y+vec1.z*vec2.z;
  }
  
  public static Vector cross(Vector vec1,Vector vec2){
    return new Vector(vec1.y*vec2.z-vec1.z*vec2.y,vec1.z*vec2.x-vec1.x*vec2.z,vec1.x*vec2.y-vec1.y*vec2.x);
  }
  
  public static Vector negate(Vector vec){
    return multiply(vec,-1f);
  }
  public static boolean equals(Vector vec1,Vector vec2){
    return vec1.x==vec2.x && vec1.y==vec2.y && vec1.z==vec2.z;
  }
  
  public static Vector rotateX(Vector vec,float angle){
    return new Vector(vec.x,vec.y*cos(angle)+vec.z*sin(angle),vec.z*cos(angle)-vec.y*sin(angle));
  }
  public static Vector rotateX(Vector vec,Vector origin,float angle){
    return Vector.add(rotateX(Vector.substract(vec,origin),angle),origin);
  }
  public static Vector rotateY(Vector vec,float angle){
    return new Vector(vec.x*cos(angle)-vec.z*sin(angle),vec.y,vec.z*cos(angle)+vec.x*sin(angle));
  }
  public static Vector rotateY(Vector vec,Vector origin,float angle){
    return Vector.add(rotateY(Vector.substract(vec,origin),angle),origin);
  }
  public static Vector rotateZ(Vector vec,float angle){
    return new Vector(vec.x*cos(angle)-vec.y*sin(angle),vec.y*cos(angle)+vec.x*sin(angle),vec.z);
  }
  public static Vector rotateZ(Vector vec,Vector origin,float angle){
    return Vector.add(rotateY(Vector.substract(vec,origin),angle),origin);
  }
  
  public static Vector rotate(Vector vec, Vector origin, float angleX,float angleY,float angleZ){
    vec = rotateX(vec,origin,angleX);
    vec = rotateY(vec,origin,angleY);
    vec = rotateZ(vec,origin,angleZ);
    return vec;
  }
  
  public static Vector rotate(Vector vec, float angleX,float angleY,float angleZ){
    vec = rotateX(vec,angleX);
    vec = rotateY(vec,angleY);
    vec = rotateZ(vec,angleZ);
    return vec;
  }
}
