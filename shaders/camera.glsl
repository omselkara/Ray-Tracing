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