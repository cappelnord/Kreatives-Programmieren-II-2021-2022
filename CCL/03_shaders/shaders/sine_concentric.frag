void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // wrap sine around the center
    float w = atan(0.5 - uv.x, 0.5 - uv.y);  
    w = (sin(w) * 0.5) + 0.5;
    
    vec3 col = vec3(w);

    fragColor = vec4(col, 1.0);
}