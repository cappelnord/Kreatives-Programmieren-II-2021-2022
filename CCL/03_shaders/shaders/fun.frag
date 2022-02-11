// load soundfile to iChannel0!

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    int tx = int(uv.x * 512.0);
 
    float sound = texelFetch(iChannel0, ivec2(tx, 1), 0).x;
    
    vec2 c = vec2(0.5 - uv.x, 0.5 - uv.y);

    float dtoc1 = sqrt(pow(c.x - 0.1, 2.0) + pow(c.y - 0.1, 2.0));
    float dtoc2 = sqrt(pow(c.x + 0.1, 2.0) + pow(c.y + 0.1, 2.0));

    float dPow = pow(dtoc1, dtoc2);

    float w = atan(dtoc1, dtoc2);   
    w = atan(w - dPow, w + dPow);
    
    vec3 col = vec3(1.0 * (sin(w * (iTime * mod(abs(sound / 60.0), sin(dPow * cos(iTime * 1.0) * 100.0))) - (iTime * 12.0))), 1.0 * (sin(w * (iTime / abs(sound * 60.0)) - (iTime * 11.0))), 1.0 * (sin(w * (iTime / 60.0) - abs(sound * 7.0))));

    fragColor = vec4(col, 1.0);
}