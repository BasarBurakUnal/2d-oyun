extern number time;

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
{
    vec4 texColor = Texel(texture, texCoord);
    

    float glow = 0.1 + 0.3 * sin(time * 4.0);

    texColor.rgb += glow;

    return texColor * color;
}
