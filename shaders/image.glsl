#version 460 core

out vec4 gl_FragColor;

uniform vec2 u_resolution;

uniform sampler2D tex;
uniform vec2 offset;


void main() {
    vec2 pos = (gl_FragCoord.xy/u_resolution) - offset;
    vec3 pixel = texture(tex, vec2(mod(pos.x,1.0),mod(pos.y,1.0))).rgb;
    gl_FragColor = vec4(pixel,1.0);
}
