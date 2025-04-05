#version 460 core

out vec4 gl_FragColor;

uniform sampler2D MainTexOld;
uniform vec2 u_resolution;

float correct(float value){
    return sqrt(value);
}

vec3 getColor(vec2 pos){
    vec4 oldRender = texture(MainTexOld, pos/u_resolution);
    return oldRender.rgb * sqrt(5.0);
}

void main() {
    gl_FragColor = vec4(getColor(gl_FragCoord.xy),1.0);
}
