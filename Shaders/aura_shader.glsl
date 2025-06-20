extern number time;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    vec4 texColor = Texel(tex, tex_coords);

    float wave = sin(time * 6.0 + tex_coords.y * 30.0) * 0.3 + 0.7;
    float pulse = sin(time * 2.0) * 0.6 + 0.9;

    float hue = mod(time * 0.2, 1.0);
    vec3 rainbow = hsv2rgb(vec3(hue, 1.0, 1.0));

    vec3 baseColor = rainbow * wave * pulse;

    return vec4(baseColor, texColor.a);
}
