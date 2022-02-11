// load soundfile to iChannel0!

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // texel coordinate (x)
    int tx = int(uv.x * 512.0);
 
    // second row is the sound wave, one texel is one mono sample
    float sound = texelFetch(iChannel0, ivec2(tx, 1), 0).x;

    float blue = 0.0; 
    blue += 1.0 - abs(sound - uv.y);

    vec3 col = vec3(0.0, 0.0, blue);

    fragColor = vec4(col, 1.0);
}