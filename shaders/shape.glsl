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