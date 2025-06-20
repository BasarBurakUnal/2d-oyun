extern number time;
extern vec2 cameraPos;

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float fbm(vec2 p) {
    float f = 0.0;
    f += 0.5000 * noise(p); p *= 2.02;
    f += 0.2500 * noise(p); p *= 2.03;
    f += 0.1250 * noise(p); p *= 2.01;
    return f;
}

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
{
    vec2 uv = screenCoord / love_ScreenSize.xy;
    uv += cameraPos / 2000.0;

    uv *= 3.0;
    uv += vec2(time * 0.02, -time * 0.015);

    float n = fbm(uv);
    n = smoothstep(0.2, 0.6, n);


    vec3 nebulaColor = vec3(0.4, 0.0, 0.6);
    return vec4(nebulaColor * n, n * 0.4);
}
