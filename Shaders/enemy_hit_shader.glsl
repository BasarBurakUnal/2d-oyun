extern number hitAmount;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texColor = Texel(texture, texture_coords);
    vec3 whiteFlash = mix(texColor.rgb, vec3(1.0), hitAmount);
    return vec4(whiteFlash, texColor.a) * color;
}
