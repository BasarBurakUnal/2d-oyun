vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
{
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(texCoord, center);

    float glow = smoothstep(0.55, 0.05, dist);

    vec3 glowColor = vec3(1.0, 0.9, 0.3);
    return vec4(glowColor * glow, glow);
}
