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
