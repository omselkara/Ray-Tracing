int maxDivide = 32; //<>// //<>// //<>//
float delta = 0.1;

class BVHNode {
  Shape[] shapes;
  Vector tMin = new Vector(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY);
  Vector tMax = new Vector(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY);
  BVHNode left;
  BVHNode right;
  int index = -1;
  boolean dontSplit = false;


  BVHNode(int shapeCount) {
    shapes = new Shape[shapeCount];
  }

  BVHNode(List<Shape> shapes) {
    this.shapes = new Shape[shapes.size()];
    for (int i=0; i<shapes.size(); i++) {
      this.shapes[i] = shapes.get(i);
    }
  }

  void calculateBbox() {
    tMin = new Vector(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY);
    tMax = new Vector(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY);
    ;
    for (Shape shape : shapes) {
      include(shape);
    }
  }

  void fix() {
    if (tMin.x==tMax.x) {
      tMin.x -= delta;
      tMax.x += delta;
    }
    if (tMin.y==tMax.y) {
      tMin.y -= delta;
      tMax.y += delta;
    }
    if (tMin.z==tMax.z) {
      tMin.z -= delta;
      tMax.z += delta;
    }
  }

  void include(Shape shape) {
    if (tMin.x > shape.minPos.x)tMin.x = shape.minPos.x;
    if (tMin.y > shape.minPos.y)tMin.y = shape.minPos.y;
    if (tMin.z > shape.minPos.z)tMin.z = shape.minPos.z;
    if (tMax.x < shape.maxPos.x)tMax.x = shape.maxPos.x;
    if (tMax.y < shape.maxPos.y)tMax.y = shape.maxPos.y;
    if (tMax.z < shape.maxPos.z)tMax.z = shape.maxPos.z;
  }

  void orderShapesInAxis(int axis) {

    Arrays.parallelSort(shapes, (a, b) -> {
      if (axis == 0) return Float.compare(a.center.x, b.center.x);
      if (axis == 1) return Float.compare(a.center.y, b.center.y);
      return Float.compare(a.center.z, b.center.z);
    }
    );
  }

  boolean split() {
    if (dontSplit || shapes.length<=2) {
      left = null;
      right = null;
      return false;
    } else {
      float bestCost = Float.POSITIVE_INFINITY;
      int bestPos = 0;

      int axis = getLongestAxis();
      orderShapesInAxis(axis);
      /*for (int divide=0; divide<divideTo-1; divide++) {
       float rate = (divide+1.0)/(divideTo);
       int pos = (int)(shapes.size()*rate);
       if (pos==0 || pos==shapes.size()-1)continue;
       left = new BVHNode();
       right = new BVHNode();
       for (int index=0; index<shapes.size(); index++) {
       if (index < pos) {
       left.include(shapes.get(index));
       } else {
       right.include(shapes.get(index));
       }
       }
       
       float totalCost = left.cost(pos)+right.cost(shapes.size()-pos);
       if (totalCost<bestCost) {
       bestPos = pos;
       bestCost = totalCost;
       bestLeft = left;
       bestRight = right;
       bestShapes = new ArrayList<Shape>(shapes);
       }
       }*/
      int n = shapes.length;
      Vector[] preMin = new Vector[n];
      Vector[] preMax = new Vector[n];
      Vector[] sufMin = new Vector[n];
      Vector[] sufMax = new Vector[n];
      preMin[0] = new Vector(shapes[0].minPos);
      preMax[0] = new Vector(shapes[0].maxPos);
      for (int i = 1; i < n; i++) {
        preMin[i] = new Vector(preMin[i-1]);
        preMax[i] = new Vector(preMax[i-1]);

        Shape shape = shapes[i];
        if (preMin[i].x>shape.minPos.x)preMin[i].x = shape.minPos.x;
        if (preMin[i].y>shape.minPos.y)preMin[i].y = shape.minPos.y;
        if (preMin[i].z>shape.minPos.z)preMin[i].z = shape.minPos.z;

        if (preMax[i].x<shape.maxPos.x)preMax[i].x = shape.maxPos.x;
        if (preMax[i].y<shape.maxPos.y)preMax[i].y = shape.maxPos.y;
        if (preMax[i].z<shape.maxPos.z)preMax[i].z = shape.maxPos.z;
      }

      sufMin[n-1] = new Vector(shapes[n-1].minPos);
      sufMax[n-1] = new Vector(shapes[n-1].maxPos);
      for (int i = n-2; i >= 0; i--) {
        sufMin[i] = new Vector(sufMin[i+1]);
        sufMax[i] = new Vector(sufMax[i+1]);

        Shape shape = shapes[i];
        if (sufMin[i].x>shape.minPos.x)sufMin[i].x = shape.minPos.x;
        if (sufMin[i].y>shape.minPos.y)sufMin[i].y = shape.minPos.y;
        if (sufMin[i].z>shape.minPos.z)sufMin[i].z = shape.minPos.z;

        if (sufMax[i].x<shape.maxPos.x)sufMax[i].x = shape.maxPos.x;
        if (sufMax[i].y<shape.maxPos.y)sufMax[i].y = shape.maxPos.y;
        if (sufMax[i].z<shape.maxPos.z)sufMax[i].z = shape.maxPos.z;
      }
      bestPos  = -1;
      float wholeCost = cost(n);
      for (int i = 1; i < n-1; i++) {
        float leftArea  = surfaceArea(preMin[i-1], preMax[i-1]);
        float rightArea = surfaceArea(sufMin[i], sufMax[i]);
        float cost = leftArea * (i) + rightArea * (n - i);
        if (cost < bestCost) {
          bestCost = cost;
          bestPos  = i;
          if (bestCost >= wholeCost) {
            return false;
          }
        }
      }
      if (bestPos <= 0 || bestPos >= n || bestCost >= wholeCost) {
        return false;
      } else {
        left = new BVHNode(bestPos);
        right = new BVHNode(n-bestPos);
        for (int i=0; i<bestPos; i++) {
          left.shapes[i] = shapes[i];
        }
        for (int i=bestPos; i<n; i++) {
          right.shapes[i-bestPos] = shapes[i];
        }

        left.calculateBbox();
        left.fix();
        right.calculateBbox();
        right.fix();


        shapes = null;
        return true;
      }
    }
  }

  float surfaceArea(Vector min, Vector max) {
    Vector d = Vector.substract(max, min);
    return d.x*(d.y + d.z) + d.y*d.z;
  }

  float cost(int shapeCount) {
    Vector size = Vector.substract(tMax, tMin);
    float area = size.x*(size.y+size.z)+size.y*size.z;
    return area*shapeCount;
  }

  int getLongestAxis() {
    Vector lengths = Vector.substract(tMax, tMin);
    if (lengths.x >= lengths.y && lengths.x >= lengths.z) return 0;
    if (lengths.y >= lengths.z) return 1;
    return 2;
  }
}
