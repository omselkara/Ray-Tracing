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