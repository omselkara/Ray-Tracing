float ro = 1;
float povDst = 1.0;
float horizontalPov = 4;
float verticalPov = 4;
float speed = 10f;
float pov = 1;
float deltatime = 1;

class Camera{
  private Vector pos;
  private float angleX,angleY;
  private Vector dir,povCenter,horizontalDirScreen,verticalDirScreen;
  Line[][] Rays;
  Camera(){
    pos = new Vector(0,0,0);
    angleX = 0;
    angleY = PI/2f;
    dir = new Vector(0,0,0);
    povCenter = new Vector(0,0,0);
    horizontalDirScreen = new Vector(0,0,0);
    verticalDirScreen = new Vector(0,0,0);
    update();
  }
  Camera(Vector pos){
    this.pos = pos;
    angleX = 0;
    angleY = PI/2f;
    dir = new Vector(0,0,0);
    povCenter = new Vector(0,0,0);
    horizontalDirScreen = new Vector(0,0,0);
    verticalDirScreen = new Vector(0,0,0);
    update();
  }
  Camera(Vector pos,float angleX){
    this.pos = pos;
    this.angleX = angleX;
    angleY = PI/2f;
    dir = new Vector(0,0,0);
    povCenter = new Vector(0,0,0);
    horizontalDirScreen = new Vector(0,0,0);
    verticalDirScreen = new Vector(0,0,0);
    update();
  }
  Camera(Vector pos,float angleX,float angleY){
    this.pos = pos;
    this.angleX = angleX;
    this.angleY = angleY;
    dir = new Vector(0,0,0);
    povCenter = new Vector(0,0,0);
    horizontalDirScreen = new Vector(0,0,0);
    verticalDirScreen = new Vector(0,0,0);
    update();
  }
  Ray getRay(float x,float y){
    x = x-0.5f;
    y = y-0.5f;
    Vector endPoint = Vector.add(povCenter,Vector.add(Vector.multiply(horizontalDirScreen,x*horizontalPov),Vector.multiply(verticalDirScreen,y*verticalPov)));
    return new Ray(endPoint,Vector.normalize(Vector.substract(endPoint,Vector.add(pos,Vector.multiply(dir,-pov)))));
  }
  
  void update(){
    dir = getDir();
    povCenter = Vector.add(pos,Vector.multiply(dir,povDst));
    horizontalDirScreen = getHorizontalDir();    
    verticalDirScreen = Vector.normalize(Vector.cross(horizontalDirScreen,dir));
  }
  
  Vector getDir(){
    float r = ro*sin(angleY);
    return new Vector(r*sin(angleX),ro*cos(angleY),r*cos(angleX));
  }
  
  Vector getHorizontalDir(){
    return new Vector(+cos(angleX),0,-sin(angleX));    
  }
  
  void rotateX(float rate){
    angleX += rate;
  }
  void rotateY(float rate){
    angleY += rate;
  }
  
  void moveX(float rate){
    pos = Vector.add(pos,Vector.multiply(Vector.normalize(horizontalDirScreen),rate*speed*deltatime));
  }
  void moveY(float rate){
    pos = Vector.add(pos,Vector.multiply(Vector.normalize(verticalDirScreen),rate*speed*deltatime));
  }
  void moveZ(float rate){
    pos = Vector.add(pos,Vector.multiply(Vector.normalize(dir),rate*speed*deltatime));
  }
}
