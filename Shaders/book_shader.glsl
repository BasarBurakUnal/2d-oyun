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

vec2 barrelDistort(vec2 pos, float power){
    float t = atan(pos.y, pos.x);
    float r = pow(length(pos), power);
    return 0.5 * (vec2(cos(t), sin(t)) * r + 1.0);
}

float easeOutCubic(float x){ return 1.0 - pow(1.0 - x, 3.0); }
float easeInCubic(float x){ return x * x * x; }

vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords){
    vec2 uv = texCoords;
    vec2 center = vec2(0.5 * aspectRatio, 0.5);
    vec2 st = uv * vec2(aspectRatio, 1.0);
    vec2 pos = st - center;
    float dist = length(pos);

    float duration = 2.0;
    float t = clamp(iTime / duration, 0.0, 1.0);
    float halfTime = 0.5;

    float progress = (t < halfTime)
        ? easeOutCubic(t / halfTime)
        : 1.0 - easeInCubic((t - halfTime) / halfTime);

    float zoom = mix(1.0, 1.05, progress);
    float rotation = 0.15 * progress;
    float angle = rotation * (0.5 - texCoords.y);

    float cs = cos(angle);
    float sn = sin(angle);
    mat2 rot = mat2(cs, -sn, sn, cs);
    vec2 p = (texCoords - 0.5) * zoom;
    p = rot * p;
    p += 0.5;

    vec2 distorted = barrelDistort(-1.0 + 2.0 * p, 1.0 / (1.0 + 0.3 * progress));
    vec2 distortedUV = (distorted - p) + p;

    float shake = 0.005 * (1.0 - progress) * noise(screenCoords * 0.5 + iTime);
    distortedUV += shake;

    vec4 texColor = Texel(iChannel1, distortedUV);

    float ring = smoothstep(progress, progress + 0.02, dist * 0.8);
    vec4 outline = whiteOutline(progress, dist * 0.8);

    float vignette = smoothstep(0.8, 0.2, dist);

    vec4 darkened = mix(texColor, vec4(0.0), 0.2 * (1.0 - ring));
    return darkened + outline;
}