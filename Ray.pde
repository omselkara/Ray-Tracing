class Ray {
  Vector pos;
  Vector dir;

  Ray(Vector pos, Vector dir) {
    this.pos = pos;
    this.dir = dir;
  }

  Intersection getClosestIntersection(ArrayList<Shape> shapes) {
    Vector closest = null;
    Shape closestShape = null;
    float closestT = -1;
    for (Shape shape : shapes) {
      if (shape.type==1 || shape.type==2) {
        float denom = Vector.dot(this.dir, shape.normal);
        if (denom==0)continue;
        float t = Vector.dot(Vector.substract(shape.center, this.pos), shape.normal)/denom;
        if (t<=0)continue;
        Vector point = Vector.add(this.pos, Vector.multiply(this.dir, t));
        if (!shape.isInside(point)) continue;
        if (closestT==-1 || t<closestT) {
          closestT = t;
          closest = point;
          closestShape = shape;
        }
      }
      if (shape.type==3) {
        float a = Vector.dot(dir, dir);
        float b = 2 * Vector.dot(dir, Vector.substract(pos, shape.center));
        float c = Vector.dot(shape.center, shape.center)+Vector.dot(pos, pos)-2 * Vector.dot(pos, shape.center) - shape.radius*shape.radius;
        float delta = b*b-4*a*c;
        if (delta<0)continue;
        else if (delta==0) {
          float t = -b/(2*a);
          if (t<0) continue;
          if (closestT==-1 || t<closestT) {
            closestT = t;
            closest = Vector.add(this.pos, Vector.multiply(this.dir, t));
            closestShape = shape;
          }
        } else {
          float sqrtDelta = sqrt(delta);
          float t0 = (-b+sqrtDelta)/(2*a);
          float t1 = (-b-sqrtDelta)/(2*a);
          if (t0<0) {
            if (t1<0)continue;
            if (closestT==-1 || t1<closestT) {
              closestT = t1;
              closest = Vector.add(this.pos, Vector.multiply(this.dir, t1));
              closestShape = shape;
            }
          } else if (t1<0) {
            if (closestT==-1 || t0<closestT) {
              closestT = t0;
              closest = Vector.add(this.pos, Vector.multiply(this.dir, t0));
              closestShape = shape;
            }
          } else {
            float t = min(t0, t1);
            if (closestT==-1 || t<closestT) {
              closestT = t;
              closest = Vector.add(this.pos, Vector.multiply(this.dir, t));
              closestShape = shape;
            }
          }
        }
      }
    }
    if (closest==null)return null;
    return new Intersection(closest, closestShape);
  }
}

Vector randomReflect(Vector normal,float[] values) {
  Vector dir = new Vector(values[0]*2.0-1, values[1]*2.0-1, values[2]*2.0-1);
  if (Vector.dot(normal, dir)<0.0)return Vector.negate(dir);
  return Vector.normalize(dir);
}

float randomValue(int seed) {
    seed = seed * 747796405 - 1403630843;
    int result = ((seed >> ((seed >> 28) + 4)) ^ seed) * 277803737;
    result = (result >> 22) ^ result;
    return (float)result / (4294967295.0/2f);
}

int newSeed(int seed){
  seed = seed * 747796405 - 1403630843;
  return seed;
}
