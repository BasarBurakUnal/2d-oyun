extern number time;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
    float hue = mod(time * 0.3, 1.0);
    vec3 rainbow = hsv2rgb(vec3(hue, 1.0, 1.0));
    vec4 texColor = Texel(tex, uv);
    return vec4(rainbow, texColor.a) * texColor;
}
