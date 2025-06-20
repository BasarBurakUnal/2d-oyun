extern number hitAmount;
number opacity = 0.5;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texColor = Texel(texture, texture_coords) * color;

    texColor.rgb += vec3(hitAmount * opacity, 0.0, 0.0);

    texColor.rgb = clamp(texColor.rgb, 0.0, 1.0);

    return texColor;
}
