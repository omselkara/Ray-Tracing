Intersection getClosestIntersection(float closestDst,Ray ray,int from,int to,int fromShapeIndex){
    Intersection intersection;
    intersection.shapeIndex = -1;
    intersection.dst = closestDst;
    for (int index=from;index<to;index++){        
        if (index==fromShapeIndex)continue;

        vec3 a = getShapePos1(index);
        vec3 b = getShapePos2(index);
        vec3 c = getShapePos3(index);
        vec3 edgeAB = b-a;
        vec3 edgeAC = c-a;
        vec3 normalVector = cross(edgeAB,edgeAC);
        
        float determinant = -dot(ray.dir, normalVector);

        if (abs(determinant) < 1E-6)continue;        
        vec3 ao = ray.pos - a;
        vec3 dao = cross(ao,ray.dir);
        
        float invDet = 1.0 / determinant;

        float dst = dot(ao,normalVector) * invDet;
        float u = dot(edgeAC,dao) * invDet;
        float v = -dot(edgeAB,dao) * invDet;
        float w = 1.0 - u - v;

        if (dst >= 0.0 && u >= 0.0 && v >= 0.0 && w >= 0.0 && intersection.dst > dst){
            intersection.pos = ray.pos + ray.dir * dst;
            intersection.shapeIndex = index;
            intersection.frontFace = determinant>1E-6;
            intersection.dst = dst;
        }
    }
    return intersection;
}

