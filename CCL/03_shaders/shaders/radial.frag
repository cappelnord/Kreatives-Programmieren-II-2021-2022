void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // center
    vec2 c = vec2(0.5 - uv.x, 0.5 - uv.y);

    // distance to the center (Pythagoras)
    float dtoc = sqrt(pow(c.x, 2.0) + pow(c.y, 2.0));
    
    vec3 col = vec3(dtoc);

    fragColor = vec4(col, 1.0);
}