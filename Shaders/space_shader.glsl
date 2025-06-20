extern number time;
extern vec2 cameraPos;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

float star(vec2 uv, float scale, float intensity) {
    vec2 id = floor(uv * scale);
    float r1 = rand(id);
    float r2 = rand(id + 123.456);

    float flicker = 0.8 + 0.2 * sin(time * 1.0 + r2 * 6.28);

    float rare = step(0.85, r1);
    return flicker * rare * intensity;
}

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
    vec2 uv = (screenCoord + cameraPos * 0.05) / love_ScreenSize.xy;

    float brightness = 0.0;
    brightness += star(uv, 1.0, 1.0);
    brightness += star(uv, 2.5, 0.5);
    brightness += star(uv, 6.0, 0.3);

    vec3 skyColor = vec3(0.02, 0.02, 0.05);
    vec3 starColor = vec3(1.0, 1.0, 1.0);

    return vec4(skyColor + starColor * brightness, 1.0);
}
