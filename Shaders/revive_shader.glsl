extern number time;
extern vec4 color;

vec4 effect(vec4 col, Image tex, vec2 texCoord, vec2 screenCoord) {
    vec4 pixel = Texel(tex, texCoord);
    float pulse = abs(sin(time * 6.0));
    return pixel * (1.0 + pulse * 2.0) * color;
}
