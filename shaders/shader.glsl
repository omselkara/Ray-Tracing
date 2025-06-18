#version 460 core

out vec4 gl_FragColor;

uniform sampler2D MainTexOld;
uniform sampler2D MainTex;
uniform vec2 u_resolution;
uniform float numRenderedFrames;

float correct(float value){
    return sqrt(value);
}

struct Pixel {
  vec3 oldRender;
  uint sampleCount;
};

layout(std430, binding = 3) buffer Pixels {
  Pixel pixels[];
};

vec3 correct(vec3 color){
  return pow(color, vec3(1.0 / 2.2));
}

void main() {
    ivec2 pixelCoord = ivec2(gl_FragCoord.xy);
    uint pos = uint(pixelCoord.x) + uint(u_resolution.x) * uint(pixelCoord.y);
    gl_FragColor = vec4(correct(pixels[pos].oldRender/pixels[pos].sampleCount),1.0);
}
