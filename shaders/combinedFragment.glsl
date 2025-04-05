//------------------------------  shaders/structs.glsl  ------------------------------
#version 460 core
#define PI 3.14159265359

const float inf = 1.0/0.0;

struct Intersection{
  vec3 pos;
  int shapeIndex;
  bool frontFace;
  float dst;
};

struct Ray{
  vec3 pos;
  vec3 dir;
  vec3 invDir;
};
//------------------------------  shaders/structs.glsl  ------------------------------



//------------------------------  shaders/funcs.glsl  ------------------------------
float random(inout uint state) {
    state = state * 747796405u + 2891336453u;
    uint result = ((state >> ((state >> 28) + 4)) ^ state) * 277803737u;
    result = (result >> 22) ^ result;
    return float(result) / 4294967295.0;
}

float randomNormal(inout uint state){
    float theta = 2.0 * PI * random(state);
    float rho = sqrt(-2.0 * log(random(state)));
    return rho * cos(theta);
}
vec3 randomReflect(vec3 normal,inout uint seed){
    float x = randomNormal(seed);
    float y = randomNormal(seed);
    float z = randomNormal(seed);
    vec3 dir = vec3(x,y,z);
    if (dot(normal,dir)<0.0)return -dir;
    return dir;
}

vec2 randomPointOnCircle(inout uint state){
    float angle = random(state)*2.0*3.14159265359;
    vec2 point = vec2(cos(angle),sin(angle));
    return point * sqrt(random(state));
}

vec3 computeBarycentric(vec3 A, vec3 B, vec3 C, vec3 P) {
    // Üçgenin alanını hesapla (ABC üçgeni)
    vec3 v0 = B - A;
    vec3 v1 = C - A;
    vec3 normal = cross(v0, v1);
    float areaABC = length(normal); // Üçgen ABC'nin alanı (2 katı, çünkü |normal|)

    // Alt üçgenlerin alanlarını hesapla
    vec3 normalPBC = cross(B - P, C - P);
    float areaPBC = length(normalPBC);

    vec3 normalPCA = cross(C - P, A - P);
    float areaPCA = length(normalPCA);

    vec3 normalPAB = cross(A - P, B - P);
    float areaPAB = length(normalPAB);

    // Barysentirik koordinatları hesapla
    float u = areaPBC / areaABC;
    float v = areaPCA / areaABC;
    float w = areaPAB / areaABC;

    return vec3(u, v, w);
}
//------------------------------  shaders/funcs.glsl  ------------------------------



//------------------------------  shaders/camera.glsl  ------------------------------
float rate = 5;
float horizontalPov = 16.0/rate;
float verticalPov = 9.0/rate;
float pov = 1.0;

uniform vec3 pos;
uniform vec3 dir;
uniform vec3 povCenter;
uniform vec3 horizontalDirScreen;
uniform vec3 verticalDirScreen;

vec3 getRayPos(vec2 xy) {
    return povCenter + (horizontalDirScreen * xy.x * horizontalPov + verticalDirScreen * xy.y * verticalPov);
}

vec3 getRayDir(vec3 endPoint) {
    return normalize(endPoint - pos);
}

Ray getRay(vec2 xy){
    Ray ray;
    ray.pos = povCenter + (horizontalDirScreen * xy.x * horizontalPov + verticalDirScreen * xy.y * verticalPov);
    ray.dir = normalize(ray.pos - pos);
    ray.invDir = 1.0/ray.dir;
    return ray;
}
//------------------------------  shaders/camera.glsl  ------------------------------



//------------------------------  shaders/shape.glsl  ------------------------------
layout (std430, binding = 0) buffer ShapeBuffer {
    float shapes[];
};

layout (std430, binding = 1) buffer BVHBuffer {
    float BVHNodes[];
};

layout (std430, binding = 2) buffer MainNodeBuffer {
    float mainNodes[];
};

layout(std430, binding = 3) buffer ImageDataBuffer {
    float imagePixels[];
};

layout(std430, binding = 4) buffer ImageIdBuffer {
    float imageId[];
};

int shapeAttributes = (3*3+3+1+1+3+1+1+3+1+1+1+3*3);
int BVHAttributes = (3+3+2);

uniform int shapeCount;
uniform int BVHCount;
uniform int mainBVHCount;
uniform int imageCount;

vec3 getShapeLinePos(int shapeIndex,int lineIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+lineIndex*3],shapes[shapeIndex*shapeAttributes+lineIndex*3+1],shapes[shapeIndex*shapeAttributes+lineIndex*3+2]);
}

int getShapeType(int shapeIndex){ ///float mı hızlı uint mi dene
    return int(shapes[shapeIndex*shapeAttributes+3*3+3]);
}

vec3 getShapeCenter(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes],shapes[shapeIndex*shapeAttributes+1],shapes[shapeIndex*shapeAttributes+2]);
}

float getShapeRadius(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+3*3+4];
}

vec3 getShapeNormal(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3],shapes[shapeIndex*shapeAttributes+3*3+1],shapes[shapeIndex*shapeAttributes+3*3+2]);
}

float getShapeSpecularChance(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+3*3+9];
}

float getShapeSmoothness(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+3*3+8];
}

vec3 getShapeLightCol(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3+5],shapes[shapeIndex*shapeAttributes+3*3+6],shapes[shapeIndex*shapeAttributes+3*3+7]);
}

int isShapeSecondPart(int shapeIndex){
    return int(shapes[shapeIndex*shapeAttributes+3*3+14]);
}

int isShapeBarycenteric(int shapeIndex){
    return int(shapes[shapeIndex*shapeAttributes+3*3+15]);
}

vec3 getShapeNormal1(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3+16],shapes[shapeIndex*shapeAttributes+3*3+17],shapes[shapeIndex*shapeAttributes+3*3+18]);
}

vec3 getShapeNormal2(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3+19],shapes[shapeIndex*shapeAttributes+3*3+20],shapes[shapeIndex*shapeAttributes+3*3+21]);
}

vec3 getShapeNormal3(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3+22],shapes[shapeIndex*shapeAttributes+3*3+23],shapes[shapeIndex*shapeAttributes+3*3+24]);
}

vec3 getImageCol(vec2 uv,int shapeIndex){   
    int startIndex = int(imageId[shapeIndex*3]);
    int resX = int(imageId[shapeIndex*3+1]);
    int resY = int(imageId[shapeIndex*3+2]);
    //uv = vec2(mod(uv.x,1.0),mod(uv.y,1.0));
    int x = int(uv.x*(resX-1));
    //if (x==resX) x = resX-1;
    int y = int(uv.y*(resY-1));
    //if (y==resY)y = resY-1;
    int index = int(x+y*resX);
    return vec3(imagePixels[startIndex+3*index],imagePixels[startIndex+3*index+1],imagePixels[startIndex+3*index+2]);
    //if (uv.x>1.0) return vec3(0.0,0.0,1.0);
    //if (uv.y>1.0) return vec3(1.0);
    //return vec3(uv,0.0);
}

vec3 getShapeSpecularColor(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3*3+10],shapes[shapeIndex*shapeAttributes+3*3+11],shapes[shapeIndex*shapeAttributes+3*3+12]);;
}

float getShapeDielectric(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+3*3+13];
}

vec3 getBVHTMin(int BVHIndex){
    return vec3(BVHNodes[BVHIndex*BVHAttributes],BVHNodes[BVHIndex*BVHAttributes+1],BVHNodes[BVHIndex*BVHAttributes+2]);
}

vec3 getBVHTMax(int BVHIndex){
    return vec3(BVHNodes[BVHIndex*BVHAttributes+3],BVHNodes[BVHIndex*BVHAttributes+4],BVHNodes[BVHIndex*BVHAttributes+5]);
}

int getBVHIndex1(int BVHIndex){
    return int(BVHNodes[BVHIndex*BVHAttributes+6]);
}

int getBVHIndex2(int BVHIndex){
    return int(BVHNodes[BVHIndex*BVHAttributes+7]);
}


int getTotalNodeIndex(int mainNodeIndex){
    return int(mainNodes[mainNodeIndex]);
}

vec3 getNormal(int shapeIndex,vec3 pos){
    float type = getShapeType(shapeIndex);
    if (type==2.0) return normalize(pos-getShapeCenter(shapeIndex));
    if (isShapeBarycenteric(shapeIndex)==0)return getShapeNormal(shapeIndex);
    vec3 A = getShapeLinePos(shapeIndex,0);
    vec3 B = getShapeLinePos(shapeIndex,1);
    vec3 C = getShapeLinePos(shapeIndex,2);
    vec3 normal1 = getShapeNormal1(shapeIndex);
    vec3 normal2 = getShapeNormal2(shapeIndex);
    vec3 normal3 = getShapeNormal3(shapeIndex); 
    vec3 uvw = computeBarycentric(A,B,C,pos);
    return uvw.x*normal1+uvw.y*normal2+uvw.z*normal3;
}

vec2 getRectUV(vec3 pos,int shapeIndex){
    int type = getShapeType(shapeIndex);
    if (type==1 || type==3){
        vec3 a = getShapeLinePos(shapeIndex,0);
        vec3 b = getShapeLinePos(shapeIndex,1);
        vec3 c = getShapeLinePos(shapeIndex,2);
        vec3 AB = a-b;
        vec3 CB = c-b;
        vec3 posB = pos-b;
        float u = dot(AB,posB)/dot(AB,AB);
        float v = dot(CB,posB)/dot(CB,CB);
        if (isShapeSecondPart(shapeIndex)==1.0)return vec2(1.0-u,1.0-v);
        return vec2(u,v);
    }
    vec3 point = getNormal(shapeIndex,pos);
    float theta = atan(point.z,point.x);
    float phi = asin(point.y);
    return vec2(theta/(2.0*PI),phi/PI+0.5);
}
//------------------------------  shaders/shape.glsl  ------------------------------



//------------------------------  shaders/ray.glsl  ------------------------------
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

//------------------------------  shaders/ray.glsl  ------------------------------



//------------------------------  shaders/shader.glsl  ------------------------------
uniform vec2 u_resolution;
//uniform float u_time;
uniform int frame;
out vec4 gl_FragColor;

uniform int reflectCount;
uniform int rayCount;

uniform vec3 sunDir;
uniform vec3 sunColor;
uniform float sunRadius;
uniform float sunBloomStrength;
uniform float blurStrength;
uniform bool showAmbientLight;

const int maxDepth = 32;


vec3 ambientLight(vec3 dir){
    float dst = distance(dir,sunDir);
    return mix(mix(vec3(1.0),vec3(0.5),smoothstep(0.0,1.0,-dir.y*15.0)),
    mix(sunColor,mix(mix(vec3(1.0),vec3(0.1025,0.2025,0.50),smoothstep(0.0,1.0,dir.y*5.0)),sunColor,max(0.0,sunBloomStrength-pow(dst-sunRadius,0.3))),step(sunRadius,dst)),step(0.0,dir.y));
}
float reflectance(float cosine,float dielectric){
    float r0 = (1.0 - dielectric) / (1.0 + dielectric);
    r0 = r0*r0;
    return r0 + (1.0-r0) * pow((1.0-cosine),5);
}


bool hitBbox(Ray ray,int nodeIndex){
    vec3 tMinBVH = getBVHTMin(nodeIndex);
    vec3 tMaxBVH = getBVHTMax(nodeIndex);
    float tMax = 0;
    float tMin = 0;
    bool changed = false;
    for (int axis=0;axis<3;axis++){
        float t0 = (tMinBVH[axis]-ray.pos[axis])*ray.invDir[axis];
        float t1 = (tMaxBVH[axis]-ray.pos[axis])*ray.invDir[axis];
        if (t0<t1){
            if (!changed){
                tMin = t0;
                tMax = t1;
                changed = true;
            }
            else{
                if (t0>tMin)tMin = t0;
                if (t1<tMax)tMax = t1;
            }
        }
        else{
            if (!changed){
                tMin = t1;
                tMax = t0;
                changed = true;
            }
            else{
                if (t1>tMin)tMin = t1;
                if (t0<tMax)tMax = t0;
            }
        }
        if (tMax <= tMin || (tMax<0.0 && tMin<0.0)) return false;
    }
    return true;
}

float dstBbox(Ray ray,int nodeIndex){
    vec3 tMinBVH = getBVHTMin(nodeIndex);
    vec3 tMaxBVH = getBVHTMax(nodeIndex);
    float tMax = 0;
    float tMin = 0;
    bool changed = false;
    for (int axis=0;axis<3;axis++){
        //if (rayDir[axis]==0.0)continue;
        float t0 = (tMinBVH[axis]-ray.pos[axis])*ray.invDir[axis];
        float t1 = (tMaxBVH[axis]-ray.pos[axis])*ray.invDir[axis];
        if (t0<t1){
            if (!changed){
                tMin = t0;
                tMax = t1;
                changed = true;
            }
            else{
                if (t0>tMin)tMin = t0;
                if (t1<tMax)tMax = t1;
            }
        }
        else{
            if (!changed){
                tMin = t1;
                tMax = t0;
                changed = true;
            }
            else{
                if (t1>tMin)tMin = t1;
                if (t0<tMax)tMax = t0;
            }
        }
        if (tMax <= tMin || (tMax<0.0 && tMin<0.0)) return inf;
    }
    return tMin;
}

Intersection getIntersectionsFromBVH(float closestDst,Ray ray,int nodeIndex,int lastHitShape){    
    Intersection intersection;
    intersection.shapeIndex = -1;
    intersection.dst = closestDst;

    int list[maxDepth];

    for (int i=0;i<maxDepth;i++){
        list[i] = -1;
    }
    
    int i = 0;
    while (true){
        if (i<0){
            break;
        }
        if (nodeIndex==-1){
            if (i==0)break;
            i -= 1;
            if (list[i] != -1){
                nodeIndex = list[i];
                list[i] = -1;
            }            
            continue;
        }
        checkedBBox += 1;
        int index1 = getBVHIndex1(nodeIndex);
        int index2 = getBVHIndex2(nodeIndex);
        if (index1>index2){
            Intersection found = getClosestIntersection(intersection.dst,ray,index2,index1,lastHitShape);
            if (found.dst<intersection.dst){
                intersection = found;
            }
            if (i==0)break;
            i -= 1;
            if (list[i] != -1){
                nodeIndex = list[i];
                list[i] = -1;
            }            
            continue;
        }
        else{
            float t1 = dstBbox(ray,index1);
            float t2 = dstBbox(ray,index2);
            if (intersection.dst != inf){
                t1 = t1<intersection.dst ? t1 : inf;
                t2 = t2<intersection.dst ? t2 : inf;
            }
            if (t1==inf){
                list[i] = -1;
                if (t2==inf){
                    nodeIndex = -1;
                }
                else{
                    nodeIndex = index2;
                }
            }
            else{
                if (t2==inf){
                    nodeIndex = index1;
                    list[i] = -1;
                }
                else{
                    if (t1<t2){
                        nodeIndex = index1;
                        list[i] = index2;
                    }
                    else{
                        nodeIndex = index2;
                        list[i] = index1;
                    }
                }
            }
            i += 1;
        }        
    }

    return intersection;
}

Intersection getClosestIntersectionBVH(Ray ray,int lastHitShape){
    Intersection intersection;
    intersection.shapeIndex = -1;
    intersection.dst = inf;
    for (int i=0;i<mainBVHCount;i++){
        if (dstBbox(ray,getTotalNodeIndex(i))<intersection.dst){
            Intersection found = getIntersectionsFromBVH(intersection.dst,ray,getTotalNodeIndex(i),lastHitShape);
            if (found.dst<intersection.dst){
                intersection = found;
            }
        }
        
    }
    return intersection;
}


vec3 rayTrace(Ray mainRay,inout uint seed){
    vec3 lightColor = vec3(0.0);
    vec3 rayColor = vec3(1.0);
    Ray ray = mainRay;
    int lastHitShape = -1;
    for (int bounce=0;bounce<=reflectCount;bounce++){
        Intersection intersection = getClosestIntersectionBVH(ray,lastHitShape);
        if (intersection.shapeIndex != -1){
            lastHitShape = intersection.shapeIndex;
            vec3 normal = getNormal(lastHitShape,intersection.pos);
            if (!intersection.frontFace)normal *= -1.0;
            float dielectric = getShapeDielectric(lastHitShape);
            vec3 dir;
            if (dielectric!=0.0){
                float specularChance = getShapeSpecularChance(lastHitShape);
                if (random(seed)<specularChance){
                    vec3 diffuseReflection = normalize(randomReflect(normal,seed)+normal);
                    vec3 specularReflection = reflect(ray.dir,normal);
                    float smoothness = getShapeSmoothness(lastHitShape);
                    dir = mix(diffuseReflection,specularReflection,smoothness);
                    vec3 lightCol = getShapeLightCol(lastHitShape);
                    vec3 light = lightCol;
                    lightColor += light * rayColor;
                    rayColor *= getShapeSpecularColor(lastHitShape);     
                }
                else{
                    rayColor *= getImageCol(getRectUV(intersection.pos,lastHitShape),lastHitShape);//getShapeCol(lastHitShape);
                    float ri = intersection.frontFace ? (1.0/getShapeDielectric(lastHitShape)) : getShapeDielectric(lastHitShape);
                    float cosTheta = min(dot(-ray.dir,normal),1.0);
                    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);
                    bool cantRefract = ri * sinTheta > 1.0;
                    if (cantRefract || reflectance(cosTheta,ri) > random(seed)){
                        dir = reflect(ray.dir,normal);
                    }
                    else{
                        dir = refract(ray.dir,normal,ri); 
                    }
                }
                
            }
            else{
                vec3 diffuseReflection = normalize(randomReflect(normal,seed)+normal);
                vec3 specularReflection = reflect(ray.dir,normal);
                float specularChance = getShapeSpecularChance(lastHitShape);
                float isSpecular = random(seed)<specularChance ? 1.0:0.0;
                float smoothness = getShapeSmoothness(lastHitShape);
                dir = mix(diffuseReflection,specularReflection,smoothness * isSpecular);
                vec3 lightCol = getShapeLightCol(lastHitShape);
                vec3 light = lightCol;
                lightColor += light * rayColor;
                rayColor *= mix(getImageCol(getRectUV(intersection.pos,lastHitShape),lastHitShape),getShapeSpecularColor(lastHitShape),isSpecular);//getShapeCol(lastHitShape)
            }
            if (dot(rayColor,rayColor)==0.0)break;
            Ray newRay;
            newRay.pos = intersection.pos;
            newRay.dir = dir;
            newRay.invDir = 1.0/dir;
            ray = newRay;
            
        }
        else {
            lightColor += ambientLight(ray.dir) * rayColor;
            break;
        }
    }
    return lightColor;
}

void main() {
    checkedShape = 0;
    vec2 uv = gl_FragCoord.xy/u_resolution;
    uv.y = 1.0-uv.y;
    uint seed = uint(gl_FragCoord.x) + uint(gl_FragCoord.y) * uint(u_resolution.x) + uint(frame * 713393);
    vec2 xy = uv - vec2(0.5);
    Ray mainRay = getRay(xy);
    Intersection intersection = getClosestIntersectionBVH(mainRay,-1);
    if (intersection.shapeIndex!=-1){
        //gl_FragColor = vec4(getShapeCol(intersection.shapeIndex),1.0);
        //if (intersection.frontFace)gl_FragColor = vec4(1.0);
        //else gl_FragColor = vec4(1.0,0.0,0.0,1.0);
        vec3 totalDiffuseColor = vec3(0.0);
        
        for (int i=0;i<rayCount;i++){
            vec2 pos = randomPointOnCircle(seed);
            vec3 randomCirclePoint = (pos.x * horizontalDirScreen + pos.y * verticalDirScreen) * blurStrength / u_resolution.x;
            vec3 endPoint = mainRay.pos + randomCirclePoint;
            vec3 dir = getRayDir(endPoint);
            Ray ray;
            ray.pos = endPoint;
            ray.dir = dir;
            ray.invDir = 1.0/dir;
            totalDiffuseColor += rayTrace(ray,seed);
        }
        vec3 diffuseColor = totalDiffuseColor/(float(rayCount));
        gl_FragColor = vec4(diffuseColor/5.0,1.0);
        //gl_FragColor = vec4(getNormal(intersection.shapeIndex,intersection.pos),1.0);
    }
    else if (showAmbientLight){
        gl_FragColor = vec4(ambientLight(mainRay.dir)/5.0,1.0);
    }
    else{
        gl_FragColor = vec4(0.0,0.0,0.0,1.0);
    }
}
//------------------------------  shaders/shader.glsl  ------------------------------




