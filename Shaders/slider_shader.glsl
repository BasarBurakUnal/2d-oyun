extern number time;
extern vec2 resolution;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords) {
    vec2 coord = (2.0 * screen_coords - resolution) / min(resolution.x, resolution.y);

    float t = time * 0.2;

    for (float i = 1.0; i < 10.0; i++) {
        coord.x += 0.6 / i * cos(i * 2.5 * coord.y + t);
        coord.y += 0.6 / i * cos(i * 1.5 * coord.x + t);
    }

    float brightness = 1.0 / (0.3 + abs(sin(t - coord.y - coord.x)));
    brightness *= 0.8;

    vec3 colorYellow = vec3(0.8, 0.8, 0.2);
    return vec4(colorYellow * brightness, 1.0);
}
