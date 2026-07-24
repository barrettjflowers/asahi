#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 screen_size;

const float scanlineIntensity = 0.35;
const float bloomThreshold = 0.75;
const float bloomIntensity = 0.10;

void main() {
    vec2 off = 6.0 / screen_size;
    vec3 color = texture(tex, v_texcoord).rgb;

    float scanline = step(0.5, fract(v_texcoord.y * screen_size.y * 0.5));
    color *= 1.0 - scanline * scanlineIntensity;

    vec3 glow = vec3(0.0);
    vec3 s;
    s = texture(tex, v_texcoord + vec2(-off.x, -off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( 0.0,  -off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( off.x, -off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2(-off.x,  0.0)).rgb;  if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( 0.0,   0.0)).rgb;  if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( off.x,  0.0)).rgb;  if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2(-off.x,  off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( 0.0,   off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;
    s = texture(tex, v_texcoord + vec2( off.x,  off.y)).rgb; if (dot(s, vec3(0.2126, 0.7152, 0.0722)) > bloomThreshold) glow += s;

    color += glow * (bloomIntensity / 9.0);

    fragColor = vec4(color, 1.0);
}
