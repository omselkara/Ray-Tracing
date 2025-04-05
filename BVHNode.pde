import java.util.Collections;
import java.util.Comparator;

int maxDivide = 20;
float delta = 0.0001;

class BVHNode{
  List<Shape> shapes;
  Vector tMin;
  Vector tMax;
  BVHNode left;
  BVHNode right;
  int depth = 0;
  int index = -1;
  boolean dontSplit = false;
  
  
  BVHNode(){
    shapes = new ArrayList<Shape>();
  }
  
  void calculateBbox(){
    tMin = null;
    tMax = null;
    for (int i=0;i<shapes.size();i++){
      Shape shape = shapes.get(i);
      include(shape);
    }
  }
  
  void fix(){
    if (tMin.x==tMax.x){
      tMin.x -= delta;
      tMax.x += delta;
    }
    if (tMin.y==tMax.y){
      tMin.y -= delta;
      tMax.y += delta;
    }
    if (tMin.z==tMax.z){
      tMin.z -= delta;
      tMax.z += delta;
    }
  }
  
  void include(Shape shape){    
    if (tMin==null){
      tMin = new Vector(shape.minPos.x,shape.minPos.y,shape.minPos.z);
    }
    if (tMax==null){
      tMax = new Vector(shape.maxPos.x,shape.maxPos.y,shape.maxPos.z);
    }
    if (tMin.x > shape.minPos.x)tMin.x = shape.minPos.x;
    if (tMin.y > shape.minPos.y)tMin.y = shape.minPos.y;
    if (tMin.z > shape.minPos.z)tMin.z = shape.minPos.z;
    if (tMax.x < shape.maxPos.x)tMax.x = shape.maxPos.x;
    if (tMax.y < shape.maxPos.y)tMax.y = shape.maxPos.y;
    if (tMax.z < shape.maxPos.z)tMax.z = shape.maxPos.z;
  }
  
  void orderShapesInAxis(int axis){
    Collections.sort(shapes,new Comparator<Shape>(){
      public int compare(Shape a,Shape b){
        if (axis==0){
          return a.center.x > b.center.x ? 1 : a.center.x == b.center.x ? 0 : -1;
        }
        if (axis==1){
          return a.center.y > b.center.y ? 1 : a.center.y == b.center.y ? 0 : -1;
        }
        return a.center.z > b.center.z ? 1 : a.center.z == b.center.z ? 0 : -1;
      }
    });
  }
  
  void split(){    
    if (dontSplit || shapes.size()<=2){
      left = null;
      right = null;
    }
    else{
      float bestCost = Float.POSITIVE_INFINITY;
      int bestPos = 0;
      int divideTo = min(maxDivide,shapes.size());
      BVHNode bestLeft = null;
      BVHNode bestRight = null;
      ArrayList<Shape> bestShapes = null;
      for (int axis=0;axis<3;axis++){
        orderShapesInAxis(axis);
        for (int divide=0;divide<divideTo-1;divide++){
          float rate = (divide+1.0)/(divideTo);
          int pos = (int)(shapes.size()*rate);
          if (pos==0 || pos==shapes.size()-1)continue;
          left = new BVHNode();
          right = new BVHNode();
          for (int index=0;index<shapes.size();index++){
            if (index < pos){
              left.include(shapes.get(index));
            }
            else{
              right.include(shapes.get(index));
            }
          }
          
          float totalCost = left.cost(pos)+right.cost(shapes.size()-pos);
          if (totalCost<bestCost){
            bestPos = pos;
            bestCost = totalCost;
            bestLeft = left;
            bestRight = right;
            bestShapes = new ArrayList<Shape>(shapes);
          }
        }
      }
      if (cost(shapes.size())<=bestCost){
        left = null;
        right = null;
      }
      else{
        left = bestLeft;
        right = bestRight;
        left.shapes = bestShapes.subList(0,bestPos);
        right.shapes = bestShapes.subList(bestPos,shapes.size());
        shapes = null;
      }
    }
  }
  
  float cost(int shapeCount){
    Vector size = Vector.substract(tMax,tMin);
    float area = size.x*(size.y+size.z)+size.y*size.z;
    return area*shapeCount;
  }
  
  int getLongestAxis(){
    Vector lengths = Vector.substract(tMax,tMin);
    if (lengths.x > lengths.y){
      if (lengths.x>lengths.z){
        return 0;
      }
      else{
        return 2;
      }
    }
    else{
      if (lengths.y > lengths.z){
        return 1;
      }
      else{
        return 2;
      }
    }
  }
}
