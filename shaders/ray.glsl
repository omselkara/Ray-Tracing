int checkedShape = 0;
int checkedBBox = 0;

Intersection getClosestIntersection(Ray ray,int fromShapeIndex){
    Intersection intersection;
    intersection.shapeIndex = -1;
    intersection.dst = inf;
    for (int index=0;index<shapeCount;index++){        
        int type = getShapeType(index);
        if (index==fromShapeIndex)continue;
        checkedShape++;
        if (type==1 || type==3){
            vec3 a = getShapeLinePos(index,0);
            vec3 b = getShapeLinePos(index,1);
            vec3 c = getShapeLinePos(index,2);
            vec3 edgeAB = b-a;
            vec3 edgeAC = c-a;
            vec3 normalVector = cross(edgeAB,edgeAC);
            
            
            vec3 ao = ray.pos - a;
            vec3 dao = cross(ao,ray.dir);

            float determinant = -dot(ray.dir, normalVector);
            float invDet = 1.0 / determinant;

            float dst = dot(ao,normalVector) * invDet;
            float u = dot(edgeAC,dao) * invDet;
            float v = -dot(edgeAB,dao) * invDet;
            float w = 1.0 - u - v;

            bool hit = determinant >= 1E-6 && dst >= 0.0 && u >= 0.0 && v >= 0.0 && w >= 0.0;
            if (hit && intersection.dst > dst){
                intersection.pos = ray.pos + ray.dir * dst;
                intersection.shapeIndex = index;
                intersection.frontFace = true;
                intersection.dst = dst;
            }
            else{
                
                edgeAB = b-c;
                edgeAC = a-c;
                normalVector = cross(edgeAB,edgeAC);
                
                
                ao = ray.pos - c;
                dao = cross(ao,ray.dir);

                determinant = -dot(ray.dir, normalVector);
                invDet = 1.0 / determinant;

                dst = dot(ao,normalVector) * invDet;
                u = dot(edgeAC,dao) * invDet;
                v = -dot(edgeAB,dao) * invDet;
                w = 1.0 - u - v;

                hit = determinant >= 1E-6 && dst >= 0.0 && u >= 0.0 && v >= 0.0 && w >= 0.0;
                if (hit && (intersection.dst == -1.0 || intersection.dst > dst)){
                    intersection.pos = ray.pos + ray.dir * dst;
                    intersection.shapeIndex = index;
                    intersection.frontFace = false;
                    intersection.dst = dst;
                }
            }
        }
        else if (type==2){
            vec3 pos = ray.pos - getShapeCenter(index);
            float radius = getShapeRadius(index);
            float a = dot(pos,ray.dir);
            float delta = a*a - (dot(pos,pos)-radius*radius);
            if (delta>=0){
                float dst = -a - sqrt(delta);
                if (dst>=0.0 && intersection.dst > dst){
                    intersection.pos = ray.pos + ray.dir * dst;
                    intersection.shapeIndex = index;
                    intersection.dst = dst;
                    intersection.frontFace = true;
                }
                if (dst<=0.0){
                    dst = -a + sqrt(delta);
                    if (dst>=0.0 && intersection.dst > dst){
                        intersection.pos = ray.pos + ray.dir * dst;
                        intersection.shapeIndex = index;
                        intersection.dst = dst;
                        intersection.frontFace = false;
                    }
                }
            }
        }
    }
    return intersection;
}

Intersection getClosestIntersection(float closestDst,Ray ray,int from,int to,int fromShapeIndex){
    Intersection intersection;
    intersection.shapeIndex = -1;
    intersection.dst = closestDst;
    for (int index=from;index<to;index++){        
        int type = getShapeType(index);
        if (index==fromShapeIndex)continue;
        checkedShape++;
        if (type==1 || type==3){
            vec3 a = getShapeLinePos(index,0);
            vec3 b = getShapeLinePos(index,1);
            vec3 c = getShapeLinePos(index,2);
            vec3 edgeAB = b-a;
            vec3 edgeAC = c-a;
            vec3 normalVector = cross(edgeAB,edgeAC);
            
            
            vec3 ao = ray.pos - a;
            vec3 dao = cross(ao,ray.dir);

            float determinant = -dot(ray.dir, normalVector);
            float invDet = 1.0 / determinant;

            float dst = dot(ao,normalVector) * invDet;
            float u = dot(edgeAC,dao) * invDet;
            float v = -dot(edgeAB,dao) * invDet;
            float w = 1.0 - u - v;

            bool hit = determinant >= 1E-6 && dst >= 0.0 && u >= 0.0 && v >= 0.0 && w >= 0.0;
            if (hit && intersection.dst > dst){
                intersection.pos = ray.pos + ray.dir * dst;
                intersection.shapeIndex = index;
                intersection.frontFace = true;
                intersection.dst = dst;
            }
            else{
                
                edgeAB = b-c;
                edgeAC = a-c;
                normalVector = cross(edgeAB,edgeAC);
                
                
                ao = ray.pos - c;
                dao = cross(ao,ray.dir);

                determinant = -dot(ray.dir, normalVector);
                invDet = 1.0 / determinant;

                dst = dot(ao,normalVector) * invDet;
                u = dot(edgeAC,dao) * invDet;
                v = -dot(edgeAB,dao) * invDet;
                w = 1.0 - u - v;

                hit = determinant >= 1E-6 && dst >= 0.0 && u >= 0.0 && v >= 0.0 && w >= 0.0;
                if (hit && (intersection.dst == -1.0 || intersection.dst > dst)){
                    intersection.pos = ray.pos + ray.dir * dst;
                    intersection.shapeIndex = index;
                    intersection.frontFace = false;
                    intersection.dst = dst;
                }
            }
        }
        else if (type==2){
            vec3 pos = ray.pos - getShapeCenter(index);
            float radius = getShapeRadius(index);
            float a = dot(pos,ray.dir);
            float delta = a*a - (dot(pos,pos)-radius*radius);
            if (delta>=0){
                float dst = -a - sqrt(delta);
                if (dst>=0.0 && intersection.dst > dst){
                    intersection.pos = ray.pos + ray.dir * dst;
                    intersection.shapeIndex = index;
                    intersection.dst = dst;
                    intersection.frontFace = true;
                }
                if (dst<=0.0){
                    dst = -a + sqrt(delta);
                    if (dst>=0.0 && intersection.dst > dst){
                        intersection.pos = ray.pos + ray.dir * dst;
                        intersection.shapeIndex = index;
                        intersection.dst = dst;
                        intersection.frontFace = false;
                    }
                }
            }
        }
    }
    return intersection;
}

