extern number time;
extern bool hovered;
extern vec2 iResolution;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 fragCoord)
{
    if (!hovered) {
        return vec4(1.0, 1.0, 1.0, 1.0) * color;
    }

    vec2 uv = (2.0 * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);

    for (float i = 1.0; i < 10.0; i++) {
        uv.x += 0.6 / i * cos(i * 2.5 * uv.y + time);
        uv.y += 0.6 / i * cos(i * 1.5 * uv.x + time);
    }

    vec3 col = vec3(0.1) / abs(sin(time - uv.y - uv.x));
    return vec4(col, 1.0) * color;
}
