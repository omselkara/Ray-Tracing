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