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

struct Pixel {
  vec3 colorSum;
  uint sampleCount;
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
    vec3 v0 = B - A;
    vec3 v1 = C - A;
    vec3 normal = cross(v0, v1);
    float areaABC = length(normal);

    vec3 normalPBC = cross(B - P, C - P);
    float areaPBC = length(normalPBC);

    vec3 normalPCA = cross(C - P, A - P);
    float areaPCA = length(normalPCA);

    vec3 normalPAB = cross(A - P, B - P);
    float areaPAB = length(normalPAB);

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


layout(std430, binding = 3) buffer Pixels {
  Pixel pixels[];
};

int shapeAttributes = 30;
int BVHAttributes = 8;

uniform int shapeCount;
uniform int BVHCount;
uniform int mainBVHCount;
uniform int imageCount;

vec3 getShapePos1(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes],shapes[shapeIndex*shapeAttributes+1],shapes[shapeIndex*shapeAttributes+2]);
}
vec3 getShapePos2(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+3],shapes[shapeIndex*shapeAttributes+4],shapes[shapeIndex*shapeAttributes+5]);
}
vec3 getShapePos3(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+6],shapes[shapeIndex*shapeAttributes+7],shapes[shapeIndex*shapeAttributes+8]);
}

vec3 getShapeColor(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+9],shapes[shapeIndex*shapeAttributes+10],shapes[shapeIndex*shapeAttributes+11]);
}

vec3 getShapeLightCol(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+12],shapes[shapeIndex*shapeAttributes+13],shapes[shapeIndex*shapeAttributes+14]);
}

float getShapeSmoothness(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+15];
}

float getShapeSpecularChance(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+16];
}

vec3 getShapeSpecularColor(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+17],shapes[shapeIndex*shapeAttributes+18],shapes[shapeIndex*shapeAttributes+19]);
}

float getShapeDielectric(int shapeIndex){
    return shapes[shapeIndex*shapeAttributes+20];
}

vec3 getShapeNormal1(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+21],shapes[shapeIndex*shapeAttributes+22],shapes[shapeIndex*shapeAttributes+23]);
}

vec3 getShapeNormal2(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+24],shapes[shapeIndex*shapeAttributes+25],shapes[shapeIndex*shapeAttributes+26]);
}

vec3 getShapeNormal3(int shapeIndex){
    return vec3(shapes[shapeIndex*shapeAttributes+27],shapes[shapeIndex*shapeAttributes+28],shapes[shapeIndex*shapeAttributes+29]);
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
    vec3 A = getShapePos1(shapeIndex);
    vec3 B = getShapePos2(shapeIndex);
    vec3 C = getShapePos3(shapeIndex);
    vec3 normal1 = getShapeNormal1(shapeIndex);
    vec3 normal2 = getShapeNormal2(shapeIndex);
    vec3 normal3 = getShapeNormal3(shapeIndex); 
    vec3 uvw = computeBarycentric(A,B,C,pos);
    return uvw.x*normal1+uvw.y*normal2+uvw.z*normal3;
}
//------------------------------  shaders/shape.glsl  ------------------------------



//------------------------------  shaders/ray.glsl  ------------------------------
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

//------------------------------  shaders/ray.glsl  ------------------------------



//------------------------------  shaders/rayTracer.glsl  ------------------------------
uniform vec2 u_resolution;
uniform int frame;

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
                    rayColor *= getShapeColor(lastHitShape);
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
                rayColor *= mix(getShapeColor(lastHitShape),getShapeSpecularColor(lastHitShape),isSpecular);
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

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

uniform float time;

void main() {
    uint index = (gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * uint(u_resolution.x));
    vec2 pos = gl_GlobalInvocationID.xy/u_resolution.xy;
    vec2 uv = pos;
    uv.y = 1.0-uv.y;
    uint seed = uint(gl_GlobalInvocationID.x) + uint(gl_GlobalInvocationID.y) * uint(gl_GlobalInvocationID.x) + uint(frame * 713393);
    vec2 xy = uv - vec2(0.5);
    Ray mainRay = getRay(xy);
    Intersection intersection = getClosestIntersectionBVH(mainRay,-1);
    if (intersection.shapeIndex!=-1){
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
        pixels[index].colorSum += diffuseColor;
        pixels[index].sampleCount += 1;
    }
    else if (showAmbientLight){
        pixels[index].colorSum += ambientLight(mainRay.dir);
        pixels[index].sampleCount += 1;
    }
}
//------------------------------  shaders/rayTracer.glsl  ------------------------------




