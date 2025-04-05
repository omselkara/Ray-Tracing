public abstract class Shape{
  public Vector[] lines;
  public Vector center,normal;
  public Vector normal1 = new Vector(0);
  public Vector normal2 = new Vector(0);
  public Vector normal3 = new Vector(0);
  public Vector minPos,maxPos;
  public abstract boolean isInside(Vector pos);
  public int type = 0;//0:Nothing  1:Triangle 2:Sphere
  public float radius = 0f;
  public Material material = new Material();
  public boolean isSecondPart = false;
  public boolean baryCenteric = false;
  public Vector getNormal(Vector pos){
    return null;
  }
}

Vector getNormal(Shape shape,Vector pos){
  if (shape.type==3)return shape.getNormal(pos);
  return shape.normal;
}

void addModel(String modelName,Vector pos,Vector scale,Vector orient,List<Shape> shapes){
  PShape shape = loadShape(modelName);
  scale.x = -scale.x;
  for (int i = 0; i < shape.getChildCount(); i++) {
    PShape child = shape.getChild(i);
    if (child.getVertexCount()==3){
      PVector v0 = child.getVertex(0);
      PVector v1 = child.getVertex(1);
      PVector v2 = child.getVertex(2);
      
      // Get normals of the triangle
      PVector n0 = child.getNormal(0);
      PVector n1 = child.getNormal(1);
      PVector n2 = child.getNormal(2);
      Vector normal1 = new Vector(n0.x,n0.y,n0.z);
      Vector normal2 = new Vector(n1.x,n1.y,n1.z);
      Vector normal3 = new Vector(n2.x,n2.y,n2.z);
      normal1 = Vector.normalize(normal1);
      normal2 = Vector.normalize(normal2);
      normal3 = Vector.normalize(normal3);
      normal1.x = -normal1.x;
      normal2.x = -normal2.x;
      normal3.x = -normal3.x;
      normal1 = Vector.rotate(normal1,orient.x,orient.y,orient.z);
      normal2 = Vector.rotate(normal2,orient.x,orient.y,orient.z);
      normal3 = Vector.rotate(normal3,orient.x,orient.y,orient.z);
      
      Vector pos1 = Vector.multiply(new Vector(v0.x,v0.y,v0.z),scale);
      Vector pos2 = Vector.multiply(new Vector(v1.x,v1.y,v1.z),scale);
      Vector pos3 = Vector.multiply(new Vector(v2.x,v2.y,v2.z),scale);
      pos1 = Vector.add(pos,Vector.rotate(pos1,orient.x,orient.y,orient.z));
      pos2 = Vector.add(pos,Vector.rotate(pos2,orient.x,orient.y,orient.z));
      pos3 = Vector.add(pos,Vector.rotate(pos3,orient.x,orient.y,orient.z));
      
      color col = color(child.getFill(0));
      
      Material mat = new Material();
      mat.col = getConstantColor(rgb(red(col),green(col),blue(col)));
      
      Shape triangle = new Triangle(pos3,pos2,pos1);
      triangle.normal1 = normal3;
      triangle.normal2 = normal2;
      triangle.normal3 = normal1;
      triangle.material = mat;
      triangle.baryCenteric = true;
      shapes.add(triangle);
    }
    else if (child.getVertexCount()==4){
      PVector v0 = child.getVertex(0);
      PVector v1 = child.getVertex(1);
      PVector v2 = child.getVertex(2);
      PVector v3 = child.getVertex(3);
      
      // Get normals of the triangle
      PVector n0 = child.getNormal(0);
      PVector n1 = child.getNormal(1);
      PVector n2 = child.getNormal(2);
      PVector n3 = child.getNormal(3);
     
      
      Vector normal1 = new Vector(n0.x,n0.y,n0.z);
      Vector normal2 = new Vector(n1.x,n1.y,n1.z);
      Vector normal3 = new Vector(n2.x,n2.y,n2.z);
      Vector normal4 = new Vector(n3.x,n3.y,n3.z);
      normal1 = Vector.normalize(normal1);
      normal2 = Vector.normalize(normal2);
      normal3 = Vector.normalize(normal3);
      normal4 = Vector.normalize(normal4);
      normal1.x = -normal1.x;
      normal2.x = -normal2.x;
      normal3.x = -normal3.x;
      normal4.x = -normal4.x;
      normal1 = Vector.rotate(normal1,orient.x,orient.y,orient.z);
      normal2 = Vector.rotate(normal2,orient.x,orient.y,orient.z);
      normal3 = Vector.rotate(normal3,orient.x,orient.y,orient.z);
      normal4 = Vector.rotate(normal4,orient.x,orient.y,orient.z);
      Vector pos1 = Vector.multiply(new Vector(v0.x,v0.y,v0.z),scale);
      Vector pos2 = Vector.multiply(new Vector(v1.x,v1.y,v1.z),scale);
      Vector pos3 = Vector.multiply(new Vector(v2.x,v2.y,v2.z),scale);
      Vector pos4 = Vector.multiply(new Vector(v3.x,v3.y,v3.z),scale);
      pos1 = Vector.add(pos,Vector.rotate(pos1,orient.x,orient.y,orient.z));
      pos2 = Vector.add(pos,Vector.rotate(pos2,orient.x,orient.y,orient.z));
      pos3 = Vector.add(pos,Vector.rotate(pos3,orient.x,orient.y,orient.z));
      pos4 = Vector.add(pos,Vector.rotate(pos4,orient.x,orient.y,orient.z));
      
      color col = color(child.getFill(0));
      
      Material mat = new Material();
      mat.col = getConstantColor(rgb(red(col),green(col),blue(col)));
      
      addRectangle(pos4,pos3,pos2,pos1,mat,shapes);
      shapes.get(shapes.size()-2).normal1 = normal4;
      shapes.get(shapes.size()-2).normal2 = normal2;
      shapes.get(shapes.size()-2).normal3 = normal3;
      shapes.get(shapes.size()-1).normal1 = normal2;
      shapes.get(shapes.size()-1).normal2 = normal1;
      shapes.get(shapes.size()-1).normal3 = normal4;
      shapes.get(shapes.size()-1).isSecondPart = true;
      shapes.get(shapes.size()-1).baryCenteric = true;
      shapes.get(shapes.size()-2).baryCenteric = true;
      
    }
  }
}

void addModel(String modelName,Vector pos,Vector scale,Vector orient,Material mat,List<Shape> shapes,boolean setColor){
  PShape shape = loadShape(modelName);
  scale.x = -scale.x;
  for (int i = 0; i < shape.getChildCount(); i++) {
    PShape child = shape.getChild(i);
    if (child.getVertexCount()==3){
      
      PVector v0 = child.getVertex(0);
      PVector v1 = child.getVertex(1);
      PVector v2 = child.getVertex(2);
      
      // Get normals of the triangle
      PVector n0 = child.getNormal(0);
      PVector n1 = child.getNormal(1);
      PVector n2 = child.getNormal(2);
      Vector normal1 = new Vector(n0.x,n0.y,n0.z);
      Vector normal2 = new Vector(n1.x,n1.y,n1.z);
      Vector normal3 = new Vector(n2.x,n2.y,n2.z);
      normal1 = Vector.rotate(normal1,orient.x,orient.y,orient.z);
      normal2 = Vector.rotate(normal2,orient.x,orient.y,orient.z);
      normal3 = Vector.rotate(normal3,orient.x,orient.y,orient.z);
      normal1 = Vector.normalize(normal1);
      normal2 = Vector.normalize(normal2);
      normal3 = Vector.normalize(normal3);
      normal1.x = -normal1.x;
      normal2.x = -normal2.x;
      normal3.x = -normal3.x;
      Vector pos1 = Vector.multiply(new Vector(v0.x,v0.y,v0.z),scale);
      Vector pos2 = Vector.multiply(new Vector(v1.x,v1.y,v1.z),scale);
      Vector pos3 = Vector.multiply(new Vector(v2.x,v2.y,v2.z),scale);
      pos1 = Vector.add(pos,Vector.rotate(pos1,orient.x,orient.y,orient.z));
      pos2 = Vector.add(pos,Vector.rotate(pos2,orient.x,orient.y,orient.z));
      pos3 = Vector.add(pos,Vector.rotate(pos3,orient.x,orient.y,orient.z));
      
      Shape triangle = new Triangle(pos3,pos2,pos1);
      triangle.normal3 = normal1;
      triangle.normal2 = normal2;
      triangle.normal1 = normal3;
      triangle.baryCenteric = true;
      if (setColor){
        color col = color(child.getFill(0));
      
        Material triMat = new Material();
        triMat.col = getConstantColor(rgb(red(col),green(col),blue(col)));
        triMat.isLight = mat.isLight;
        triMat.smoothness = mat.smoothness;
        triMat.specularChance = mat.specularChance;
        triMat.specularColor = mat.specularColor;
        triMat.dielectric = mat.dielectric;
        triangle.material = triMat;
      }
      else{
        triangle.material = mat;
      }
      shapes.add(triangle);
    }
    else if (child.getVertexCount()==4){
      PVector v0 = child.getVertex(0);
      PVector v1 = child.getVertex(1);
      PVector v2 = child.getVertex(2);
      PVector v3 = child.getVertex(3);
      
      // Get normals of the triangle
      PVector n0 = child.getNormal(0);
      PVector n1 = child.getNormal(1);
      PVector n2 = child.getNormal(2);
      PVector n3 = child.getNormal(3);
     
      
      Vector normal1 = new Vector(n0.x,n0.y,n0.z);
      Vector normal2 = new Vector(n1.x,n1.y,n1.z);
      Vector normal3 = new Vector(n2.x,n2.y,n2.z);
      Vector normal4 = new Vector(n3.x,n3.y,n3.z);
      normal1 = Vector.normalize(normal1);
      normal2 = Vector.normalize(normal2);
      normal3 = Vector.normalize(normal3);
      normal4 = Vector.normalize(normal4);
      normal1.x = -normal1.x;
      normal2.x = -normal2.x;
      normal3.x = -normal3.x;
      normal4.x = -normal4.x;
      normal1 = Vector.rotate(normal1,orient.x,orient.y,orient.z);
      normal2 = Vector.rotate(normal2,orient.x,orient.y,orient.z);
      normal3 = Vector.rotate(normal3,orient.x,orient.y,orient.z);
      normal4 = Vector.rotate(normal4,orient.x,orient.y,orient.z);
      Vector pos1 = Vector.multiply(new Vector(v0.x,v0.y,v0.z),scale);
      Vector pos2 = Vector.multiply(new Vector(v1.x,v1.y,v1.z),scale);
      Vector pos3 = Vector.multiply(new Vector(v2.x,v2.y,v2.z),scale);
      Vector pos4 = Vector.multiply(new Vector(v3.x,v3.y,v3.z),scale);
      pos1 = Vector.add(pos,Vector.rotate(pos1,orient.x,orient.y,orient.z));
      pos2 = Vector.add(pos,Vector.rotate(pos2,orient.x,orient.y,orient.z));
      pos3 = Vector.add(pos,Vector.rotate(pos3,orient.x,orient.y,orient.z));
      pos4 = Vector.add(pos,Vector.rotate(pos4,orient.x,orient.y,orient.z));
      if (setColor){
        color col = color(child.getFill(0));
      
        Material triMat = new Material();
        triMat.col = getConstantColor(rgb(red(col),green(col),blue(col)));
        triMat.isLight = mat.isLight;
        triMat.smoothness = mat.smoothness;
        triMat.specularChance = mat.specularChance;
        triMat.specularColor = mat.specularColor;
        triMat.dielectric = mat.dielectric;
        addRectangle(pos4,pos3,pos2,pos1,triMat,shapes);
      }
      else{
        addRectangle(pos4,pos3,pos2,pos1,mat,shapes);
      }
      shapes.get(shapes.size()-2).normal1 = normal4;
      shapes.get(shapes.size()-2).normal2 = normal2;
      shapes.get(shapes.size()-2).normal3 = normal3;
      shapes.get(shapes.size()-1).normal1 = normal2;
      shapes.get(shapes.size()-1).normal2 = normal1;
      shapes.get(shapes.size()-1).normal3 = normal4;
      shapes.get(shapes.size()-1).isSecondPart = true;
      shapes.get(shapes.size()-1).baryCenteric = true;
      shapes.get(shapes.size()-2).baryCenteric = true;
      
    }
  }
}
