extern number time;
extern vec4 color1;
extern vec4 color2;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float wave = sin((screen_coords.x + time * 100.0) * 0.05) * 0.1;
    float t = screen_coords.x / love_ScreenSize.x;
    vec4 base = mix(color1, color2, t);
    base.rgb += wave;
    return base;
}
