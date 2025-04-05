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