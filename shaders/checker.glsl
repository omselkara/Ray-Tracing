#version 460 core

out vec4 gl_FragColor;

uniform vec2 u_resolution;

uniform vec3 col1;
uniform vec3 col2;
uniform vec2 uv;
uniform vec2 offset;


void main() {
    vec2 pos = (gl_FragCoord.xy/u_resolution) - offset;
    float dx = 1.0/uv.x;
    float dy = 1.0/uv.y;
    int x = int(pos.x/dx);
    if (pos.x<0) x--;
    int y = int(pos.y/dy);
    if (pos.y<0) y--;
    float index = mod(mod(float(x),2.0)+mod(float(y),2.0),2.0);
    gl_FragColor = vec4(mix(col1,col2,index),1.0); 

}
