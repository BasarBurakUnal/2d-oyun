extern number iTime;
extern Image iChannel1;
extern vec2 iResolution;

float aspectRatio = iResolution.x / iResolution.y;

vec2 random2(vec2 st){
    st = vec2(dot(st, vec2(127.1, 311.7)),
              dot(st, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);
    vec2 randVal = random2(i);

    return mix(
        mix(dot(randVal, f - vec2(0.0, 0.0)),
            dot(randVal, f - vec2(1.0, 0.0)), u.x),
        mix(dot(randVal, f - vec2(0.0, 1.0)),
            dot(randVal, f - vec2(1.0, 1.0)), u.x),
        u.y
    );
}

vec4 whiteOutline(float timingVal, float radius){
    float outerEdge = smoothstep(clamp(timingVal + 0.02, 0.0, 1.0) - 0.1,
                                 clamp(timingVal + 0.02, 0.0, 1.0), radius);
    float innerEdge = smoothstep(clamp(timingVal + 0.01, 0.0, 1.0),
                                 clamp(timingVal + 0.01, 0.0, 1.0) + 0.01, radius);
    return vec4(vec3(outerEdge - innerEdge), 1.0);
}

vec4 imageFilter(vec2 st, vec4 color, vec4 filteredColor, float timePercent){
    st -= vec2(0.5 * aspectRatio, 0.5);
    float r = length(st) * 0.8;
    float timingVal = timePercent;

    float a = 0.2 * atan(st.y, st.x);
    timingVal += (sin(a * 50.0) * timingVal) * noise(st + 0.2) * 0.2;

    float circlePos = smoothstep(clamp(timingVal, 0.0, 1.0),
                                 clamp(timingVal, 0.0, 1.0) + 0.007, r);

    return color * vec4(circlePos) +
           whiteOutline(timingVal, r) +
           filteredColor * vec4(1.0 - circlePos);
}

vec2 barrelDistort(vec2 pos, float power){
    float t = atan(pos.y, pos.x);
    float r = pow(length(pos), power);
    return 0.5 * (vec2(cos(t), sin(t)) * r + 1.0);
}

float easeInCubic(float x){
    return x * x * x;
}
float easeOutCubic(float x){
    return 1.0 - pow(1.0 - x, 3.0);
}

vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords){
    vec2 uv = texCoords;
    vec2 p = -1.0 + 2.0 * uv;
    vec2 st = uv * vec2(aspectRatio, 1.0);

    float currTime = iTime;
    float negativeWaveTime = 1.33; // 4 saniyeye oranlandı

    vec4 texColor = Texel(iChannel1, uv);
    vec3 base = pow(texColor.rgb, vec3(0.6));
    vec3 cool = vec3(0.6, 0.7, 1.0);
    vec3 mixed = mix(base, cool, 0.4);
    mixed = (mixed - 0.5) * 1.2 + 0.5;
    vec4 imageNegative = vec4(clamp(mixed, 0.0, 1.0), texColor.a);

    float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    vec4 greyImage = vec4(grey, grey, grey, 1.0);

    if (currTime > 0.0 && currTime <= 3.0) {
        float timeSegment = easeOutCubic(clamp(currTime, 0.0, 1.5) / 1.5);
        if (currTime > 1.67) {
            timeSegment = 1.0 - easeInCubic(clamp(currTime - 1.5, 0.0, 1.5) / 1.5);
        }
        float barrel_pow = 1.0 + 0.2 * (1.0 + timeSegment);
        p = barrelDistort(p, 1.0 / barrel_pow);
        uv = (p - uv) + uv;
        texColor = Texel(iChannel1, uv);
        imageNegative = vec4(1.0) - texColor;
        grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
        greyImage = vec4(grey, grey, grey, 1.0);
    }

    if (currTime <= 1.33) {
        return imageFilter(st, texColor, imageNegative, clamp(currTime, 0.0, 1.33) / negativeWaveTime);
    } else if (currTime > 1.33 && currTime <= 2.0) {
        return imageFilter(st, imageNegative, imageNegative, clamp(currTime - 1.33, 0.0, 0.67) / 0.67);
    } else if (currTime > 2.0 && currTime <= 3.0) {
        return imageFilter(st, imageNegative, imageNegative, 1.0 - clamp(currTime - 2.0, 0.0, 1.0) / 1.0);
    } else if (currTime > 3.0 && currTime <= 4.0) {
        return imageFilter(st, greyImage, imageNegative, 1.0 - clamp(currTime - 3.0, 0.0, 1.0) / 1.0);
    } else {
        return texColor;
    }
}
