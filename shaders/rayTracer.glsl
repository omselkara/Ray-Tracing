#version 460 core

out vec4 gl_FragColor;

uniform sampler2D MainTexOld;
uniform sampler2D MainTex;
uniform vec2 u_resolution;
uniform float numRenderedFrames;

float correct(float value){
    return sqrt(value);
}

vec3 getColor(vec2 pos){
    vec4 oldRender = texture(MainTexOld, pos/u_resolution);
    vec4 newRender = texture(MainTex, pos/u_resolution);
    newRender.r = correct(newRender.r);
    newRender.g = correct(newRender.g);
    newRender.b = correct(newRender.b);
    float weight = 1.0/(numRenderedFrames+1.0);
    if (dot(newRender.rgb,newRender.rgb)>0.0) return oldRender.rgb*(1.0-weight)+newRender.rgb*weight;
    return oldRender.rgb;
}

void main() {
    gl_FragColor = vec4(getColor(gl_FragCoord.xy),1.0);
}
